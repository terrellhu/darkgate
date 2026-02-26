import os
from PIL import Image, ImageDraw, ImageFilter

out_dir = r"f:\code\godot\darkgate\assets\images\menu"
os.makedirs(out_dir, exist_ok=True)

def draw_hexagons(draw, w, h, color):
    # Draw faint hex pattern
    size = 10
    import math
    for x in range(0, w, int(size * 1.5)):
        for y in range(0, h, int(size * math.sqrt(3))):
            offset_y = (x // int(size * 1.5)) % 2 * (size * math.sqrt(3)) / 2
            # Calculate hex points
            cy = y + offset_y
            cx = x
            points = []
            for i in range(6):
                angle_deg = 60 * i
                angle_rad = math.pi / 180 * angle_deg
                px = cx + size * math.cos(angle_rad)
                py = cy + size * math.sin(angle_rad)
                points.append((px, py))
            draw.polygon(points, outline=color)

def generate_button(filename, size, base_color, border_color, border_width, hex_color, corner_radius=2):
    w, h = size
    # x3 supersampling for anti-aliasing
    sw, sh = w * 3, h * 3
    img = Image.new('RGBA', (sw, sh), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Parse colors properly to RGBA
    # Base drawing
    rect_box = [border_width*3, border_width*3, sw-1-border_width*3, sh-1-border_width*3]
    draw.rounded_rectangle(rect_box, radius=corner_radius*3, fill=base_color)

    # Add hex pattern
    hex_img = Image.new('RGBA', (sw, sh), (0,0,0,0))
    hex_draw = ImageDraw.Draw(hex_img)
    draw_hexagons(hex_draw, sw, sh, hex_color)
    img = Image.alpha_composite(img, hex_img)
    draw = ImageDraw.Draw(img)
    
    # Draw border
    draw.rounded_rectangle(rect_box, radius=corner_radius*3, outline=border_color, width=border_width*3)
    
    # Draw tech corners
    deco_len = 12 * 3
    dw = 3 * 3
    # Top-left
    draw.line([(0, deco_len), (0, 0), (deco_len, 0)], fill=border_color, width=dw)
    # Top-right
    draw.line([(sw-1-deco_len, 0), (sw-1, 0), (sw-1, deco_len)], fill=border_color, width=dw)
    # Bottom-left
    draw.line([(0, sh-1-deco_len), (0, sh-1), (deco_len, sh-1)], fill=border_color, width=dw)
    # Bottom-right
    draw.line([(sw-1-deco_len, sh-1), (sw-1, sh-1), (sw-1, sh-1-deco_len)], fill=border_color, width=dw)
    
    # Downscale
    img = img.resize((w, h), Image.Resampling.LANCZOS)
    img.save(os.path.join(out_dir, filename))
    print(f"Generated {filename}")

# Normal State
generate_button("btn_normal.png", (624, 64), 
                base_color="#14141E", 
                border_color="#A61414", 
                border_width=1,
                hex_color=(255, 255, 255, 5))

# Pressed State (brighter, red tint, thicker corners/border)
generate_button("btn_pressed.png", (624, 64), 
                base_color="#2E0A0A", 
                border_color="#F23333", 
                border_width=2,
                hex_color=(242, 51, 51, 20))
