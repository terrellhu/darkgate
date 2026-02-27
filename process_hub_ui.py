import os
import glob
from PIL import Image

artifact_dir = r"C:\Users\hutao\.gemini\antigravity\brain\b20159a1-f73a-441d-9767-d8224346e25f"
out_dir = r"f:\code\godot\darkgate\assets\images\hub"

os.makedirs(out_dir, exist_ok=True)

def remove_bg(img, bg_color="black", tolerance=60):
    img = img.convert("RGBA")
    data = img.getdata()
    new_data = []
    
    if bg_color == "white":
        target = (255, 255, 255)
    else:
        target = (0, 0, 0)
        
    for item in data:
        dist = sum(abs(item[i] - target[i]) for i in range(3))
        if dist < tolerance:
            # Calculate alpha based on distance for smooth edge
            alpha = int((dist / tolerance) * 255)
            new_data.append((item[0], item[1], item[2], alpha))
        else:
            new_data.append(item)
    img.putdata(new_data)
    return img

targets = {
    "toast_production_bg": (512, 128, None),
    "toast_production_divider": (400, 8, "black"),
    "toast_production_frame": (512, 128, "black"),
    "divider_hub": (600, 16, "black"),
}

for base_name, (w, h, bg_remove) in targets.items():
    files = glob.glob(os.path.join(artifact_dir, f"{base_name}_*.png"))
    if not files:
        continue
    
    latest_file = max(files, key=os.path.getctime)
    out_name = f"{base_name}.png"
    print(f"Processing {latest_file} -> {out_name}")
    
    img = Image.open(latest_file)
    out = img.resize((w, h), Image.Resampling.LANCZOS)
    
    if bg_remove:
        out = remove_bg(out, bg_remove, 80)
    else:
        # Make the background texture semi-transparent
        out = out.convert("RGBA")
        data = out.getdata()
        new_data = [(r, g, b, min(220, a)) for r, g, b, a in data]
        out.putdata(new_data)

    out.save(os.path.join(out_dir, out_name))

print("Done")
