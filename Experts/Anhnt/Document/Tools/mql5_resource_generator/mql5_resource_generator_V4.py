import os
import struct

SOURCE_DIR = r'D:\MT5-Dev\Temp\19073 Images'
DEST_FILE  = r'D:\MT5-Dev\Temp\Dest\ImageResources.mqh'

def get_var_name(root_dir, file_path):
    rel = os.path.relpath(file_path, root_dir)
    name = rel.replace(os.sep, "_").replace(".", "_").replace(" ", "_")
    return name.lower()

def get_enum_name(var_name):
    return f"IMAGE_RESOURCE_{var_name.upper()}"

def image_to_argb_array(file_path):
    """
    Đọc file BMP và convert sang ARGB array cho MQL5.

    Rules (verified against Resources.mqh gốc của library 19703):
      - BMP 32-bit: đọc raw BGRA bytes (Pillow swap kênh sai)
        + alpha == 0  → 0x00FFFFFF  (background transparent, RGB=white)
        + alpha > 0   → 0xFF_RR_GG_BB  (ép alpha=255, bỏ semi-transparency)
      - BMP 24-bit: dùng Pillow + transparent color detection (pixel góc dưới-trái)
        + transparent → 0x00FFFFFF
        + opaque      → 0xFF_RR_GG_BB
    """
    with open(file_path, 'rb') as f:
        data = f.read()

    bit_count = struct.unpack_from('<H', data, 28)[0]
    offset    = struct.unpack_from('<I', data, 10)[0]
    w         = struct.unpack_from('<i', data, 18)[0]
    h         = struct.unpack_from('<i', data, 22)[0]
    h_abs     = abs(h)

    if bit_count == 32:
        # Đọc raw BGRA — KHÔNG dùng Pillow vì nó swap kênh sai
        pixels_raw = data[offset:]
        argb_values = []
        for i in range(0, w * h_abs * 4, 4):
            b = pixels_raw[i]
            g = pixels_raw[i + 1]
            r = pixels_raw[i + 2]
            a = pixels_raw[i + 3]
            if a == 0:
                val = 0x00FFFFFF  # background transparent
            else:
                val = (0xFF << 24) | (r << 16) | (g << 8) | b  # ép alpha=255
            argb_values.append(val)

        # BMP lưu upside-down khi h > 0
        if h > 0:
            rows = [argb_values[row * w:(row + 1) * w] for row in range(h_abs)]
            rows.reverse()
            argb_values = [v for row in rows for v in row]

        return w, h_abs, argb_values

    else:
        # BMP 24-bit: dùng Pillow + transparent color detection
        from PIL import Image
        img_rgb = Image.open(file_path).convert("RGB")
        wp, hp = img_rgb.size
        transparent_color = img_rgb.getpixel((0, hp - 1))
        pixels = list(img_rgb.getdata())
        argb = []
        for (r, g, b) in pixels:
            if (r, g, b) == transparent_color:
                argb.append(0x00FFFFFF)
            else:
                argb.append((0xFF << 24) | (r << 16) | (g << 8) | b)
        return wp, hp, argb

def generate_resources():
    all_files = []
    for root, _, files in os.walk(SOURCE_DIR):
        for filename in sorted(files):
            if filename.lower().endswith(('.bmp', '.png', '.jpg')):
                full_path = os.path.join(root, filename)
                var_name  = get_var_name(SOURCE_DIR, full_path)
                enum_name = get_enum_name(var_name)
                all_files.append({
                    'full_path': full_path,
                    'var_name':  var_name,
                    'enum_name': enum_name
                })

    if not all_files:
        print("No image files found!")
        return

    dest_dir = os.path.dirname(DEST_FILE)
    if dest_dir:
        os.makedirs(dest_dir, exist_ok=True)

    with open(DEST_FILE, 'w', encoding='utf-8') as f:
        f.write("//+------------------------------------------------------------------+\n")
        f.write("//|                                           ImageResources.mqh     |\n")
        f.write("//|                         Generated for EasyAndFastGUI 19703       |\n")
        f.write("//+------------------------------------------------------------------+\n")
        f.write("#ifndef __IMAGERESOURCES_MQH__\n")
        f.write("#define __IMAGERESOURCES_MQH__\n\n")

        # 1. #define block
        f.write("// Generated for EasyAndFastGUI - Image Resources\n")
        for i, entry in enumerate(all_files):
            f.write(f"    #define {entry['enum_name']} (uint){i}\n")
        f.write("\n")

        # 2. struct SImage
        f.write("  struct SImage\n")
        f.write("    {\n")
        f.write("        string name;\n")
        f.write("        uint width;\n")
        f.write("        uint height;\n")
        f.write("        uint data[];\n")
        f.write("    };\n\n")

        # 3. Class declaration
        f.write(" class CImageResources\n")
        f.write(" {\n")
        f.write("    protected:\n")
        f.write("    SImage images[];\n")
        f.write("  public:\n")
        f.write("  // --- Constructors/destructor\n")
        f.write("        CImageResources(void);\n")
        f.write("        ~CImageResources(void);\n")
        f.write("    int Total(void) { return(ArraySize(images)); }\n")
        f.write("    void SetData(const uint index, const string name, const uint width, const uint height, uint &data[]);\n")
        f.write("    string GetData(const uint index, uint &image_data[], uint &image_width, uint &image_height);\n")

        # 4. Resource access method declarations
        f.write("  //--- Resource access methods\n")
        for entry in all_files:
            f.write(f"    void {entry['var_name']}(uint &image_data[], uint &image_width, uint &image_height);\n")
        f.write("};\n\n")

        f.write("#ifndef CIMAGERESOURCES_IMPLEMENTATION\n")
        f.write("#define CIMAGERESOURCES_IMPLEMENTATION\n\n")

        # 5. Destructor
        f.write(" CImageResources::~CImageResources(void)\n")
        f.write("  {\n")
        f.write("  }\n\n")

        # 6. SetData
        f.write(" void CImageResources::SetData(const uint index, const string name, const uint width, const uint height, uint &data[])\n")
        f.write("  {\n")
        f.write("   if((int)index >= ArraySize(images)) ArrayResize(images, (int)index+1);\n")
        f.write("   images[index].name   = name;\n")
        f.write("   images[index].width  = width;\n")
        f.write("   images[index].height = height;\n")
        f.write("   ArrayCopy(images[index].data, data);\n")
        f.write("  }\n\n")

        # 7. GetData
        f.write(" string CImageResources::GetData(const uint index, uint &image_data[], uint &image_width, uint &image_height)\n")
        f.write(" {\n")
        f.write("   if((int)index >= ArraySize(images))\n")
        f.write("    {\n")
        f.write("      Print(__FUNCTION__,\" > Preventing out-of-bounds array!\");\n")
        f.write("      return(\"\");\n")
        f.write("    }\n")
        f.write("   ArrayFree(image_data);\n")
        f.write("   image_width  = images[index].width;\n")
        f.write("   image_height = images[index].height;\n")
        f.write("   ArrayCopy(image_data, images[index].data);\n")
        f.write("   return(images[index].name);\n")
        f.write(" }\n\n")

        # 8. Constructor
        f.write(" //+------------------------------------------------------------------+\n")
        f.write(" //| Class Constructor - Digitized Data Initialization                |\n")
        f.write(" //+------------------------------------------------------------------+\n")
        f.write(" CImageResources::CImageResources(void)\n")
        f.write("  {\n")
        f.write(f"    ArrayResize(images, {len(all_files)});\n\n")

        errors = []
        for entry in all_files:
            print(f"Processing: {entry['var_name']}")
            try:
                w, h, argb = image_to_argb_array(entry['full_path'])
                print(f"  -> {w}x{h}, {len(argb)} pixels")
            except Exception as e:
                print(f"  ERROR: {e}")
                errors.append(entry['var_name'])
                continue

            f.write(f"    uint {entry['var_name']}[] = {{\n")
            for i in range(0, len(argb), 20):
                line = "    " + ",".join(str(v) for v in argb[i:i+20])
                f.write(line + (",\n" if i + 20 < len(argb) else "\n"))
            f.write("    };\n")
            f.write(f'    SetData({entry["enum_name"]}, "{entry["var_name"]}", {w}, {h}, {entry["var_name"]});\n\n')

        f.write("  }\n\n")

        # 9. Resource access method implementations
        for entry in all_files:
            if entry['var_name'] in errors:
                continue
            f.write(f" void CImageResources::{entry['var_name']}(uint &image_data[], uint &image_width, uint &image_height)\n")
            f.write("  {\n")
            f.write(f"   GetData({entry['enum_name']}, image_data, image_width, image_height);\n")
            f.write("  }\n\n")

        f.write("#endif // CIMAGERESOURCES_IMPLEMENTATION\n")
        f.write("#endif // __IMAGERESOURCES_MQH__\n")

    print(f"\nDone! Saved to: {DEST_FILE}")
    print(f"Total images processed: {len(all_files) - len(errors)}")
    if errors:
        print(f"Errors ({len(errors)}): {errors}")

if __name__ == "__main__":
    generate_resources()