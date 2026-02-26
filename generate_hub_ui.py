import os
from PIL import Image, ImageDraw, ImageFilter

out_dir = r"f:\code\godot\darkgate\assets\images\hub"
os.makedirs(out_dir, exist_ok=True)

def generate_overlay_locked():
    w, h = 480, 120
    img = Image.new('RGBA', (w, h), (15, 10, 20, 200)) # Dark semi-transparent
    draw = ImageDraw.Draw(img)
    
    # Subtle red warning top and bottom borders
    draw.rectangle([0, 0, w, 2], fill=(183, 18, 18, 150))
    draw.rectangle([0, h-3, w, h], fill=(183, 18, 18, 150))
    
    # Add a glitch line effect
    for y in range(0, h, 4):
        draw.line([(0, y), (w, y)], fill=(0, 0, 0, 40), width=1)
        
    img.save(os.path.join(out_dir, "overlay_locked.png"))
    print("Generated overlay_locked.png")

def generate_overlay_unbuilt():
    w, h = 480, 120
    img = Image.new('RGBA', (w, h), (10, 10, 15, 100)) # Very faint dark
    draw = ImageDraw.Draw(img)
    
    # Cyan wireframe grid
    cyan = (0, 200, 255, 100)
    grid_size = 20
    
    for x in range(0, w, grid_size):
        draw.line([(x, 0), (x, h)], fill=cyan, width=1)
    for y in range(0, h, grid_size):
        draw.line([(0, y), (w, y)], fill=cyan, width=1)
        
    # Wireframe box layout
    draw.rectangle([20, 20, w-20, h-20], outline=cyan, width=2)
    # Add some dotted accents 
    for x in range(25, 100, 10):
        draw.rectangle([x, 25, x+5, 30], fill=cyan)
        
    img.save(os.path.join(out_dir, "overlay_unbuilt.png"))
    print("Generated overlay_unbuilt.png")

def generate_card_frame():
    # 480x120 frame, 9-patch sliceable
    w, h = 480, 120
    img = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Inner dark translucent area - leave center empty if purely a frame, or add a faint fill
    # Actually, as a card frame, it shouldn't fill the center so the background image shows through, 
    # but the prompt says "dark semi-transparent interior". Let's add it.
    draw.rectangle([2, 2, w-3, h-3], fill=(15, 10, 20, 80))
    
    red_glow = (217, 31, 31, 200) # #D91F1F
    red_bright = (255, 100, 100, 255)
    
    # Border
    draw.rectangle([0, 0, w-1, h-1], outline=red_glow, width=1)
    
    # Corner treatments (Top Left, Top Right, Bottom Left, Bottom Right)
    corner_length = 20
    thick = 3
    # TL
    draw.line([(0, 0), (corner_length, 0)], fill=red_bright, width=thick)
    draw.line([(0, 0), (0, corner_length)], fill=red_bright, width=thick)
    # TR
    draw.line([(w-1-corner_length, 0), (w-1, 0)], fill=red_bright, width=thick)
    draw.line([(w-1, 0), (w-1, corner_length)], fill=red_bright, width=thick)
    # BL
    draw.line([(0, h-1), (corner_length, h-1)], fill=red_bright, width=thick)
    draw.line([(0, h-1), (0, h-1-corner_length)], fill=red_bright, width=thick)
    # BR
    draw.line([(w-1-corner_length, h-1), (w-1, h-1)], fill=red_bright, width=thick)
    draw.line([(w-1, h-1), (w-1, h-1-corner_length)], fill=red_bright, width=thick)

    # Some tech nodes on horizontal borders
    draw.rectangle([w//2 - 20, 0, w//2 + 20, 3], fill=red_bright)
    draw.rectangle([w//2 - 20, h-4, w//2 + 20, h-1], fill=red_bright)
    
    img.save(os.path.join(out_dir, "card_frame.png"))
    print("Generated card_frame.png")

def generate_divider_hub():
    w, h = 600, 16
    img = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # We want a neon red line fading to transparent
    # Best way is drawing from center out with varying alpha
    cx, cy = w//2, h//2
    
    for x in range(w):
        # Calculate distance from center (0 to 1)
        dist = abs(x - cx) / float(cx)
        # Alpha from 255 at center to 0 at edges
        alpha = int(255 * (1.0 - dist))
        if alpha < 0: alpha = 0
        
        # Draw central line
        draw.point((x, cy), fill=(217, 31, 31, alpha))
        if alpha > 100:
            draw.point((x, cy-1), fill=(183, 18, 18, alpha//2))
            draw.point((x, cy+1), fill=(183, 18, 18, alpha//2))
            
    # Center circuit board pattern
    draw.rectangle([cx - 10, cy - 3, cx + 10, cy + 3], fill=(0, 0, 0, 255), outline=(217, 31, 31, 255), width=1)
    draw.point((cx - 5, cy), fill=(255, 100, 100, 255))
    draw.point((cx + 5, cy), fill=(255, 100, 100, 255))
    
    img.save(os.path.join(out_dir, "divider_hub.png"))
    print("Generated divider_hub.png")

def generate_vignette():
    w, h = 1080, 1920
    # Downscale generation for speed, then upscale
    sw, sh = w // 4, h // 4
    img = Image.new('RGBA', (sw, sh), (0, 0, 0, 0))
    
    # We don't have a simple radial gradient in Pillow Draw, so we calculate pixel by pixel
    pixels = img.load()
    cx, cy = sw / 2, sh / 2
    max_dist = (cx**2 + cy**2)**0.5
    
    for x in range(sw):
        for y in range(sh):
            # Elliptical distance
            dx = (x - cx) / cx
            dy = (y - cy) / cy
            dist = (dx*dx + dy*dy)**0.5
            
            # Non-linear alpha scaling
            if dist < 0.5:
                alpha = 0
            else:
                alpha = int(255 * ((dist - 0.5) / 0.5) ** 2)
            
            if alpha > 255: alpha = 255
            pixels[x, y] = (5, 0, 10, alpha) # Dark purple tint
            
    img = img.resize((w, h), Image.Resampling.LANCZOS)
    img.save(os.path.join(out_dir, "vignette_overlay.png"))
    print("Generated vignette_overlay.png")

if __name__ == "__main__":
    generate_overlay_locked()
    generate_overlay_unbuilt()
    generate_card_frame()
    generate_divider_hub()
    generate_vignette()
