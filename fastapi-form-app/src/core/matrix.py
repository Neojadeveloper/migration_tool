import time
import os
from core.log import log_info
from core.util import replace_char, replace_cyrillic
import re
from core.config import ENCODING, MODULE_CODE
from core.exceptions import MatrixError


def matrix(input_path: str, output_dir: str) -> str:
    start = time.time()
    file_name = os.path.basename(input_path)
    base_name = os.path.splitext(file_name)[0]
    output_filename = f"{base_name}_matrix.sql"
    output_path = os.path.join(output_dir, output_filename)

    log_info(f"Processing file for SQL template generation: {input_path}")

    try:
        lines = buttons(input_path)
        buttons_sql(lines, output_path)
        log_info(f"Successfully converted file: {output_path}")
        return output_path
    except MatrixError:
        raise
    except Exception as e:
        log_info(f"Conversion failed: {str(e)}")
        return None
    finally:
        end = time.time()
        log_info(f"Processing time: {end - start:.2f}s")


def buttons_sql(source, output_path):
    header = [
        "set define off;\n",
        "delete Dw_Buttons t where t.Module_Code = 'LN';\n",
        "delete Dw_Button_Roles where Module_Code = 'LN';\n",
        "-------------------------------------------------------------------------------\n",
        "begin\n",
    ]

    lines = []
    temp = 0
    conuter = 0
    for row in source:
        r = replace_char(row.strip()).split("|")
        conuter += 1
        if temp != r[0]:
            conuter = 1
        temp = r[0]
        line = (
            f"\tinsert into Dw_Buttons (Module_Code, Menu_Id, Button_Id, Button_Code, Label, Condition) values ("
            f"'{MODULE_CODE}', "
            f"'{r[0]}', "
            f"'{conuter}', "
            f"'{r[1]}', "
            f"s_Nsi_Nvt('{r[2]}', '{replace_cyrillic(r[3])}', '{r[4]}', '{r[5]}'), "
            "'A');\n"
        )
        lines.append(line)
    footer = [
        "\tcommit;\n",
        "end;\n",
    ]
    with open(output_path, "w") as file:
        file.writelines(header)
        file.writelines(lines)
        file.writelines(footer)
    # [
    #             "/\n",
    #             "begin\n",
    #             "\tSetup.Set_Iabs(Setup.Get_Headermfo);\n",
    #             "\tLn_Cache.Module_Code := 'LN';\n",
    #             "\tLn_Cache.Form_Code   := 70904;\n",
    #             "\tinsert into Dw_Button_Roles"
    #             "\t\t(Module_Code, Menu_Id, Button_Id, Role_Code, Rank_Code, Condition)\n",
    #             "\t\tselect 'LN', d.Menu_Id, d.Button_Id, t.Code, '', 'A'\n",
    #             "\t\t  from Dw_Buttons d, Ln_v_Roles t\n",
    #             "\t\t where d.Module_Code = 'LN';\n",
    #             "\tcommit;\n",
    #             "end;\n",
    #             "/\n",
    #             "set define on;",
    #         ]


def buttons(file_path):
    log_info("Make sources")
    p_ids = r'id="(.*?)"|id=(.*?)\s+'
    p_si = rf"lang.get\((.*?)\)"
    p_jsp_id = r"<%--matrix\|(\d+)--%>"
    # Read the file and find all matches
    with open(file_path, "r", encoding=ENCODING) as file:
        content = file.read()
        try:
            jsp_id = re.findall(p_jsp_id, content)[0]
            pattern = rf"<%--matrix\|{jsp_id}--%>(.*?)<%--matrix\|{jsp_id}--%>"
            matches = re.findall(pattern, content, re.DOTALL)
        except:
            raise MatrixError(
                message="Matrix ID pattern not found in file. <%--matrix|id--%>",
                error_code=f"{MODULE_CODE}_MATRIX_ID_NOT_FOUND",
            )
        for matrix_content in matches:
            ids = []
            ids_ = re.findall(p_ids, matrix_content)
            for i in ids_:
                a = ""
                if i[0] != "":
                    a = i[0]
                elif i[1] != "":
                    a = i[1]
                if a not in [
                    "tableControls",
                    "filterControls",
                    "sumControls",
                    "basepanel",
                    "user_id_span",
                    "pass",
                    "html",
                    "excel",
                    "formToolbar",
                ]:
                    ids.append(a)
            si_matches = re.findall(p_si, matrix_content)
        if len(ids) > len(si_matches):
            r = len(si_matches)
        else:
            r = len(ids)
        add = []
        for i in range(r):
            l = r'<%@ include file="form_language.jsp" %>'
            si_2 = rf'{re.escape(si_matches[i])}\s*=\s*SI\("([^"]*)",\s*"([^"]*)",\s*"([^"]*)",\s*"([^"]*)"\)'
            if re.findall(l, content):
                lang_path = f"{file_path[:-4]}_language.jsp"
                with open(lang_path) as lang:
                    lang_content = lang.read()
                matches = re.findall(si_2, lang_content)
            else:
                matches = re.findall(si_2, content)
            # print(f"{ids[i]}|{si_matches[i]}|{matches}")
            a = f"{jsp_id}|{ids[i]}|{matches[0][0]}|{matches[0][1]}|{matches[0][2]}|{matches[0][3]}\n"
            add.append(a)
        return add
