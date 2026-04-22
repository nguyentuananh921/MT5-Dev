import os
import re
from googletrans import Translator
from pathlib import Path

# Cấu hình
SOURCE_DIR = r'C:\Users\nguye\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Experts\Artyom Trishkin\3. Tables in the MVC\17960 Base graphical element' # Thay bằng đường dẫn của cậu
TARGET_LANG = 'en' # 'en' cho tiếng Anh, 'vi' cho tiếng Việt
translator = Translator()

def translate_text(text):
    if not text.strip() or not re.search('[а-яА-Я]', text):
        return text
    try:
        translated = translator.translate(text, src='ru', dest=TARGET_LANG)
        return translated.text
    except Exception as e:
        print(f"Lỗi dịch: {e}")
        return text

def process_file(file_path):
    print(f"Đang xử lý: {file_path.name}")
    with open(file_path, 'r', encoding='utf-16') as f: # MQL5 thường dùng utf-16
        content = f.read()

    # Regex tìm comment // và /* ... */
    def replace_comment(match):
        comment = match.group(0)
        # Tách phần dấu // hoặc /* ra để chỉ dịch nội dung
        prefix = ""
        if comment.startswith('//'):
            prefix = '// '
            inner_text = comment[2:]
        else:
            prefix = '/* '
            inner_text = comment[2:-2]
            
        return prefix + translate_text(inner_text) + ( ' */' if prefix == '/* ' else '')

    # Dịch comment dòng đơn
    new_content = re.sub(r'//.*', replace_comment, content)
    # Dịch comment khối
    new_content = re.sub(r'/\*.*?\*/', replace_comment, new_content, flags=re.DOTALL)

    # Lưu file mới với hậu tố _translated
    new_file_path = file_path.parent / f"{file_path.stem}_en{file_path.suffix}"
    with open(new_file_path, 'w', encoding='utf-8') as f:
        f.write(new_content)

# Quét tất cả file .mqh và .mq5
path = Path(SOURCE_DIR)
for ext in ['*.mqh', '*.mq5']:
    for file in path.rglob(ext):
        process_file(file)

print("--- HOÀN THÀNH ---")