import os
import glob
from PIL import Image

artifact_dir = r"C:\Users\hutao\.gemini\antigravity\brain\926de741-7be9-44b3-89b9-c504fecd5737"
out_dir = r"f:\code\godot\darkgate\assets\images\team"

os.makedirs(out_dir, exist_ok=True)

img_targets = {
    "team_bg": ("team_bg.png", "resize_720x1280", (720, 1280)),
    "detail_bg": ("detail_bg.png", "resize_720x1280", (720, 1280)),
    "card_slot_bg": ("card_slot_bg.png", "remove_black_and_resize", (640, 100)),
    "detail_info_panel": ("detail_info_panel.png", "remove_black_and_resize", (680, 500)),
    "tab_bg_inactive": ("tab_bg_inactive.png", "remove_black_and_resize", (200, 48)),
    "btn_back": ("btn_back.png", "remove_black_and_resize", (48, 48)),
    "card_slot_empty": ("card_slot_empty.png", "remove_black_and_resize", (640, 100)),
    "equip_slot_bg": ("equip_slot_bg.png", "remove_black_and_resize", (80, 80)),
    "rarity_frame_r": ("rarity_frame_r.png", "remove_black_and_resize_cutout", (100, 100)),
    "rarity_frame_sr": ("rarity_frame_sr.png", "remove_black_and_resize_cutout", (100, 100)),
    "rarity_frame_ssr": ("rarity_frame_ssr.png", "remove_black_and_resize_cutout", (100, 100)),
    "tab_bg_active": ("tab_bg_active.png", "remove_black_and_resize", (200, 48))
}

def remove_color_bg(img, target_color=(0, 0, 0), tolerance=15, cutout=False):
    img = img.convert("RGBA")
    data = img.getdata()
    new_data = []
    
    for item in data:
        dist = sum(abs(item[i] - target_color[i]) for i in range(3))
        if dist < tolerance:
            new_data.append((item[0], item[1], item[2], 0))
        else:
            new_data.append(item)
            
    img.putdata(new_data)
    
    if cutout:
        # Create a circle or square cutout for rarity frames
        # The prompt says 84x84 cutout for 100x100 frame
        # We'll just force clear the middle 80x80 pixels to be safe
        offset = (img.width - 80) // 2
        for x in range(offset, offset + 80):
            for y in range(offset, offset + 80):
                img.putpixel((x, y), (0, 0, 0, 0))
                
    return img

def resize_crop(img, target_size):
    target_ratio = target_size[0] / target_size[1]
    img_ratio = img.width / img.height
    if img_ratio > target_ratio:
        new_width = int(img.height * target_ratio)
        left = (img.width - new_width) // 2
        img = img.crop((left, 0, left + new_width, img.height))
    else:
        new_height = int(img.width / target_ratio)
        top = (img.height - new_height) // 2
        img = img.crop((0, top, img.width, top + new_height))
        
    img = img.resize(target_size, Image.Resampling.LANCZOS)
    return img

for prefix, (out_name, process_type, size) in img_targets.items():
    # Handle the "new" and "final" suffixes I added during retries
    files = glob.glob(os.path.join(artifact_dir, f"{prefix}_*.png"))
    if not files:
        print(f"Skipping {prefix}, not found.")
        continue
    # take the latest
    latest_file = max(files, key=os.path.getctime)
    print(f"Processing {latest_file} -> {out_name}")
    
    img = Image.open(latest_file)
    
    if process_type == "resize_720x1280":
        img = resize_crop(img, size)
        img.save(os.path.join(out_dir, out_name))
    elif process_type == "remove_black_and_resize":
        img = resize_crop(img, size)
        out = remove_color_bg(img, (0,0,0), 30)
        out.save(os.path.join(out_dir, out_name))
    elif process_type == "remove_black_and_resize_cutout":
        img = resize_crop(img, size)
        out = remove_color_bg(img, (0,0,0), 30, cutout=True)
        out.save(os.path.join(out_dir, out_name))

print("Done")
