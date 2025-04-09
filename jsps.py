# -*- coding: windows-1251 -*-

import os
import re
import translator as tr

def convert_to_cyrillic(latin_text):
    latin_to_cyrillic_map = {
        "a": "�",
        "b": "�",
        "v": "�",
        "g": "�",
        "g�": "&#1171;",
        "d": "�",
        "e": "�",
        "yo": "�",
        "j": "�",
        "z": "�",
        "i": "�",
        "y": "�",
        "k": "�",
        "q": "&#1179;",
        "l": "�",
        "m": "�",
        "n": "�",
        "o": "�",
        "p": "�",
        "r": "�",
        "s": "�",
        "t": "�",
        "u": "�",
        "f": "�",
        "x": "�",
        "h": "&#1203;",
        "ts": "�",
        "ch": "�",
        "sh": "�",
        "sch": "�",
        "y": "�",
        "e": "�",
        "yu": "�",
        "ya": "�",
        "o�": "&#1118;",
        "zh": "�",
        "A": "�",
        "B": "�",
        "V": "�",
        "G": "�",
        "G�": "&#1170;",
        "D": "�",
        "E": "�",
        "Yo": "�",
        "J": "�",
        "Z": "�",
        "I": "�",
        "Y": "�",
        "K": "�",
        "Q": "&#1178;",
        "L": "�",
        "M": "�",
        "N": "�",
        "O": "�",
        "P": "�",
        "R": "�",
        "S": "�",
        "T": "�",
        "U": "�",
        "F": "�",
        "X": "�",
        "H": "&#1202;",
        "Ts": "�",
        "Ch": "�",
        "Sh": "�",
        "Sch": "�",
        "Y": "�",
        "E": "�",
        "Yu": "�",
        "Ya": "�",
        "O�": "&#1038;",
        "Zh": "�",
    }

    for latin, cyrillic in latin_to_cyrillic_map.items():
        latin_text = latin_text.replace(latin, cyrillic)

    return latin_text


def clear(word):
    return word.replace('\\"', "&quot;")
encode = "windows-1251"
# JSP fayllarini qidirish va yangilash funksiyasi
def process_jsp_files(path):
    # Fayl yo'llari bo'yicha qidirish
    for root, dirs, files in os.walk(path):
        for file in files:
            if file.endswith(".jsp"):
                file_path = os.path.join(root, file)
                print(f"Faylni ishlov berilmoqda: {file_path}")

                # Faylni ochish
                with open(file_path, "r", encoding=encode) as f:
                    content = f.read()

                # SI() funksiyasini qidirish va bo'sh joylarni to'ldirish
                pattern = r'SI\("((?:[^"\\]|\\.)*)",\s*"((?:[^"\\]|\\.)*)",\s*"((?:[^"\\]|\\.)*)",\s*"((?:[^"\\]|\\.)*)"\)'
                matches = re.findall(pattern, content)
                # Tarjima qilish va yangilash
                for match in matches:
                    rus_text = clear(match[0])
                    uzb_krill_text = clear(match[1])
                    uzb_latin_text = clear(match[2])
                    eng_text = clear(match[3])
                    # Agar ikkinchi (Uzbek Krill), uchinchi (Uzbek Latin) yoki to'rtinchi (Inglizcha) bo'sh bo'lsa
                    if uzb_latin_text == "":
                        uzb_latin_text = tr.translate_text(text=rus_text, src_lang="ru", dest_lang="uz")
                    if uzb_krill_text == "":
                        uzb_krill_text = convert_to_cyrillic(uzb_latin_text)
                    if eng_text == "":
                        eng_text = tr.translate_text(text=rus_text, src_lang="ru", dest_lang="en")
                    # Yangilangan SI() funksiyasini topish
                    updated_text = f'SI("{rus_text}", "{uzb_krill_text}", "{uzb_latin_text}", "{eng_text}")'
                    pattern = rf'SI\("{re.escape(match[0])}",\s*"{re.escape(match[1])}",\s*"{re.escape(match[2])}",\s*"{re.escape(match[3])}"\)'
                    content = re.sub(pattern, updated_text, content)

                # Yangilangan kontentni faylga yozish
                with open(file_path, "w", encoding=encode, errors='ignore') as f:
                    f.write(content)
                print(f"Fayl yangilandi: {file_path}")

# Fayl yo'lini ko'rsating
directory_path = "D:/iabs/iabs_core/src/main/webapp/ibs/ls/automatic_repayment"  # .jsp fayllari joylashgan papka yo'lini kiriting
process_jsp_files(directory_path)
