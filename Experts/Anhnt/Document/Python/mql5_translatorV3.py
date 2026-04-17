import os
import re
import time
from deep_translator import GoogleTranslator
from pathlib import Path

# --- CẤU HÌNH GỐC ---
# Tớ để thư mục gốc chứa tất cả các bài của Artyom Trishkin
SOURCE_DIR = r'C:\Users\nguye\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Include\Vendors\Anhnt\Library\3. EasyAndFastGUI 19703'
translator = GoogleTranslator(source='ru', target='en')

def process_file(file_path):
    # Bỏ qua nếu file đã có hậu tố _EN (tránh dịch đè lên file đã dịch)
    if "_EN" in file_path.name:
        return

    print(f"--- Đang xử lý: {file_path.relative_to(SOURCE_DIR)} ---")
    
    content = ""
    # Thử các định dạng mã hóa phổ biến của MQL5
    for enc in ['utf-16', 'utf-8', 'cp1251']:
        try:
            with open(file_path, 'r', encoding=enc) as f:
                content = f.read()
            break
        except:
            continue

    if not content:
        return

    def translate_func(match):
        text = match.group(0)
        # Chỉ dịch nếu chứa ký tự tiếng Nga
        if re.search('[а-яА-Я]', text):
            # Giữ lại định dạng comment // hoặc /* */
            prefix = "// " if text.startswith("//") else "/* "
            suffix = " */" if text.startswith("/*") else ""
            clean_text = text.replace("//", "").replace("/*", "").replace("*/", "").strip()
            try:
                # Nghỉ một chút để tránh bị Google chặn
                time.sleep(0.2) 
                return prefix + translator.translate(clean_text) + suffix
            except:
                return text
        return text

    # Tìm và dịch comment đơn dòng và đa dòng
    new_content = re.sub(r'//.*', translate_func, content)
    new_content = re.sub(r'/\*.*?\*/', translate_func, new_content, flags=re.DOTALL)

    # Tạo file mới với hậu tố _EN
    new_file = file_path.parent / f"{file_path.stem}_EN{file_path.suffix}"
    with open(new_file, 'w', encoding='utf-8') as f:
        f.write(new_content)
    print(f"   => Xong: {new_file.name}")

# --- KHỞI CHẠY QUÉT TOÀN BỘ THƯ MỤC CON ---
path = Path(SOURCE_DIR)
# rglob('*') sẽ quét tất cả file trong mọi thư mục con
for ext in ['*.mqh', '*.mq5']:
    for file in path.rglob(ext):
        process_file(file)

print("\n--- ĐÃ DỊCH XONG TOÀN BỘ THƯ MỤC ---")