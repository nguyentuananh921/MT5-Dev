import os
import re
from deep_translator import GoogleTranslator
from pathlib import Path

# Cấu hình đường dẫn
SOURCE_DIR = r'C:\Users\nguye\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Experts\Artyom Trishkin\3. Tables in the MVC\17960 Base graphical element\Original Russian\Controls'
translator = GoogleTranslator(source='ru', target='en')

def process_file(file_path):
    print(f"Đang xử lý: {file_path.name}")
    content = ""
    # Thử đọc các loại định dạng file
    for enc in ['utf-16', 'utf-8', 'cp1251']:
        try:
            with open(file_path, 'r', encoding=enc) as f:
                content = f.read()
            break
        except: continue

    if not content: return

    def translate_func(match):
        text = match.group(0)
        # Chỉ dịch nếu có chữ tiếng Nga
        if re.search('[а-яА-Я]', text):
            prefix = "// " if text.startswith("//") else "/* "
            clean_text = text.replace("//", "").replace("/*", "").replace("*/", "").strip()
            try:
                return prefix + translator.translate(clean_text) + (" */" if "/*" in text else "")
            except: return text
        return text

    # Dịch comment
    new_content = re.sub(r'//.*', translate_func, content)
    new_content = re.sub(r'/\*.*?\*/', translate_func, new_content, flags=re.DOTALL)

    new_file = file_path.parent / f"{file_path.stem}_EN{file_path.suffix}"
    with open(new_file, 'w', encoding='utf-8') as f:
        f.write(new_content)
    print(f"Done -> {new_file.name}")

path = Path(SOURCE_DIR)
for ext in ['*.mqh', '*.mq5']:
    for file in path.rglob(ext):
        process_file(file)