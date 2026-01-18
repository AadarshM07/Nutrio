from pydantic import BaseModel
from typing import List, Optional

class ImpactAnalysis(BaseModel):
    state: str
    mechanism: str

class KeyNutrient(BaseModel):
    nutrient: str
    status: str
    impact: str

class DashboardAnalysisResponse(BaseModel):
    health_score: int
    prediction_summary: str
    mood_analysis: ImpactAnalysis
    body_analysis: ImpactAnalysis
    key_nutrients: List[KeyNutrient]
    recommendation: str