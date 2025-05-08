from httpcore import SyncHTTPProxy
from googletrans import Translator
from core.log import log_info
from core.config import USING_PROXY

if USING_PROXY:
    http_proxy = SyncHTTPProxy((b"http", b"inet.fido.uz", 3128, b""))
    proxies = {"http": http_proxy, "https": http_proxy}
    translator = Translator(proxies=proxies)
else:
    translator = Translator()


def translate_text(text, src_lang, dest_lang):
    log_info(f"text : {text} | src : {src_lang} | dest : {dest_lang}")
    try:
        translation = translator.translate(text, src=src_lang, dest=dest_lang)
        log_info(f"tr : {translation.text}")
        return translation.text
    except Exception as e:
        log_info(f"Tarjima xatosi: {e}")
        return text


def latin_to_cyrillic(text):
    mapping = {
        "Yo": "Ё",
        "yo": "ё",
        "Ya": "Я",
        "ya": "я",
        "Yu": "Ю",
        "yu": "ю",
        "Sh": "Ш",
        "sh": "ш",
        "Ch": "Ч",
        "ch": "ч",
        "O‘": "&#1038;",
        "o‘": "&#1118;",
        "O'": "&#1038;",
        "o'": "&#1118;",
        "G‘": "&#1170;",
        "g‘": "&#1171;",
        "G'": "&#1170;",
        "g'": "&#1171;",
        "A": "А",
        "a": "а",
        "B": "Б",
        "b": "б",
        "D": "Д",
        "d": "д",
        "E": "Э",
        "e": "э",
        "F": "Ф",
        "f": "ф",
        "G": "Г",
        "g": "г",
        "H": "&#1202;",
        "h": "&#1203;",
        "I": "И",
        "i": "и",
        "J": "Ж",
        "j": "ж",
        "K": "К",
        "k": "к",
        "L": "Л",
        "l": "л",
        "M": "М",
        "m": "м",
        "N": "Н",
        "n": "н",
        "O": "О",
        "o": "о",
        "P": "П",
        "p": "п",
        "Q": "&#1178;",
        "q": "&#1203;",
        "R": "Р",
        "r": "р",
        "S": "С",
        "s": "с",
        "T": "Т",
        "t": "т",
        "U": "У",
        "u": "у",
        "V": "В",
        "v": "в",
        "X": "Х",
        "x": "х",
        "Y": "Й",
        "y": "й",
        "Z": "З",
        "z": "з",
    }
    log_info(f"Latin: {text}")
    # Ikki harfli kombinatsiyalarni avval almashtiramiz (masalan: sh, ch)
    for latin, cyr in sorted(mapping.items(), key=lambda x: -len(x[0])):
        text = text.replace(latin, cyr)
    log_info(f"Cyrillic: {text}")
    return text


if __name__ == "__main__":
    log_info("Testing translation")
    log_info(translate_text("Привет, как дела?", src_lang="ru", dest_lang="uz"))
