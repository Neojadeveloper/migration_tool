# -*- coding: windows-1251 -*-

from pathlib import Path
import re

encode = "windows-1251"
# Regular expression pattern to match content between `<%--matrix|60--%>` tags
p_ids = r'id="(.*?)"|id=(.*?)\s+'
p_si = rf"lang.get\((.*?)\)"
p_jsp_id = r"<%--matrix\|(\d+)--%>"


def buttons(file_path):
    # Read the file and find all matches
    with open(file_path, "r", encoding=encode) as file:
        content = file.read()
        jsp_id = re.findall(p_jsp_id, content)[0]
        pattern = rf"<%--matrix\|{jsp_id}--%>(.*?)<%--matrix\|{jsp_id}--%>"
        matches = re.findall(pattern, content, re.DOTALL)
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


if __name__ == "__main__":
    file_paths = [
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/card/cards_list.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/card/form.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/blank/account_balance/class_credit.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/card/founders.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/accounts/acc_list.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/claim/claims_list.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/claim/coborrowers.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/claim/form.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/blank/form.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/blank/blanks.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/blank/blanks_all.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/factoring_promisors/promisors_list.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/claim/admission.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/refs/rep_types/rep_types.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/refs/bank_codes/bank_codes.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/refs/credit_history/credit_histories.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/refs/deciding_organ/organs_list.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/refs/direction/directions.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/refs/eco_file_types/eco_types.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/refs/fin_sources/finance_rates.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/refs/fin_sources/finance_types.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/refs/fin_sources/return_percents.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/refs/fin_sources/return_resources.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/refs/insurance_companies/insurance_companies.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/refs/insurance_companies/esbc_insuranse/insuranse_terminates.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/refs/credit_objects/credit_objects.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/refs/credit_objects/credit_object_types.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/settings/blank/levels.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/settings/blank/departments.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/settings/blank/states.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/settings/blank/product_departments.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/settings/blank/user_levels.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/settings/blank/transit_levels.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/settings/blank/level_2_props_ankets.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/settings/resource_control/admission/sources.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/settings/resource_control/filial_crediting_settings.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/settings/product/list.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/settings/percent_tariffs/currency_interests.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/settings/loan_control/cards.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/settings/percent_tariffs/interest_rates.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/settings/loan_control/requisites.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/settings/class_quality/class_quality.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/settings/loan_type/loan_types.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/settings/percent_tariffs/list.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/settings/loan_control/access_users.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/settings/loan_control/card_admissions.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/settings/mock_account/accounts.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/settings/controlled_balance_acc/accounts.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/settings/controlled_balance_acc/layout_templates.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/settings/sub_coa/adm/sub_coas.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/settings/reserve/filial_accounts.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/settings/controlled_balance_acc/bls_accounts.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/settings/claim_admitters/admitters.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/settings/comissions/comissions.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/settings/plans/ln_plans.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/settings/sms/sms_settings.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/settings/capital_reserve/list.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/settings/capital_reserve/accounts.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/settings/sub_coa/relation/sub_coas_on_coa.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/percent_rate/rates_list.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/guarantee/guarantees_list_current.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/info_contract/form.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/leasing_objects/objects_list.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/mode_actions/form.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/conversion/conversion.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/grant_funds/form.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/plastic_card/list.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/plastic_card/crediting_cards.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/graphic/debt_form.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/graphic/perc_form.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/graphic/revenue_form.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/card/admission.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/graphic/prolong/main.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/operations/form.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/autoredemption.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/operations/monitoring/operations.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/file/files_list.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/class_quality_reserv/form.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/settings/action_purpose/list.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/settings/black_list/pinfl_black_list.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/settings/black_list/inn_black_list.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/operations/munis/operations.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/online/infokiosk/authorization.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/online/business_online/online_claims.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/online/infokiosk/monitoring.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/online/infokiosk/accounts.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/online/infokiosk/sverka.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/online/infokiosk/payments.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/mobile_overdraft/MPK_overdraft.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/mua_guar/companies_list.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/refs/insurance_companies/list.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/refs/loan_fam_business/people_list.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/refs/min_salary/min_salary_list.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/refs/loan_purposes/loan_purposes.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/refs/loan_providers/loan_providers.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/refs/phone_prefix/phone_prefixes.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/refs/resp_personal/personal_list.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/co/ref_terms/terms_list.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/refs/loan_allocation/allocations.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/refs/university/university_list.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/file/sub_categories.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/file/categories.jsp",
        "D:/iabs/iabs_core/src/main/webapp/ibs/ls/file/confirmation/conf_list.jsp",
    ]
    l = []
    for p in file_paths:
        l += buttons(p)
    # print(l)
    with open("card_buttons.txt", "w", encoding=encode) as f:
        f.writelines(l)
