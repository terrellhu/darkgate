import os
import glob
from PIL import Image

artifact_dir = r"C:\Users\hutao\.gemini\antigravity\brain\b20159a1-f73a-441d-9767-d8224346e25f"
out_dir = r"f:\code\godot\darkgate\assets\images\hub"

os.makedirs(out_dir, exist_ok=True)

img_targets = {
    "bg_hub": ("bg_hub.png", "none"),
    "facility_reactor": ("facility_reactor.png", "none"),
    "facility_recruit": ("facility_recruit.png", "none"),
    "facility_clinic": ("facility_clinic.png", "none"),
    "facility_market": ("facility_market.png", "none"),
    "facility_forge": ("facility_forge.png", "none"),
    "facility_data_lab": ("facility_data_lab.png", "none"),
    "icon_bio_electricity": ("icon_bio_electricity.png", "black_to_alpha"),
    "icon_nano_alloy": ("icon_nano_alloy.png", "black_to_alpha"),
    "icon_hashrate": ("icon_hashrate.png", "black_to_alpha"),
    "icon_mental_power": ("icon_mental_power.png", "black_to_alpha"),
    "nav_hub": ("nav_hub.png", "black_to_alpha"),
    "nav_team": ("nav_team.png", "black_to_alpha"),
    "nav_growth": ("nav_growth.png", "black_to_alpha"),
    "nav_expedition": ("nav_expedition.png", "black_to_alpha"),
    "nav_settings": ("nav_settings.png", "black_to_alpha"),
}

def black_to_alpha(img):
    img = img.convert("RGBA")
    gray = img.convert("L")
    pixels = img.load()
    alpha_data = gray.getdata()
    
    # Simple luminance to alpha approach
    new_data = []
    for point, alpha in zip(img.getdata(), alpha_data):
        new_data.append((point[0], point[1], point[2], alpha))
        
    img.putdata(new_data)
    return img

for prefix, (out_name, process_type) in img_targets.items():
    files = glob.glob(os.path.join(artifact_dir, f"{prefix}_*.png"))
    if not files:
        print(f"Skipping {prefix}, not found.")
        continue
    latest_file = max(files, key=os.path.getctime)
    print(f"Processing {latest_file} -> {out_name}")
    
    img = Image.open(latest_file)
    
    if process_type == "none":
        img.save(os.path.join(out_dir, out_name))
    elif process_type == "black_to_alpha":
        out = black_to_alpha(img)
        out.save(os.path.join(out_dir, out_name))

print("Done")
