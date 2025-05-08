import time
import os
from core.log import log_info
from core.util import read_file_with_encoding, quote
import re
from core.translator import latin_to_cyrillic, translate_text
from core.config import ENCODING


def to_fill(input_path: str, output_dir: str) -> str:
    """
    This function is a placeholder for the actual implementation of the
    to_fill_the_lang4 function. It should be replaced with the actual
    logic that processes the file and updates the processing status.
    """
    start = time.time()
    file_name = os.path.basename(input_path)
    output_path = os.path.join(output_dir, file_name)

    log_info(f"Processing file for LANG4 conversion: {input_path}")

    content = read_file_with_encoding(input_path)
    if content is None:
        log_info(f"Could not read file {file_name}")
        return None
    # SI() funksiyasini qidirish va bo'sh joylarni to'ldirish
    pattern = r'SI\("((?:[^"\\]|\\.)*)",\s*"((?:[^"\\]|\\.)*)",\s*"((?:[^"\\]|\\.)*)",\s*"((?:[^"\\]|\\.)*)"\)'
    try:

        matches = re.findall(pattern, content)
        # Tarjima qilish va yangilash
        for match in matches:
            rus_text = match[0]
            uzb_krill_text = match[1]
            uzb_latin_text = match[2]
            eng_text = match[3]
            # Agar ikkinchi (Uzbek Krill), uchinchi (Uzbek Latin) yoki to'rtinchi (Inglizcha) bo'sh bo'lsa
            if uzb_latin_text == "":
                uzb_latin_text = translate_text(
                    text=rus_text, src_lang="ru", dest_lang="uz"
                )
            if uzb_krill_text == "":
                uzb_krill_text = latin_to_cyrillic(uzb_latin_text)
            if eng_text == "":
                eng_text = translate_text(text=rus_text, src_lang="ru", dest_lang="en")
            # Yangilangan SI() funksiyasini topish
            updated_text = f'SI("{quote(rus_text)}", "{quote(uzb_krill_text)}", "{quote(uzb_latin_text)}", "{quote(eng_text)}")'
            pattern = rf'SI\("{re.escape(match[0])}",\s*"{re.escape(match[1])}",\s*"{re.escape(match[2])}",\s*"{re.escape(match[3])}"\)'
            content = re.sub(pattern, updated_text, content)
        # Yangilangan kontentni faylga yozish
        with open(output_path, "w", encoding=ENCODING) as f:
            f.write(content)
        log_info(f"Successfully converted file: {output_path}")
        return output_path
    except Exception as e:
        log_info(f"Conversion failed: {str(e)}")
        return None
    finally:
        end = time.time()
        log_info(f"Processing time: {end - start:.2f}s")
