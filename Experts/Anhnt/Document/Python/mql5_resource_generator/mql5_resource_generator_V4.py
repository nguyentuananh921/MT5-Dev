import os
from PIL import Image

SOURCE_DIR = r'D:\AppData\Download\19073 Images\EasyAndFastGUI'
DEST_FILE  = r'D:\AppData\Download\Dest\ImageResources.mqh'

def get_var_name(root_dir, file_path):
    """
    Build var_name from relative path, e.g.:
      Controls\ArrowDown.bmp  ->  controls_arrowdown_bmp
      Icons\Bmp16\advisor.bmp ->  icons_bmp16_advisor_bmp
    Includes folder(s) + filename + extension, all lowercase,
    with separators and dots replaced by underscores.
    """
    rel = os.path.relpath(file_path, root_dir)
    name = rel.replace(os.sep, "_").replace(".", "_").replace(" ", "_")
    return name.lower()

def get_enum_name(var_name):
    """
    e.g. controls_arrowdown_bmp  ->  IMAGE_RESOURCE_CONTROLS_ARROWDOWN_BMP
    """
    return f"IMAGE_RESOURCE_{var_name.upper()}"

def get_bmp_transparent_color(file_path):
    """
    BMP files store the transparent color as the color of the bottom-left pixel.
    This is a common convention used in MQL5/MetaTrader icon sets.
    """
    try:
        img = Image.open(file_path).convert("RGB")
        w, h = img.size
        return img.getpixel((0, h - 1))
    except Exception:
        return None

def image_to_argb_array(file_path):
    img = Image.open(file_path)
    original_mode = img.mode

    if original_mode in ('RGB', 'P'):
        transparent_color = get_bmp_transparent_color(file_path)
        img = img.convert("RGBA")
        pixels = list(img.getdata())
        new_pixels = []
        for (r, g, b, a) in pixels:
            if transparent_color and (r, g, b) == transparent_color:
                new_pixels.append((0, 0, 0, 0))
            else:
                new_pixels.append((r, g, b, 255))
        img.putdata(new_pixels)
    else:
        img = img.convert("RGBA")

    w, h = img.size
    pixels = list(img.getdata())
    argb = []
    for (r, g, b, a) in pixels:
        val = (a << 24) | (r << 16) | (g << 8) | b
        argb.append(val)
    return w, h, argb

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

    # Tạo thư mục đích nếu chưa tồn tại
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

        # 5. Destructor implementation
        f.write(" CImageResources::~CImageResources(void)\n")
        f.write("  {\n")
        f.write("  }\n\n")

        # 6. SetData implementation
        f.write(" void CImageResources::SetData(const uint index, const string name, const uint width, const uint height, uint &data[])\n")
        f.write("  {\n")
        f.write("   if((int)index >= ArraySize(images)) ArrayResize(images, (int)index+1);\n")
        f.write("   images[index].name   = name;\n")
        f.write("   images[index].width  = width;\n")
        f.write("   images[index].height = height;\n")
        f.write("   ArrayCopy(images[index].data, data);\n")
        f.write("  }\n\n")

        # 7. GetData implementation
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

        # 8. Constructor with all image data
        f.write(" //+------------------------------------------------------------------+\n")
        f.write(" //| Class Constructor - Digitized Data Initialization                |\n")
        f.write(" //+------------------------------------------------------------------+\n")
        f.write(" CImageResources::CImageResources(void)\n")
        f.write("  {\n")
        f.write(f"    ArrayResize(images, {len(all_files)});\n\n")

        for entry in all_files:
            print(f"Processing: {entry['var_name']}")
            try:
                w, h, argb = image_to_argb_array(entry['full_path'])
                print(f"  -> {w}x{h}, {len(argb)} pixels")
            except Exception as e:
                print(f"  ERROR: {e}")
                continue

            f.write(f"    uint {entry['var_name']}[] = {{\n")
            for i in range(0, len(argb), 20):
                line = "    " + ",".join(str(v) for v in argb[i:i+20])
                f.write(line + (",\n" if i + 20 < len(argb) else "\n"))
            f.write("    };\n")
            f.write(f'    SetData({entry["enum_name"]}, "{entry["var_name"]}", {w}, {h}, {entry["var_name"]});\n\n')

        f.write("  }\n\n")
        f.write("#endif // CIMAGERESOURCES_IMPLEMENTATION\n")
        f.write("#endif // __IMAGERESOURCES_MQH__\n")

    print(f"\nDone! Saved to: {DEST_FILE}")
    print(f"Total images processed: {len(all_files)}")

if __name__ == "__main__":
    generate_resources()