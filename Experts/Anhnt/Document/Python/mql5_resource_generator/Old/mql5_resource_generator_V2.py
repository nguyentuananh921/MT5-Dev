import os
from PIL import Image

SOURCE_DIR = r'D:\AppData\Download\19073 Images\EasyAndFastGUI'
DEST_FILE  = r'D:\AppData\Download\Dest\Resources.mqh'

def get_var_name(root_dir, file_path):
    rel = os.path.relpath(file_path, root_dir)
    name = rel.replace(os.sep, "_").replace(".", "_").replace(" ", "_")
    return name.lower()

def image_to_argb_array(file_path):
    img = Image.open(file_path).convert("RGBA")
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
                # ✅ Thêm IMAGE_ vào prefix enum
                enum_name = f"IMAGE_RESOURCE_{var_name.upper()}"
                all_files.append({
                    'full_path': full_path,
                    'var_name':  var_name,
                    'enum_name': enum_name
                })

    if not all_files:
        print("No image files found!")
        return

    with open(DEST_FILE, 'w', encoding='utf-8') as f:
        f.write("// Generated for EasyAndFastGUI - Image Resources\n\n")

        # 1. #define block - IMAGE_RESOURCE_ prefix
        for i, entry in enumerate(all_files):
            f.write(f"    #define {entry['enum_name']} (uint){i}\n")

        f.write("\n")

        # 2. struct SImage (giữ nguyên)
        f.write("struct SImage\n{\n")
        f.write("    string name;\n")
        f.write("    uint width;\n")
        f.write("    uint height;\n")
        f.write("    uint data[];\n")
        f.write("};\n\n")

        # 3. Class declaration - CImageResources
        f.write("class CImageResources\n{\n")
        f.write("  protected:\n")
        f.write("    SImage images[];\n")
        f.write("  public:\n")
        f.write("    CImageResources(void);\n")
        f.write("    ~CImageResources(void);\n")
        f.write("    int Total(void) { return(ArraySize(images)); }\n")
        f.write("    void SetData(const uint index, const string name, const uint width, const uint height, uint &data[]);\n")
        f.write("    string GetData(const uint index, uint &image_data[], uint &image_width, uint &image_height);\n")
        f.write("};\n\n")

        f.write("#ifndef CIMAGERESOURCES_IMPLEMENTATION\n")
        f.write("#define CIMAGERESOURCES_IMPLEMENTATION\n\n")

        # 4. SetData implementation
        f.write("void CImageResources::SetData(const uint index, const string name, const uint width, const uint height, uint &data[])\n{\n")
        f.write("    if((int)index >= ArraySize(images)) ArrayResize(images, index+1);\n")
        f.write("    images[index].name   = name;\n")
        f.write("    images[index].width  = width;\n")
        f.write("    images[index].height = height;\n")
        f.write("    ArrayCopy(images[index].data, data);\n")
        f.write("}\n\n")

        # 5. GetData implementation
        f.write("string CImageResources::GetData(const uint index, uint &image_data[], uint &image_width, uint &image_height)\n{\n")
        f.write("    if((int)index >= ArraySize(images)) { Print(__FUNCTION__,\" > Out of bounds!\"); return(\"\"); }\n")
        f.write("    ArrayFree(image_data);\n")
        f.write("    image_width  = images[index].width;\n")
        f.write("    image_height = images[index].height;\n")
        f.write("    ArrayCopy(image_data, images[index].data);\n")
        f.write("    return(images[index].name);\n")
        f.write("}\n\n")

        # 6. Constructor - CImageResources
        f.write("CImageResources::CImageResources(void)\n{\n")
        f.write(f"    ArrayResize(images, {len(all_files)});\n\n")

        for entry in all_files:
            print(f"Processing: {entry['var_name']}")
            try:
                w, h, argb = image_to_argb_array(entry['full_path'])
            except Exception as e:
                print(f"  ERROR: {e}")
                continue

            f.write(f"    uint {entry['var_name']}[] = {{\n")
            for i in range(0, len(argb), 20):
                line = "    " + ",".join(str(v) for v in argb[i:i+20])
                f.write(line + (",\n" if i + 20 < len(argb) else "\n"))
            f.write("    };\n")
            # ✅ SetData dùng IMAGE_RESOURCE_ enum
            f.write(f'    SetData({entry["enum_name"]}, "{entry["var_name"]}", {w}, {h}, {entry["var_name"]});\n\n')

        f.write("}\n\n")
        f.write("#endif // CIMAGERESOURCES_IMPLEMENTATION\n")

    print(f"Done! Saved to: {DEST_FILE}")

if __name__ == "__main__":
    generate_resources()