import os
import glob
from PIL import Image, ImageOps

artifact_dir = r"C:\Users\hutao\.gemini\antigravity\brain\b20159a1-f73a-441d-9767-d8224346e25f"
out_dir = r"f:\code\godot\darkgate\assets\images\menu"

os.makedirs(out_dir, exist_ok=True)

# Map prefix to output filename
img_targets = {
    "bg_main_image": ("bg_main.png", "none"),
    "char_main_image": ("char_main.png", "remove_white"),
    "title_glow_img": ("title_glow.png", "black_to_alpha"),
    "divider_ornament": ("divider_ornament.png", "black_to_alpha"),
    "btn_normal_img": ("btn_normal.png", "black_to_alpha_corners"),
    "btn_pressed_img": ("btn_pressed.png", "black_to_alpha_corners")
}

def remove_color_bg(img, bg_color="white", tolerance=30):
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

def black_to_alpha(img):
    img = img.convert("RGBA")
    # Use luminance as alpha
    gray = img.convert("L")
    img.putalpha(gray)
    return img

for prefix, (out_name, process_type) in img_targets.items():
    files = glob.glob(os.path.join(artifact_dir, f"{prefix}_*.png"))
    if not files:
        print(f"Skipping {prefix}, not found.")
        continue
    # take the latest
    latest_file = max(files, key=os.path.getctime)
    print(f"Processing {latest_file} -> {out_name}")
    
    img = Image.open(latest_file)
    
    if process_type == "none":
        img.save(os.path.join(out_dir, out_name))
    elif process_type == "remove_white":
        out = remove_color_bg(img, "white", 50)
        out.save(os.path.join(out_dir, out_name))
    elif process_type == "black_to_alpha":
        out = black_to_alpha(img)
        out.save(os.path.join(out_dir, out_name))
    elif process_type == "black_to_alpha_corners":
        out = remove_color_bg(img, "black", 15)
        out.save(os.path.join(out_dir, out_name))

print("Done")
