from PIL import Image, ImageDraw, ImageFont
import math

def create_splash_screen():
    # Create a transparent background
    size = (512, 512)
    image = Image.new('RGBA', size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)
    
    # Calculate center and sizes
    center = (size[0] // 2, size[1] // 2)
    tomato_radius = 200
    
    # Draw the tomato body (slightly elongated circle)
    tomato_bounds = [
        center[0] - tomato_radius,
        center[1] - tomato_radius * 1.05,  # Slightly taller
        center[0] + tomato_radius,
        center[1] + tomato_radius * 1.05
    ]
    draw.ellipse(tomato_bounds, fill='#FF4136')  # Bright red for tomato
    
    # Draw clock face (white circle)
    clock_radius = tomato_radius * 0.8
    clock_bounds = [
        center[0] - clock_radius,
        center[1] - clock_radius,
        center[0] + clock_radius,
        center[1] + clock_radius
    ]
    draw.ellipse(clock_bounds, fill='white')
    
    # Draw tomato stem and leaf
    stem_start = (center[0], center[1] - tomato_radius * 1.05)
    stem_control1 = (center[0], stem_start[1] - 30)
    stem_end = (center[0], stem_start[1] - 40)
    
    # Draw stem
    draw.line([stem_start, stem_end], fill='#2E7D32', width=15)  # Dark green
    
    # Draw leaf
    leaf_points = [
        (center[0], stem_start[1] - 20),  # Base of leaf
        (center[0] + 60, stem_start[1] - 50),  # Tip of leaf
        (center[0] + 30, stem_start[1] - 20),  # Bottom curve
    ]
    draw.polygon(leaf_points, fill='#4CAF50')  # Lighter green
    
    # Draw clock numbers
    clock_numbers = list(range(1, 11))  # 1 to 10
    radius_text = clock_radius * 0.8
    font_size = 40
    try:
        font = ImageFont.truetype("Arial Bold", font_size)
    except:
        font = ImageFont.load_default()
    
    # Draw numbers
    for i, num in enumerate(clock_numbers):
        angle = math.radians(270 + i * 36)  # Start from top (270 degrees) and go clockwise
        x = center[0] + radius_text * math.cos(angle)
        y = center[1] + radius_text * math.sin(angle)
        # Get text size for centering
        text = str(num)
        bbox = draw.textbbox((0, 0), text, font=font)
        text_width = bbox[2] - bbox[0]
        text_height = bbox[3] - bbox[1]
        draw.text((x - text_width/2, y - text_height/2), text, font=font, fill='black')
    
    # Draw clock hands
    # Hour hand (pointing to 7)
    hour_angle = math.radians(210)  # 7 o'clock
    hour_length = clock_radius * 0.5
    hour_end = (
        center[0] + hour_length * math.cos(hour_angle),
        center[1] + hour_length * math.sin(hour_angle)
    )
    draw.line([center, hour_end], fill='black', width=8)
    
    # Save the images
    image.save('assets/splash.png')
    
    # Create a copy for branding with transparent background
    branding = Image.new('RGBA', (800, 200), (0, 0, 0, 0))
    draw_branding = ImageDraw.Draw(branding)
    text = "Pomo Timer"
    try:
        font_branding = ImageFont.truetype("Arial Bold", 96)
    except:
        font_branding = ImageFont.load_default()
    
    text_bbox = draw_branding.textbbox((0, 0), text, font=font_branding)
    text_width = text_bbox[2] - text_bbox[0]
    text_x = (800 - text_width) // 2
    draw_branding.text((text_x, 50), text, font=font_branding, fill='#FF4136')  # Match tomato color
    branding.save('assets/branding.png')

if __name__ == '__main__':
    create_splash_screen() 