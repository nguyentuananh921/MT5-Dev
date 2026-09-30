import os
import struct

# ── Configuration ──────────────────────────────────────────────────────────────
SOURCE_DIR = r'D:\MT5-Dev\Icons'
DEST_FILE  = r'D:\MT5-Dev\Experts\Anhnt\Document\Tools\mql5_resource_generator\Dest\ImageDataDefine.mqh'

# Leave empty to process all images found in SOURCE_DIR.
# Add relative paths (from SOURCE_DIR) to filter, e.g. ['bmp16\\ArrowDown.bmp']
INCLUDE_ONLY = []
# ───────────────────────────────────────────────────────────────────────────────

def get_var_name(root_dir, file_path):
    rel  = os.path.relpath(file_path, root_dir)
    name = rel.replace(os.sep, "_").replace(".", "_").replace(" ", "_")
    return name.lower()

def get_enum_name(var_name):
    return f"IMAGE_RESOURCE_{var_name.upper()}"

def detect_format(file_path):
    with open(file_path, 'rb') as f:
        magic = f.read(8)
    if magic[:8] == b'\x89PNG\r\n\x1a\n':
        return 'png'
    if magic[:2] == b'BM':
        return 'bmp'
    if magic[:3] == b'\xff\xd8\xff':
        return 'jpg'
    raise ValueError(f"Unknown file format (magic={magic[:4].hex()}): {file_path}")

def image_to_argb_array(file_path):
    fmt = detect_format(file_path)

    if fmt == 'png':
        from PIL import Image
        img = Image.open(file_path).convert("RGBA")
        wp, hp = img.size
        argb = []
        for (r, g, b, a) in img.getdata():
            argb.append(0x00FFFFFF if a == 0 else (0xFF << 24) | (r << 16) | (g << 8) | b)
        return wp, hp, argb

    if fmt == 'jpg':
        from PIL import Image
        img = Image.open(file_path).convert("RGB")
        wp, hp = img.size
        argb = [(0xFF << 24) | (r << 16) | (g << 8) | b for (r, g, b) in img.getdata()]
        return wp, hp, argb

    # BMP — read raw bytes
    with open(file_path, 'rb') as f:
        data = f.read()

    bit_count = struct.unpack_from('<H', data, 28)[0]
    offset    = struct.unpack_from('<I', data, 10)[0]
    w         = struct.unpack_from('<i', data, 18)[0]
    h         = struct.unpack_from('<i', data, 22)[0]
    h_abs     = abs(h)

    if bit_count == 32:
        pixels_raw = data[offset:]
        pixels     = []
        for i in range(0, w * h_abs * 4, 4):
            pixels.append((pixels_raw[i + 2], pixels_raw[i + 1], pixels_raw[i], pixels_raw[i + 3]))
        if h > 0:
            rows = [pixels[row * w:(row + 1) * w] for row in range(h_abs)]
            rows.reverse()
            pixels = [p for row in rows for p in row]
        # No real alpha (all 0, XRGB, e.g. Kazharski checkbox icons): every pixel is opaque
        if all(a == 0 for (_, _, _, a) in pixels):
            argb_values = [(0xFF << 24) | (r << 16) | (g << 8) | b for (r, g, b, _) in pixels]
        else:
            argb_values = [0x00FFFFFF if a == 0 else (0xFF << 24) | (r << 16) | (g << 8) | b
                           for (r, g, b, a) in pixels]
        return w, h_abs, argb_values
    else:
        from PIL import Image
        img_rgb = Image.open(file_path).convert("RGB")
        wp, hp  = img_rgb.size
        transparent_color = img_rgb.getpixel((0, hp - 1))
        argb    = []
        for (r, g, b) in img_rgb.getdata():
            argb.append(0x00FFFFFF if (r, g, b) == transparent_color
                        else (0xFF << 24) | (r << 16) | (g << 8) | b)
        return wp, hp, argb

def generate():
    include_set = (
        set(os.path.normpath(p) for p in INCLUDE_ONLY) if INCLUDE_ONLY else None
    )

    # ── Pass 1: collect files and read pixel data ──────────────────────────────
    entries = []   # successfully processed
    errors  = []   # failed

    for root, _, files in os.walk(SOURCE_DIR):
        for filename in sorted(files):
            if not filename.lower().endswith(('.bmp', '.png', '.jpg')):
                continue
            full_path = os.path.join(root, filename)
            rel       = os.path.relpath(full_path, SOURCE_DIR)
            if include_set and os.path.normpath(rel) not in include_set:
                continue

            var_name  = get_var_name(SOURCE_DIR, full_path)
            enum_name = get_enum_name(var_name)
            print(f"Processing: {var_name}")
            try:
                w, h, argb = image_to_argb_array(full_path)
                print(f"  -> {w}x{h}, {len(argb)} pixels")
                entries.append({
                    'var_name':  var_name,
                    'enum_name': enum_name,
                    'w': w, 'h': h, 'argb': argb,
                })
            except Exception as e:
                print(f"  ERROR: {e}")
                errors.append(var_name)

    if not entries:
        print("No images processed successfully.")
        return

    # ── Pass 2: write ImageDataDefine.mqh ─────────────────────────────────────
    os.makedirs(os.path.dirname(DEST_FILE), exist_ok=True)

    with open(DEST_FILE, 'w', encoding='utf-8') as f:

        # Header
        f.write("//+------------------------------------------------------------------+\n")
        f.write("//|                                          ImageDataDefine.mqh      |\n")
        f.write("//|               Generated by claude-Python-Digital_ImageCreator     |\n")
        f.write("//+------------------------------------------------------------------+\n")
        f.write("#ifndef __IMAGEDATADEFINE_MQH__\n")
        f.write("#define __IMAGEDATADEFINE_MQH__\n\n")

        # ── STATIC section (written once, never changes) ───────────────────────
        f.write("//+--- Static: image data structure -----------------------------------+\n")
        f.write("struct SImage\n")
        f.write("  {\n")
        f.write("    string name;\n")
        f.write("    uint   width;\n")
        f.write("    uint   height;\n")
        f.write("    uint   data[];\n")
        f.write("  };\n\n")

        # ── Part 1: index constants ────────────────────────────────────────────
        f.write("//+--- Part 1: Image index constants ---------------------------------+\n")
        for i, e in enumerate(entries):
            f.write(f" #define {e['enum_name']} (uint){i}\n")
        f.write(f" #define IMAGE_RESOURCE_TOTAL (uint){len(entries)}\n")
        f.write("\n")

        # ── Part 2 + Part 3: one switch case per image ─────────────────────────
        # Only the requested case runs, so only that image's pixels are built
        f.write("//+--- Part 2 & 3: Pixel data + loader of a single image ------------+\n")
        f.write("bool LoadImageData(const uint index, SImage &image)\n")
        f.write("  {\n")
        f.write("    switch(index)\n")
        f.write("      {\n")

        for i, e in enumerate(entries):
            f.write(f"       case {i}: // {e['var_name']}\n")
            f.write("         {\n")
            f.write(f"          uint {e['var_name']}[] = {{\n")
            argb = e['argb']
            for j in range(0, len(argb), 20):
                line = "          " + ",".join(str(v) for v in argb[j:j + 20])
                f.write(line + (",\n" if j + 20 < len(argb) else "\n"))
            f.write("          };\n")
            f.write(f"          image.name   = \"{e['var_name']}\";\n")
            f.write(f"          image.width  = {e['w']};\n")
            f.write(f"          image.height = {e['h']};\n")
            f.write(f"          ArrayCopy(image.data, {e['var_name']});\n")
            f.write("          return true;\n")
            f.write("         }\n")

        f.write("      }\n")
        f.write("    return false;\n")
        f.write("  }\n\n")
        f.write("#endif // __IMAGEDATADEFINE_MQH__\n")

    print(f"\nDone! Saved to: {DEST_FILE}")
    print(f"Total images: {len(entries)}  |  Errors: {len(errors)}")
    if errors:
        print(f"Failed: {errors}")

if __name__ == "__main__":
    generate()
