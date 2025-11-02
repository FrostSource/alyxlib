import os
import re
import sys
import requests
from io import BytesIO
from PIL import Image, ImageDraw, ImageFont, ImageFilter

# ----- CONFIG -----
STEAM_API_URL = "https://api.steampowered.com/ISteamRemoteStorage/GetPublishedFileDetails/v1/"
OUTPUT_FOLDER = "docs/assets/workshop_cards"

# Base layout
BASE_CARD_WIDTH = round(600*1)
BASE_CARD_HEIGHT = round(190*1)
BASE_ICON_WIDTH = round(190*1)
BASE_PADDING = 15
MAX_DESC_CHARS = 200
CUTOFF_SYMBOLS = [".", "!", "?"]  # you can add/remove as needed
FONT_PATH = "fonts/FiraSans-Light.ttf"  # Replace with Roboto/Montserrat for better style
FONT_TITLE = "fonts/FiraSans-Regular.ttf"

# Theme colors
GRADIENT_COLOR = (30, 38, 50)   # dark bluish-green
OUTLINE_COLOR = (120, 200, 220) # bright tealish outline
SHADOW_COLOR = (0, 0, 0, 100)   # dark shadow for stats, separator, border

# Scaling factor
SCALE = 8

# Derived scaled sizes
CARD_WIDTH = round(BASE_CARD_WIDTH * SCALE)
CARD_HEIGHT = round(BASE_CARD_HEIGHT * SCALE)
ICON_WIDTH = round(BASE_ICON_WIDTH * SCALE)
PADDING = BASE_PADDING * SCALE

os.makedirs(OUTPUT_FOLDER, exist_ok=True)

# ----- HELPERS -----
def get_workshop_id(input_str):
    match = re.search(r'\d+', input_str)
    return match.group() if match else input_str

def fetch_workshop_data(workshop_id):
    payload = {"itemcount": 1, "publishedfileids[0]": workshop_id}
    response = requests.post(STEAM_API_URL, data=payload)
    data = response.json()
    try:
        item = data["response"]["publishedfiledetails"][0]
        return {
            "title": item.get("title", "Unknown Title"),
            "description": item.get("description", ""),
            "subscriptions": item.get("subscriptions", 0),
            "favorited": item.get("favorited", 0),
            "preview_url": item.get("preview_url")
        }
    except (KeyError, IndexError):
        print(f"Failed to fetch data for ID {workshop_id}")
        return None

def strip_bbcode(text):
    return re.sub(r'\[.*?\]', '', text)

def truncate_description(text):
    text = strip_bbcode(text)
    if len(text) > MAX_DESC_CHARS:
        cut = text[:MAX_DESC_CHARS]

        # find the *last* occurrence of any cutoff symbol
        best_cut = -1
        for sym in CUTOFF_SYMBOLS:
            idx = cut.rfind(sym)
            if idx > best_cut:
                best_cut = idx

        # only cut if symbol is decently far into the text
        if best_cut > 50:
            text = cut[:best_cut+1]
        else:
            text = cut + "..."
    return text

def wrap_text(draw, text, font, max_width):
    words = text.split()
    lines = []
    line = ""
    for word in words:
        test_line = f"{line} {word}".strip()
        bbox = draw.textbbox((0,0), test_line, font=font)
        w = bbox[2] - bbox[0]
        if w <= max_width:
            line = test_line
        else:
            lines.append(line)
            line = word
    if line:
        lines.append(line)
    return lines

# ----- CARD CREATION -----
def create_card(workshop_id, data):
    # High-res card
    card = Image.new("RGBA", (CARD_WIDTH, CARD_HEIGHT), GRADIENT_COLOR + (255,))
    draw = ImageDraw.Draw(card)

    # Subtle vertical gradient
    for i in range(CARD_HEIGHT):
        shade = int(GRADIENT_COLOR[0] + (i / CARD_HEIGHT) * 20)
        draw.line([(0,i),(CARD_WIDTH,i)], fill=(shade, GRADIENT_COLOR[1], GRADIENT_COLOR[2], 255))

    # Icon
    if data["preview_url"]:
        response = requests.get(data["preview_url"])
        icon = Image.open(BytesIO(response.content)).convert("RGBA")
        icon = icon.resize((ICON_WIDTH, CARD_HEIGHT))
        card.paste(icon, (0,0))

    # Vertical separator with shadow
    sep_width = 1 * SCALE
    sep_x = ICON_WIDTH
    sep_shadow = Image.new("RGBA", card.size, (0,0,0,0))
    sep_draw = ImageDraw.Draw(sep_shadow)
    shadow_width = 4 * SCALE
    for i in range(round(shadow_width)):
        alpha = int(SHADOW_COLOR[3] * (1 - i/shadow_width))
        sep_draw.line([(sep_x+i,0),(sep_x+i,CARD_HEIGHT)], fill=(0,0,0,alpha))
    sep_shadow = sep_shadow.filter(ImageFilter.GaussianBlur(1))
    card.alpha_composite(sep_shadow)
    # Draw the separator line itself using OUTLINE_COLOR
    draw.rectangle([sep_x,0,sep_x+sep_width,CARD_HEIGHT], fill=OUTLINE_COLOR + (255,))

    # Fonts
    try:
        title_font = ImageFont.truetype(FONT_TITLE, int(26*SCALE))
        body_font  = ImageFont.truetype(FONT_PATH, int(16*SCALE))
        stats_font = ImageFont.truetype(FONT_PATH, int(14*SCALE))
    except:
        title_font = ImageFont.load_default()
        body_font  = ImageFont.load_default()
        stats_font = ImageFont.load_default()

    x_text = ICON_WIDTH + sep_width + PADDING
    y_text = PADDING + 5 * SCALE
    max_width = CARD_WIDTH - ICON_WIDTH - sep_width - 2*PADDING

    # Title
    draw.text((x_text, y_text), data["title"], font=title_font, fill=(230,230,230))
    bbox = draw.textbbox((0,0), data["title"], font=title_font)
    line_height = bbox[3] - bbox[1]
    y_text += line_height + 12 * SCALE

    # Description
    desc = truncate_description(data["description"])
    lines = wrap_text(draw, desc, body_font, max_width)
    for line in lines:
        draw.text((x_text, y_text), line, font=body_font, fill=(180,180,180))
        bbox = draw.textbbox((0,0), line, font=body_font)
        line_height = bbox[3] - bbox[1]
        y_text += line_height + 6 * SCALE

    # Stats box (bottom-right) with shadow and colored outline
    stats_text = f"Subscriptions: {data['subscriptions']}  |  Favorites: {data['favorited']}"
    bbox = draw.textbbox((0,0), stats_text, font=stats_font)
    stats_w = bbox[2] - bbox[0]
    stats_h = bbox[3] - bbox[1]
    stats_padding = 8 * SCALE
    box_x0 = CARD_WIDTH - stats_w - stats_padding*2 - PADDING
    box_y0 = CARD_HEIGHT - stats_h - stats_padding*2 - PADDING
    box_x1 = CARD_WIDTH - PADDING
    box_y1 = CARD_HEIGHT - PADDING

    # Shadow behind stats (darker than outline)
    shadow = Image.new("RGBA", card.size, (0,0,0,0))
    shadow_draw = ImageDraw.Draw(shadow)
    shadow_draw.rectangle([box_x0+2,box_y0+2,box_x1+2,box_y1+2], fill=SHADOW_COLOR, width=round(SCALE))
    shadow = shadow.filter(ImageFilter.GaussianBlur(10))
    card.alpha_composite(shadow)

    # Stats background and outline
    draw.rectangle([box_x0, box_y0, box_x1, box_y1], fill=(20,20,20,255), outline=OUTLINE_COLOR + (255,), width=round(SCALE))
    draw.text((box_x0 + stats_padding, box_y0 + stats_padding), stats_text, font=stats_font, fill=(200,200,200))

    # Dark inner shadow border with brighter outline
    border_shadow_layer = Image.new("RGBA", card.size, (0,0,0,0))
    border_draw = ImageDraw.Draw(border_shadow_layer)
    border_width = 4 * SCALE
    for i in range(round(border_width)):
        alpha = int(50 * (1 - i/border_width))
        border_draw.line([(i,i),(CARD_WIDTH-1-i,i)], fill=SHADOW_COLOR[:3]+(alpha,))
        border_draw.line([(i,CARD_HEIGHT-1-i),(CARD_WIDTH-1-i,CARD_HEIGHT-1-i)], fill=SHADOW_COLOR[:3]+(alpha,))
        border_draw.line([(i,i),(i,CARD_HEIGHT-1-i)], fill=SHADOW_COLOR[:3]+(alpha,))
        border_draw.line([(CARD_WIDTH-1-i,i),(CARD_WIDTH-1-i,CARD_HEIGHT-1-i)], fill=SHADOW_COLOR[:3]+(alpha,))
    border_shadow_layer = border_shadow_layer.filter(ImageFilter.GaussianBlur(1))
    card.alpha_composite(border_shadow_layer)
    # Outline itself
    draw.rectangle([0,0,CARD_WIDTH-1,CARD_HEIGHT-1], outline=OUTLINE_COLOR + (180,), width=round(SCALE))

    # Downscale to final size
    final_card = card.resize((BASE_CARD_WIDTH, BASE_CARD_HEIGHT), resample=Image.Resampling.LANCZOS)
    # final_card = card

    # Save
    output_path = os.path.join(OUTPUT_FOLDER, f"{workshop_id}.png")
    final_card.save(output_path)
    print(f"Saved card for ID {workshop_id} -> {output_path}")

# ----- MAIN -----
def main():
    sys.argv.append("3329679071")
    sys.argv.append("3527754624")
    sys.argv.append("3144612716")
    sys.argv.append("3145397582")
    sys.argv.append("3329684800")
    sys.argv.append("2703180455")
    sys.argv.append("3426415080")
    sys.argv.append("3559284902")
    if len(sys.argv) > 1:
        inputs = sys.argv[1:]
    else:
        user_input = input("Enter Steam Workshop URLs or IDs (comma-separated): ")
        inputs = [x.strip() for x in user_input.split(",")]

    for item in inputs:
        workshop_id = get_workshop_id(item)
        data = fetch_workshop_data(workshop_id)
        if data:
            create_card(workshop_id, data)

if __name__ == "__main__":
    main()
