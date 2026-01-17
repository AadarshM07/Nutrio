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
        
    def analyze_user_dashboard(self, user_profile: dict, inventory_items: list) -> dict:
        """
        Analyzes the user's entire inventory against their health profile 
        to generate dashboard statistics.
        """
        # 1. Prepare Inventory Text
        if not inventory_items:
            return {
                "health_breakdown": [],
                "macro_distribution": [],
                "ai_feedback": "Your inventory is empty. Add products to get an analysis."
            }

        inventory_text = "User's Current Pantry Inventory:\n"
        for item in inventory_items:
            # Note: nutrient_scrore is the typo from your model, keeping it consistent
            inventory_text += f"- {item.title} (Tag: {item.tag}, Grade: {item.nutrient_score})\n"

        # 2. Get RAG Context (General dietary guidelines for their condition)
        disease = user_profile.get('disease', 'General Health')
        search_query = f"Dietary guidelines for {disease} regarding pantry staples and macronutrient balance."
        
        relevant_guidelines = get_relevant_passages(self.db, search_query, n_results=3)
        guidelines_text = "\n".join([f"- {g['content']}" for g in relevant_guidelines]) if relevant_guidelines else "General healthy eating guidelines."

        # 3. Construct System Prompt for JSON Output
        system_prompt = f"""
        You are the backend AI for Nutrio. Your task is to analyze a user's food inventory and return a strictly formatted JSON response for a dashboard.

        User Profile:
        - Condition: {disease}
        - Goals: {user_profile.get('goals')}
        - Gender: {user_profile.get('gender')}
        
        Medical Guidelines (RAG Context):
        {guidelines_text}

        {inventory_text}

        Task:
        1. Classify the inventory items into "Beneficial", "Moderate", or "Avoid" based on the User Profile. Calculate the percentage of each.
        2. Estimate the aggregate macronutrient profile (Protein, Carbs, Fats, Fiber) represented by this pantry.
        3. Provide a short, actionable feedback summary (max 50 words) referring to specific items in their list.

        OUTPUT FORMAT (STRICT JSON ONLY, NO MARKDOWN):
        {{
            "health_breakdown": [
                {{"label": "Beneficial", "value": 60, "color": "#4CAF50"}},
                {{"label": "Moderate", "value": 30, "color": "#FFC107"}},
                {{"label": "Limit", "value": 10, "color": "#F44336"}}
            ],
            "macro_distribution": [
                {{"label": "Protein", "value": 30, "color": "#2196F3"}},
                {{"label": "Carbs", "value": 50, "color": "#FF9800"}},
                {{"label": "Fats", "value": 20, "color": "#9C27B0"}}
            ],
            "ai_feedback": "Your summary here..."
        }}
        """

        try:
            # Using Gemini 1.5 Flash which is good at JSON
            response = client.models.generate_content(
                model='gemini-2.5-flash',
                contents=system_prompt,
                config=genai.types.GenerateContentConfig(
                    response_mime_type="application/json" 
                )
            )
            
            # Parse JSON
            data = json.loads(response.text)
            return data
            
        except Exception as e:
            print(f"Dashboard Analysis Error: {e}")
            # Return fallback data
            return {
                "health_breakdown": [{"label": "Error", "value": 100, "color": "#9E9E9E"}],
                "macro_distribution": [],
                "ai_feedback": "Unable to generate analysis at the moment."
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


def generate_dashboard_stats(user: dict, inventory: list) -> dict:
    analyzer = NutritionAnalyzer(db_name="disease-guidelines")
    return analyzer.analyze_user_dashboard(user, inventory)