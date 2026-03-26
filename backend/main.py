from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import joblib
import pandas as pd
import numpy as np
import os

app = FastAPI()

# Load models and encoders
MODEL_PATH = '../Trained models/agropilot_xgboost.pkl'
CROP_PATH = '../Trained models/encoder_crop.pkl'
REGION_PATH = '../Trained models/encoder_region.pkl'
SOIL_PATH = '../Trained models/encoder_soil.pkl'
STAGE_PATH = '../Trained models/encoder_stage.pkl'

try:
    model = joblib.load(MODEL_PATH)
    le_crop = joblib.load(CROP_PATH)
    le_region = joblib.load(REGION_PATH)
    le_soil = joblib.load(SOIL_PATH)
    le_stage = joblib.load(STAGE_PATH)
    print("Models and encoders loaded successfully.")
except Exception as e:
    print(f"Error loading models: {e}")

class PredictionInput(BaseModel):
    temperature: float
    humidity: float
    co2: float
    light: float
    soil_moisture: float
    ph: float
    crop_type: str
    days_planted: int
    soil_type: str
    region: str
    growth_stage: str

@app.get("/")
def read_root():
    return {"status": "AgroPilot AI Prediction Backend is running"}

@app.post("/predict")
def predict(input_data: PredictionInput):
    try:
        # Encode categorical features
        # Note: If a label is not found in the encoder, we might need to handle it.
        # For now, we assume the input labels match the training labels.
        
        try:
            crop_encoded = le_crop.transform([input_data.crop_type])[0]
        except: crop_encoded = 0
            
        try:
            region_encoded = le_region.transform([input_data.region])[0]
        except: region_encoded = 0
            
        try:
            soil_encoded = le_soil.transform([input_data.soil_type])[0]
        except: soil_encoded = 0
            
        try:
            stage_encoded = le_stage.transform([input_data.growth_stage])[0]
        except: stage_encoded = 0

        # Prepare feature vector in the correct order
        # ['temperature' 'humidity' 'co2' 'light' 'soil_moisture' 'ph' 'crop_type' 'days_planted' 'soil_type' 'region' 'growth_stage']
        features = [
            input_data.temperature,
            input_data.humidity,
            input_data.co2,
            input_data.light,
            input_data.soil_moisture,
            input_data.ph,
            crop_encoded,
            input_data.days_planted,
            soil_encoded,
            region_encoded,
            stage_encoded
        ]

        df = pd.DataFrame([features], columns=[
            'temperature', 'humidity', 'co2', 'light', 'soil_moisture', 'ph', 
            'crop_type', 'days_planted', 'soil_type', 'region', 'growth_stage'
        ])

        prediction = model.predict(df)[0]
        
        # Mock SHAP values for now, or implement SHAP if requested
        # We can also calculate simple importance if the model supports it
        
        return {
            "prediction": float(prediction),
            "unit": "kg/m²",
            "features_used": features
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
