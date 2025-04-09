# -*- coding: windows-1251 -*-


module_code = "LN"
conuter = 0
source = ["card_buttons.txt"]


def replace_char(word):
    return word.replace('"', "&quot;").replace("'", "''").replace("`","‘").replace("‘", "&rsquo;").replace("’", "&rsquo;")


def replace_cyrillic(word):
    return (
        word.replace("?", "&#1178;")  # Replace '?' with &#1178;
        .replace("?", "&#1170;")  # Replace '?' with &#1170;
        .replace("Ў", "&#1038;")  # Replace 'Ў' with &#1038;
        .replace("?", "&#1202;")  # Replace '?' with &#1202;
        .replace("?", "&#1179;")  # Replace '?' with &#1179;
        .replace("?", "&#1171;")  # Replace '?' with &#1171;
        .replace("ў", "&#1118;")  # Replace 'ў' with &#1118;
        .replace("?", "&#1203;")  # Replace '?' with &#1203;
    )



with open("dw_buttons.sql", "w") as file:
    file.write("set define off;\n")
    file.write("delete Dw_Buttons t where t.Module_Code = 'LN';\n")
    file.write("delete Dw_Button_Roles where Module_Code = 'LN';\n")
    file.write(
        "-------------------------------------------------------------------------------\n"
    )
    file.write("begin\n")
for l in source:
    lines = []
    temp =0
    with open(l, "r") as rows:
        for row in rows:
            r = replace_char(row.strip()).split("|")
            conuter += 1
            if temp != r[0]:
                conuter = 1    
            temp = r[0]
            line = (
                f"\tinsert into Dw_Buttons (Module_Code, Menu_Id, Button_Id, Button_Code, Label, Condition) values ("
                f"'{module_code}', "
                f"'{r[0]}', "
                f"'{conuter}', "
                f"'{r[1]}', "
                f"s_Nsi_Nvt('{r[2]}', '{replace_cyrillic(r[3])}', '{r[4]}', '{r[5]}'), "
                "'A');\n"
            )
            lines.append(line)
            
    with open("dw_buttons.sql", "a") as file:
        file.writelines(lines)
    lines = []
    conuter = 1
with open("dw_buttons.sql", "a") as file:
    file.writelines(
        [
            "\tcommit;\n",
            "end;\n",
            "/\n",
            "begin\n",
            "\tSetup.Set_Iabs(Setup.Get_Headermfo);\n",
            "\tLn_Cache.Module_Code := 'LN';\n",
            "\tLn_Cache.Form_Code   := 70904;\n",
            "\tinsert into Dw_Button_Roles"
            "\t\t(Module_Code, Menu_Id, Button_Id, Role_Code, Rank_Code, Condition)\n",
            "\t\tselect 'LN', d.Menu_Id, d.Button_Id, t.Code, '', 'A'\n",
            "\t\t  from Dw_Buttons d, Ln_v_Roles t\n",
            "\t\t where d.Module_Code = 'LN';\n",
            "\tcommit;\n",
            "end;\n",
            "/\n",
            "set define on;",
        ]
    )
