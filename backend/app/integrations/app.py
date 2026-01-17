import os
import time
from dotenv import load_dotenv
from google import genai
from google.genai.errors import ServerError
from app.integrations.rag_utils import get_relevant_passages, get_chroma_db
from app.integrations.memory import ShortTermMemory

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
