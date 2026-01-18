import os
import time
from dotenv import load_dotenv
from google import genai
from google.genai.errors import ServerError
from app.integrations.rag_utils import get_relevant_passages, get_chroma_db
from app.integrations.memory import ShortTermMemory
import json

load_dotenv()
api_key = os.getenv("GEMINI_API")
client = genai.Client(api_key=api_key)


class NutritionAnalyzer:
   
    def __init__(self, db_name="disease-guidelines"):
        self.db = get_chroma_db(db_name)
        self.memory = ShortTermMemory(max_turns=6)
        
    def analyze(self, gender,goals,allergies, disease,nutrition_text, user_query, n_results=5, ask_qs = True):
        # Store user query in short-term memory
        self.memory.add("user", user_query)
        search_query = (
            f"{user_query}. "
            f"This is about nutrition guidelines for {disease} and applies to {gender}."
        )

        relevant_guidelines = get_relevant_passages(self.db, search_query, n_results=n_results)
        
        if relevant_guidelines:
            guidelines_context = "\n\nRelevant Guidelines from Database:\n"
            for i, guideline in enumerate(relevant_guidelines, 1):
                guidelines_context += f"\n{i}. {guideline['content']}\n"
                if guideline.get('metadata'):
                    guidelines_context += f"   (Category: {guideline['metadata'].get('category', 'N/A')}, "
                    guidelines_context += f"Gender: {guideline['metadata'].get('gender', 'N/A')})\n"
        else:
            guidelines_context = "\n\nNo specific guidelines found in our database for this query."
        
        conversation_context = self.memory.get_context() 
        system_prompt = f"""You are a Nutrition Assistant at Nutrio. Your job is to analyze food products and provide personalized nutrition guidance based on user health conditions.

            Conversation so far:
            {conversation_context}

            User Information:
            - Gender: {gender}
            - Health Condition(s): {disease if disease and disease.lower() != 'none' else 'None reported'}
            - Their Goals: {goals  if goals and goals.lower() != 'none' else 'None reported'}
            - They have the following Allergies: {allergies  if allergies and allergies.lower() != 'none' else 'None reported'}

            User Query: {user_query}
            {guidelines_context}
            Product Nutrition Information:
            {nutrition_text}

            Your Task:
            Analyze whether this product is suitable for the user given their health condition(s). Provide:
            1. A clear recommendation (Safe/Moderate/Avoid)
            2. Specific nutrients of concern (if any)
            3. Suggested serving size or frequency of consumption like if it is a chip packet and you know they should'nt have more than 1 packet a week say that (only if applicable).

            {"4. if you are telling the prodect is not safe ask them if they would like alternative and if needed click the button below" if ask_qs 
             else "4. This is a summary so don't ask the user anymore questions"}
            
            If it is a general question reply accordingly. be polite i less words , always remember you are a nutrition assistant created by nutrio.

            If we don't have specific guidelines for the user's condition in our database, tell them that you dont have the information regarding this.politely

            Be empathetic, clear, and actionable in your response. Dont make it long try to keep it under 60 words."""

        # Retry logic with exponential backoff for handling 503 errors
        max_retries = 3
        retry_delay = 2  # Start with 2 seconds
        
        for attempt in range(max_retries):
            try:
                response = client.models.generate_content(
                    model='gemini-2.5-flash',
                    contents=system_prompt
                )
                # Store assistant response in memory
                self.memory.add("assistant", response.text)

                
                return {
                    'success': True,
                    'recommendation': response.text,
                    'relevant_guidelines': relevant_guidelines,
                    'nutrition_summary': nutrition_text
                }
            except ServerError as e:
                # Check if it's a 503 error (overloaded)
                if '503' in str(e) or 'overloaded' in str(e).lower():
                    if attempt < max_retries - 1:
                        wait_time = retry_delay * (2 ** attempt)  # Exponential backoff
                        print(f"Model overloaded. Retrying in {wait_time} seconds... (Attempt {attempt + 1}/{max_retries})")
                        time.sleep(wait_time)
                        continue
                    else:
                        print(f"DEBUG - Error occurred after {max_retries} attempts: {str(e)}")
                        return {
                            'success': False,
                            'error': str(e),
                            'message': "The AI service is currently experiencing high load. Please try again in a few moments."
                        }
                else:
                    # For other server errors, don't retry
                    print(f"DEBUG - Server error occurred: {str(e)}")
                    return {
                        'success': False,
                        'error': str(e),
                        'message': "I apologize, but I encountered a server error. Please try again."
                    }
            except Exception as e:
                print(f"DEBUG - Error occurred: {str(e)}")
                print(f"DEBUG - Error type: {type(e).__name__}")
                import traceback
                traceback.print_exc()
                return {
                    'success': False,
                    'error': str(e),
                    'message': "I apologize, but I encountered an error while analyzing this product. Please try again."
                }
            
    def process_chat_message(user_message: str, user_profile: dict, history_context: str) -> dict:
        """
        Analyzes a chat message using RAG context + Database History.
        """
        # Initialize the analyzer to access the vector DB
        analyzer = NutritionAnalyzer(db_name="disease-guidelines")
        
        # 1. Get RAG Context for the *current* specific question
        # We construct a search query that includes user context
        search_query = (
            f"{user_message}. "
            f"User has {user_profile.get('disease', 'no conditions')} "
            f"and goals: {user_profile.get('goals', 'general health')}."
        )
        
        relevant_guidelines = get_relevant_passages(analyzer.db, search_query, n_results=3)
        
        guidelines_text = ""
        if relevant_guidelines:
            guidelines_text = "\nRelevant Nutrition Guidelines:\n"
            for i, g in enumerate(relevant_guidelines, 1):
                guidelines_text += f"{i}. {g['content']}\n"
        
        # 2. Construct the Prompt with History
        system_prompt = f"""You are a friendly and knowledgeable Nutrition Assistant at Nutrio.
        
        User Profile:
        - Name: {user_profile.get('name')}
        - Health Conditions: {user_profile.get('disease') or 'None'}
        - Goals: {user_profile.get('goals') or 'None'}
        - Allergies/Preferences: {user_profile.get('allergies') or 'None'}
        
        {guidelines_text}
        
        Recent Conversation History:
        {history_context}
        
        User's New Message: {user_message}
        
        Task: Reply to the user. Use the relevant guidelines if they apply to the specific question. 
        If the user asks about previous topics, refer to the history. 
        Keep the tone encouraging, concise (under 80 words), and safe. 
        If you don't know something, admit it politely."""

        # 3. Call Gemini
        try:
            response = client.models.generate_content(
                model='gemini-2.5-flash',
                contents=system_prompt
            )
            return {
                'success': True,
                'response': response.text
            }
        except Exception as e:
            print(f"Chat Error: {str(e)}")
            return {
                'success': False,
                'response': "I'm having trouble connecting right now. Please try again."
            }
    def analyze_user_dashboard(self, user_profile: dict, inventory_items: list, timeline: str = "1 year") -> dict:
        """
        Analyzes the user's entire inventory by processing the detailed 'product_data' 
        of each item to predict long-term health outcomes.
        """
        # 1. Prepare Inventory Text with detailed Product Data
        if not inventory_items:
            return {
                "health_score": 0,
                "mood_prediction": "Unknown",
                "body_prediction": "Unknown",
                "timeline_analysis": "Inventory empty. Please add items to generate a prediction.",
                "nutrients_of_concern": []
            }

        # Build a comprehensive context string from the inventory list
        inventory_context = "User's Current Dietary Intake (based on Inventory Data):\n"
        
        for item in inventory_items:
            # We access the specific fields defined in your SQLModel/Pydantic schema
            title = getattr(item, 'title', 'Unknown Product')
            score = getattr(item, 'nutrient_score', 'N/A')
            
            # Access the raw string data stored in the database
            # We truncate it to 300 chars per item to avoid token overflow if the list is huge
            raw_data = getattr(item, 'product_data', '')[:300] 
            
            inventory_context += f"""
            - Product: {title}
              Nutri-Score: {score}
              Details: {raw_data}
            """

        # 2. Get RAG Context (Mechanisms of Action)
        disease = user_profile.get('disease', 'General Health')
        
        # Search for specific biological mechanisms related to the user's condition
        search_query = (
            f"Physiological and psychological effects of diet on {disease}. "
            f"Mechanisms linking processed food, sugar, and additives to mood and brain structure."
        )
        
        relevant_passages = get_relevant_passages(self.db, search_query, n_results=4)
        
        clinical_context = ""
        if relevant_passages:
            clinical_context = "\nClinical Evidence & Mechanisms:\n"
            for p in relevant_passages:
                clinical_context += f"- {p['content']}\n"

        # 3. Construct the Predictive Prompt
        system_prompt = f"""
        You are Nutrio's Medical Prediction Engine.
        Your task is to analyze the user's *actual* food consumption data to predict their future health trajectory.

        USER PROFILE:
        - Condition: {disease}
        - Gender: {user_profile.get('gender', 'N/A')}
        - Goals: {user_profile.get('goals', 'N/A')}
        - Timeline: {timeline}

        CLINICAL KNOWLEDGE BASE (Source of Truth):
        {clinical_context}

        INVENTORY DATA (The Food They Eat):
        {inventory_context}

        TASK:
        Analyze the "Details" (ingredients/nutrients) of the products listed above. 
        Predict the specific biological impact on this user if they consume this inventory regularly for {timeline}.

        REQUIREMENTS:
        1. **Health Score**: 0-100 (Based on nutrient density vs. processing level).
        2. **Mood Analysis**: Use the ingredient data to predict neurochemical effects (e.g., "High sugar causing dopamine crashes", "Additives linked to anxiety").
        3. **Body Analysis**: Predict physiological outcomes (e.g., "Inflammation markers may rise due to processed oils found in Product X").
        4. **Nutrients of Concern**: Identify the specific bad actors hidden in the `product_data`.

        OUTPUT FORMAT (STRICT JSON ONLY):
        {{
            "health_score": 72,
            "prediction_summary": "Over the next {timeline}, your current intake of...",
            "mood_analysis": {{
                "state": "Variable / Foggy",
                "mechanism": "The high fructose corn syrup in [Product Name] may disrupt..."
            }},
            "body_analysis": {{
                "state": "Pro-Inflammatory",
                "mechanism": "The processed seed oils in your inventory are linked to..."
            }},
            "key_nutrients": [
                {{"nutrient": "Sodium", "status": "Excess", "impact": "Water retention"}},
                {{"nutrient": "Omega-3", "status": "Low", "impact": "Cognitive decline"}}
            ],
            "recommendation": "Try swapping [Unhealthy Item] for a whole-food alternative."
        }}
        """

        try:
            response = client.models.generate_content(
                model='gemini-2.5-flash',
                contents=system_prompt,
                config=genai.types.GenerateContentConfig(
                    response_mime_type="application/json"
                )
            )
            
            return json.loads(response.text)
            
        except Exception as e:
            print(f"Dashboard Prediction Error: {e}")
            return {
                "health_score": 0,
                "prediction_summary": "Unable to generate prediction.",
                "mood_analysis": {"state": "N/A", "mechanism": "N/A"},
                "body_analysis": {"state": "N/A", "mechanism": "N/A"},
                "key_nutrients": [],
                "recommendation": "Please try again."
            }

def analyze_nutrition(nutrition:dict,disease:str,gender:str='male',goals:str='none',allergies:str='none') -> str:
    analyzer = NutritionAnalyzer(db_name="disease-guidelines")
    result = analyzer.analyze(
        gender=gender,  #TODO
        disease=disease,
        goals=goals,
        allergies=allergies,
        user_query="Describe in detail about your opinion on viability of this product for me",
        nutrition_text=nutrition,
        ask_qs=False
    )
    if result['success']:
        result = f"{result['recommendation']}"
        return result
    else:
        print(f"Error: {result['message']}")
        if 'error' in result:
            print(f"Details: {result['error']}")
            return "Error"


def generate_dashboard_stats(user: dict, inventory: list, timeline:str = "1 year") -> dict:
    analyzer = NutritionAnalyzer(db_name="disease-guidelines")
    return analyzer.analyze_user_dashboard(user, inventory, timeline)


def compare_products(
    product1: dict,
    product2: dict,
    disease: str,
    gender: str = "male",
    goals: str = "none",
    allergies: str = "none"
) -> dict:
    """
    Compare two products and determine which is better for the user.
    """

    analyzer = NutritionAnalyzer(db_name="disease-guidelines")

    # --- Minimal guideline (optional, short) ---
    guidelines_text = ""
    if disease and disease.lower() != "none":
        guidelines = get_relevant_passages(
            analyzer.db,
            f"Dietary guidelines for {disease}",
            n_results=1
        )
        if guidelines:
            guidelines_text = f"Guideline: {guidelines[0]['content'][:120]}"

    # --- Compact product data ---
    def compact(p: dict) -> dict:
        n = p.get("nutriments", {})
        return {
            "name": p.get("product_name"),
            "grade": p.get("nutrition_grades"),
            "nova": p.get("nova_group"),
            "sugar": n.get("sugars_100g"),
            "fat": n.get("fat_100g"),
            "salt": n.get("salt_100g"),
            "protein": n.get("proteins_100g"),
            "ingredients": (p.get("ingredients_text") or "")[:150]
        }

    p1 = compact(product1)
    p2 = compact(product2)

    name1 = p1.get("name", "Product 1")
    name2 = p2.get("name", "Product 2")

    # --- STRICT minimal-output prompt ---
    system_prompt = f"""
You are Nutrio’s nutrition comparison engine.

User:
Gender: {gender}
Condition: {disease if disease and disease.lower() != "none" else "None"}
Goals: {goals if goals != "none" else "General health"}
Allergies: {allergies if allergies != "none" else "None"}

{guidelines_text}

Product 1: {p1}
Product 2: {p2}

Rules:
- Be concise
- Max 2 pros and 2 cons per product
- Verdict: max 1 sentence mention which product is better here , be more like a personalized suggestion to the user
- Recommendation: max 20 words
- Key factors: exactly 3 short points

Return STRICT JSON ONLY in this format:
{{
  "winner": "1" or "2",
  "winner_name": "{name1} or {name2}",
  "loser_name": "",
  "verdict": "",
  "comparison": {{
    "product1": {{
      "name": "{name1}",
      "pros": [],
      "cons": [],
      "health_rating": "Good/Moderate/Poor for user"
    }},
    "product2": {{
      "name": "{name2}",
      "pros": [],
      "cons": [],
      "health_rating": "Good/Moderate/Poor for user"
    }}
  }},
  "key_factors": [],
  "recommendation": ""
}}
""".strip()

    try:
        response = client.models.generate_content(
            model="gemini-2.5-flash",
            contents=system_prompt,
            config=genai.types.GenerateContentConfig(
                response_mime_type="application/json"
            )
        )

        import json
        data = json.loads(response.text)
        return {
            "success": True,
            "comparison": data
        }

    except Exception as e:
        print(f"Compare Products Error: {e}")
        return {
            "success": False,
            "error": str(e),
            "message": "Unable to compare products at the moment. Please try again."
        }
