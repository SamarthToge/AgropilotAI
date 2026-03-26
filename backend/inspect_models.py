import joblib
import xgboost as xgb
import os

# Paths to the model files
model_path = 'Trained models/agropilot_xgboost.pkl'
crop_path = 'Trained models/encoder_crop.pkl'
region_path = 'Trained models/encoder_region.pkl'
soil_path = 'Trained models/encoder_soil.pkl'
stage_path = 'Trained models/encoder_stage.pkl'

def inspect():
    print("--- Inspecting Encoders ---")
    for name, path in [('Crop', crop_path), ('Region', region_path), ('Soil', soil_path), ('Stage', stage_path)]:
        try:
            le = joblib.load(path)
            print(f"{name} classes: {le.classes_}")
        except Exception as e:
            print(f"Error reading {name} encoder: {e}")

    print("\n--- Inspecting Model ---")
    try:
        model = joblib.load(model_path)
        print(f"Model type: {type(model)}")
        if hasattr(model, 'feature_names_in_'):
            print(f"Feature names in: {model.feature_names_in_}")
        elif hasattr(model, 'get_booster'):
            booster = model.get_booster()
            print(f"Feature names (booster): {booster.feature_names}")
    except Exception as e:
        print(f"Error reading model: {e}")

if __name__ == "__main__":
    inspect()
