from pydantic import BaseModel
from typing import List

class GraphDataPoint(BaseModel):
    label: str
    value: float
    color: str # Hex code for UI

class DashboardAnalysisResponse(BaseModel):
    # Pie Chart Data (e.g., "Beneficial", "Moderate", "Limit")
    health_breakdown: List[GraphDataPoint]
    
    # Bar/Line Graph Data (Estimated Nutrient breakdown of the pantry)
    macro_distribution: List[GraphDataPoint]
    
    # Text feedback
    ai_feedback: str