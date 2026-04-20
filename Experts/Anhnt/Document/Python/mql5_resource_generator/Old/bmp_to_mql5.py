"""
BMP to MQL5 Resource Converter
--------------------------------
- Scans all .bmp files in the specified folder
- Converts each BMP to uint[] ARGB pixel array
- Outputs result.txt next to this script
"""

from PIL import Image
import os

# ============================================================
# CONFIG - Change this to your BMP folder path
# ============================================================
FOLDER_PATH = r"E:\Temp\Image to uInt"
# ============================================================

def bmp_to_uint_array(filepath):
    img = Image.open(filepath).convert("RGBA")
    width, height = img.size
    pixels = list(img.getdata())
    uint_array = []
    for r, g, b, a in pixels:
        argb = (a << 24) | (r << 16) | (g << 8) | b
        uint_array.append(argb)
    return width, height, uint_array

def format_uint_array(uint_array, pixels_per_line=20):
    lines = []
    for i in range(0, len(uint_array), pixels_per_line):
        chunk = uint_array[i:i + pixels_per_line]
        lines.append(",".join(str(v) for v in chunk) + ",")
    return "\n    ".join(lines)

def to_var_name(filename):
    name = os.path.splitext(filename)[0]
    name = name.lower()
    name = name.replace("-", "_").replace(" ", "_")
    return name

def main():
    if not os.path.isdir(FOLDER_PATH):
        print(f"ERROR: Folder not found: {FOLDER_PATH}")
        input("Press Enter to exit...")
        return

    bmp_files = sorted([f for f in os.listdir(FOLDER_PATH) if f.lower().endswith(".bmp")])

    if not bmp_files:
        print("No .bmp files found in folder.")
        input("Press Enter to exit...")
        return

    # Output file: same folder as this script
    output_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "result.txt")

    print(f"Found {len(bmp_files)} BMP file(s)")
    print(f"Saving to: {output_path}")

    with open(output_path, "w", encoding="utf-8") as out:
        for filename in bmp_files:
            filepath = os.path.join(FOLDER_PATH, filename)
            var_name = to_var_name(filename)
            try:
                width, height, uint_array = bmp_to_uint_array(filepath)
                out.write(f"    // --- {filename} ({width}x{height}) ---\n")
                out.write(f"    uint {var_name}[] = {{\n")
                out.write(f"    {format_uint_array(uint_array)}\n")
                out.write(f"    }};\n")
                out.write(f"    SetData(RESOURCE_{var_name.upper()}, \"{var_name}\", {width}, {height}, {var_name});\n")
                out.write("\n")
                print(f"  OK: {filename} ({width}x{height})")
            except Exception as e:
                out.write(f"    // ERROR processing {filename}: {e}\n\n")
                print(f"  ERROR: {filename} -> {e}")

    print(f"\nDone! Open result.txt in the same folder as this script.")
    input("Press Enter to exit...")

if __name__ == "__main__":
    main()
