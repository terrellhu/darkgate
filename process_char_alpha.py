import os
import glob
from PIL import Image

artifact_dir = r"C:\Users\hutao\.gemini\antigravity\brain\b20159a1-f73a-441d-9767-d8224346e25f"
out_dir = r"f:\code\godot\darkgate\assets\images\characters"

os.makedirs(out_dir, exist_ok=True)

def remove_color_bg(img, bg_color="white", tolerance=50):
    img = img.convert("RGBA")
    data = img.getdata()
    new_data = []
    
    if bg_color == "white":
        target = (255, 255, 255)
    else:
        target = (0, 0, 0)
        
    for item in data:
        # Distance to target color
        dist = sum(abs(item[i] - target[i]) for i in range(3))
        if dist < tolerance:
            new_data.append((item[0], item[1], item[2], 0))
        else:
            new_data.append(item)
    img.putdata(new_data)
    return img

img_targets = [
    "char_assault_01",
    "char_berserker_01",
    "char_executioner_01",
    "char_plague_01",
    "char_psion_01",
    "char_shield_01"
]

for base_name in img_targets:
    for suffix in ["_avatar", "_full"]:
        prefix = base_name + suffix
        out_name = prefix + ".png"
        
        files = glob.glob(os.path.join(artifact_dir, f"{prefix}_*.png"))
        if not files:
            print(f"Skipping {prefix}, not found.")
            continue
        latest_file = max(files, key=os.path.getctime)
        print(f"Processing {latest_file} -> {out_name}")
        
        img = Image.open(latest_file)
        out = remove_color_bg(img, "white", 60)
        out.save(os.path.join(out_dir, out_name))

print("Done")
