from core.log import log_info
from core.config import ENCODING


def read_file_with_encoding(file_path: str, encoding: str = ENCODING) -> str:
    last_error = None

    try:
        with open(file_path, "r", encoding=encoding) as file:
            content = file.read()
            log_info(f"Successfully read file with encoding: {encoding}")
            return content
    except UnicodeDecodeError as e:
        last_error = e
        log_info(f"Failed to read {file_path} with encoding {encoding}")

    except Exception as e:
        log_info(f"Unexpected error reading file: {str(e)}")
        raise

    log_info(f"Failed to read file with any encoding. Last error: {str(last_error)}")
    return None


def quote(word):
    return word.replace('\\"', "&quot;")


def replace_char(word):
    return (
        word.replace('"', "&quot;")
        .replace("'", "''")
        .replace("`", "‘")
        .replace("‘", "&rsquo;")
        .replace("’", "&rsquo;")
    )


def replace_cyrillic(word):
    return (
        word.replace("Қ", "&#1178;")  # Replace 'Қ' with &#1178;
        .replace("Ғ", "&#1170;")  # Replace 'Ғ' with &#1170;
        .replace("Ў", "&#1038;")  # Replace 'Ў' with &#1038;
        .replace("Ҳ", "&#1202;")  # Replace 'Ҳ' with &#1202;
        .replace("қ", "&#1179;")  # Replace 'қ' with &#1179;
        .replace("ғ", "&#1171;")  # Replace 'ғ' with &#1171;
        .replace("ў", "&#1118;")  # Replace 'ў' with &#1118;
        .replace("ҳ", "&#1203;")  # Replace 'ҳ' with &#1203;
    )
