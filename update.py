#!/usr/bin/env python3
import json
import sys

def convert_theme(input_file, output_file):
    # Read the input JSON file
    with open(input_file, 'r') as f:
        data = json.load(f)
    
    converted_themes = []
    
    # Process each theme in the input data
    for theme in data:
        theme_name = theme.get("name", "")
        if not theme_name:
            continue
        
        # Add variant to theme name if it exists
        variant = theme.get("variant", "")
        if variant:
            theme_name = f"{theme_name} {variant}"
            
        converted_theme = {}
        
        # Convert color_XX to palette = X (starting from 0)
        # Handle both color_01 (Gogh format) and color0 (0-indexed format)
        for i in range(16):
            # Try different possible color key formats
            color_formats = [
                f"color_{i+1:02d}",  # color_01, color_02, etc. (Gogh format, 1-indexed)
                f"color_{i:02d}",    # color_00, color_01, etc.
                f"color_{i}",        # color_0, color_1, etc.
                f"color{i:02d}",     # color00, color01, etc.
                f"color{i}",         # color0, color1, etc.
            ]
            
            for color_format in color_formats:
                if color_format in theme:
                    converted_theme[f"palette = {i}"] = theme[color_format]
                    break
        
        # Add other properties with the specific format
        if "background" in theme:
            converted_theme["background"] = f"background = {theme['background']}"
        
        if "foreground" in theme:
            converted_theme["foreground"] = f"foreground = {theme['foreground']}"
        
        if "cursor" in theme:
            converted_theme["cursor-color"] = f"cursor-color = {theme['cursor']}"
        
        # Add to the converted themes list
        converted_themes.append({theme_name: converted_theme})
    
    # Write the converted data to output file
    with open(output_file, 'w') as f:
        json.dump(converted_themes, f, indent=2)
    
    print(f"    Update Done: {len(converted_themes)} themes.")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python convert.py input.json output.json")
        sys.exit(1)
    
    input_file = "sys.argv[1]"
    output_file = sys.argv[2]
    
    convert_theme(input_file, output_file)