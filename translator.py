# -*- coding: windows-1251 -*-

from httpcore import SyncHTTPProxy
from googletrans import Translator

http_proxy = SyncHTTPProxy((b"http", b"inet.fido.uz", 3128, b""))
proxies = {"http": http_proxy, "https": http_proxy}

translator = Translator(proxies=proxies)


def translate_text(text, src_lang, dest_lang):
    # print(f"text : {text} | src : {src_lang} | dest : {dest_lang}")
    try:
        translation = translator.translate(text, src=src_lang, dest=dest_lang)
        # print(f"tr : {translation.text}")
        return translation.text
    except Exception as e:
        print(f"Tarjima xatosi: {e}")
        return text
