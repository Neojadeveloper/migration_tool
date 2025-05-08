<%@ page contentType="text/html;charset=WINDOWS-1251" language="java"%><%
%><%@ page import="java.sql.*,java.util.*, uz.fido_biznes.cms.*" %><%
%><%@ page import="oracle.sql.*, oracle.jdbc.*" %><%
%><%@ taglib uri="/WEB-INF/cms.tld" prefix="t"%><%
%><jsp:useBean id="cods" class="iabs.oraDBConnection" scope="session" /><%
%><jsp:useBean id="stored" class="uz.fido_biznes.sql.StoredObject" scope="session"/><%
%><jsp:useBean id="storedObj" class="iabs.StoredObject" scope="session"/><%
%><jsp:useBean id="user" class="iabs.User" scope="session" /><%
    Connection conn = cods.getConnection();
    if (conn == null || user.getUserCode() == null)
        pageContext.setAttribute(Resource.SESSION_EXPIRED, Boolean.TRUE);
    Language lang = new Language(user.getLanguageIndex(), sentences);
    pageContext.setAttribute(Resource.STR_LANGUAGE, lang);
    //  storedObj.setConnection(conn, "70904");
//-------------------------------------------------------------------------------------------------
%>
<t:page>
    <%
		String themeId = (String)session.getValue("ibs.cms.themeId");
    String fClientCode = request.getParameter("fClientCode");
    String fClientName = request.getParameter("fClientName");
    String fLoanId = request.getParameter("fLoanId");
    String fMFO = request.getParameter("fMFO");
    
    String offerId     = "";
    String action = request.getParameter("action");
    String defFilterValue = request.getParameter("defFilterValue");
    String helpDate       = stored.execSelect("select to_char(add_months(setup.get_operday, -1),'dd.mm.yyyy') from dual");
    String headerCode = user.getHeaderCode();
    Integer parentLoanId = Util.parseInt(Util.nvl(stored.decryptValue(request.getParameter("parentLoanId"), "LN_CARD")));
    String en_parentLoanId = Util.nvl(request.getParameter("parentLoanId"));
    if (parentLoanId == null) {
        parentLoanId = -1;
    }
    String WHERE = "1=1";
    String module_code = "LN";
    String sessionName = "CARDS_LIST_LN";
    if (parentLoanId > 0) {
        WHERE = "parent_loan_id = " + parentLoanId;
    } else if (!"".equals(fClientCode + fClientName + fLoanId + fMFO)) {
        if (!("".equals(fClientCode) || fClientCode == null)) {
            WHERE = WHERE + " and CLIENT_CODE like '%" + fClientCode + "%'";
        }
        if (!("".equals(fLoanId) || fLoanId == null)) {
            WHERE = WHERE + " and LOAN_ID = " + fLoanId;
        }
        if (!("".equals(fMFO) || fMFO == null)) {
            WHERE = WHERE + " and FILIAL_CODE = '" + fMFO + "'";
        }
        if (!("".equals(fClientName) || fClientName == null)) {
            WHERE = WHERE + " and upper(CLIENT_NAME) like '%" + fClientName + "%'";
        }
    }
    boolean isHamkorBank = false;
    boolean isLimitsControlUsed = false;
    String userLevel = stored.execSelect("select instr(setup.Is_Headerlevel||setup.Is_Regionlevel, 'Y')  from dual");
    boolean isHeaderBank = !"0".equals(userLevel);//user.isHeaderBank();

    try {
        isHamkorBank = stored.execFunction("LN_Api.Is_Hamkor_Bank").equalsIgnoreCase("Y");

        isLimitsControlUsed = "1".equals(stored.execFunction("sys.diutil.bool_to_int(Ln_Api.Is_Limits_Control_Used)"));

        if (action != null) {
            ServletCallableStatement cs = new ServletCallableStatement(stored, request);
            if (action.equalsIgnoreCase("adjust")) {
                cs.setFunction("Ln_Api.Adjust_Loans_States");
                cs.setEncryptedParameter("loansIds", "LN_CARD");
                cs.setArrayNumberParameter("iLoans_Ids", "loansIds");
                cs.execute();
%>
    <script>alert('<%=Util.quotesEsc( cs.getStringResult())%>');</script>
    <%
    } else if (action.equalsIgnoreCase("close")) {
		cs.setProcedure("Ln_Api.Close_Loan");
        cs.setEncryptedParameter("loanId", "LN_CARD");
        cs.setNumberParameter("iLoan_ID", "loanId");
        cs.execute();
    %>
    <script>alert("<%=lang.get(si_alert1)%>");</script>
    <%
    } else if (action.equalsIgnoreCase("restore")) {
        cs.setFunction("Ln_Api.Set_Loans_Normal");
        cs.setEncryptedParameter("loansIds", "LN_CARD");
        cs.setArrayNumberParameter("iLoans_Ids", "loansIds");
        cs.execute();
    %>
    <script>alert('<%=Util.quotesEsc( cs.getStringResult())%>');</script>
    <%
    } else if (action.equalsIgnoreCase("requestLimits")) {
        cs.setProcedure("Ln_Api.Request_Crediting_Limits");
        cs.setEncryptedParameter("loanId", "LN_CARD");
        cs.setNumberParameter("iLoan_Id", "loanId");
        cs.execute();
    %>
    <script>alert("<%=lang.get(si_alert2)%>");</script>
    <%
    } else if (action.equalsIgnoreCase("setSignEBRD")) {
        cs.setProcedure("Ln_Api.Set_Sign_EBRD");
        cs.setEncryptedParameter("loansIds", "LN_CARD");
        cs.setArrayNumberParameter("iLoans_Ids", "loansIds");
        cs.execute();
    %>
    <script>alert("<%=lang.get(si_alert3)%>");</script>
    <%
    } else if (action.equalsIgnoreCase("transferToLNB")) {
        cs.setProcedure("Ln_Api2.Transfer_To_Lnb");
        cs.setEncryptedParameter("loansIds", "LN_CARD");
        cs.setArrayNumberParameter("i_Loans_Ids", "loansIds");
        cs.execute();
    %>
    <script>alert("<%=lang.get(si_alert3)%>");</script>
    <%
    } else if (action.equalsIgnoreCase("transferToLNB")) {
        cs.setProcedure("Ln_Api3.Cancel_Bs_Count");
        cs.setEncryptedParameter("loansIds", "LN_CARD");
        cs.setArrayNumberParameter("i_Loans_Ids", "loansIds");
        cs.execute();
    %>
    <script>alert("<%=lang.get(si_alert3)%>");</script>
    <%
                }

            }
            if (request.getParameter("f38") != null) {
                ServletCallableStatement cs = new ServletCallableStatement(stored, request);
                cs.setProcedure("User_Session.Put_Varchar2");
                cs.setString("i_key", "ln_main_account");
                cs.setStringParameter("i_value", "f38");
                cs.execute();
            }
            if (request.getParameter("f39") != null) {
                ServletCallableStatement cs = new ServletCallableStatement(stored, request);
                cs.setProcedure("User_Session.Put_Varchar2");
                cs.setString("i_key", "ln_inspector");
                cs.setStringParameter("i_value", "f39");
                cs.execute();
            }
        } catch (SQLException ex) {
            Util.alertUserMessage(ex, out);
        }
        try {
            module_code = stored.execFunction("Ln_Api2.Get_Module_Code");
            sessionName = stored.execFunction("Ln_Api2.Get_Module_Code");
        } catch (Exception ex) {

        }
        String formTitle = lang.get(si_form_title) + "<div id=sumControls></div>";
    %><t:form titleText="<%= formTitle %>" minHeight="fill" minWidth="fill">
        <object id="plugin0" type="application/x-fidoprint" width="1" height="1">
            <param name="onload" value="pluginLoaded"/>
        </object>
        <script src="../style/jquery.min.js"></script>
        <script>
            let btns = <%= stored.execFunction("Dw_Api.Get_Button_As_Json('LN', '60')")%>;
            let docTypeCode = "LNCONTRACT";

            function onAction() {
                ajax.load({
                    url: "/ibs/ls/init_params.jsp?docId=" + encodeURIComponent(getData(28)) + "&docTypeCode=" + docTypeCode,
                    onSuccess: function (d) {
                        go({
                            url: "/ibs/ls/card/main.jsp?parentLoanId=" + encodeURIComponent("<%= en_parentLoanId %>"),
                            param: {
                                url: "/ibs/ls/accounts/acc_list.jsp?1=1&loanId=" + encodeURIComponent("<%= en_parentLoanId %>"),
                                folderId: d
                            }
                        });
                    }
                });
            }

            function onSelect() {
                parent.docId = encodeURIComponent(getData(28));
                parent.docTypeCode = docTypeCode;
                var t = getDOM('a1');
                if (getData(40) != '') {
                    t.parentNode.parentNode.getElementsByTagName('span')[0].innerText = "<%=lang.get(si_loan_id)%> / <%=lang.get(si_loan_uid)%>";
                    t.value += " / " + getData(40);
                } else {
                    t.parentNode.parentNode.getElementsByTagName('span')[0].innerText = "<%=lang.get(si_loan_id)%>";
                }
                var pr_code = getData(42);
                if (pr_code == 3) {
                    getDOM("opComp").disabled = false;
                } else {
                    getDOM("opComp").disabled = true;
                }
                if (getData(44) == 2) {
                    getDOM("famDocs").disabled = false;
                } else {
                    getDOM("famDocs").disabled = true;
                }
                offerActiv();
                // Dogovor tanlanganda monitoringni tekshirish
                prepare_monitorng_option();
            }

            function onLoad() {
                var DataExists = dataExist();
                //getDOM('prolongHis').disabled     = !DataExists;
                //getDOM('growingHis').disabled     = !DataExists;
                //getDOM('trialHis').disabled       = !DataExists;
                getDOM('modifyLnState').disabled = !DataExists;
                if (is.def(getDOM('btnQRCode')))
                    getDOM('btnQRCode').disabled = !DataExists;
                // getDOM('sumControls').innerHTML = '<img id=\'qr_code\' src=\'../util/qrcode.png\'/>'

            }

            function offerActiv() {
                ajax.load({
        url: 'offers.jsp',
                    POST: {
                        request: 'viewOfferFile',
                        productId: getData(-42),
                        loanId: getData(28)
                    },
        onSuccess: function (d) {
          if (typeof d === 'undefined'){
             getDOM("btnOffers").disabled = true;
          }else {
             getDOM("btnOffers").disabled = false;
          }
        },
        onError: function (err) {
            getDOM("btnOffers").disabled = true;
        }
                });
            }

            function isAnyLoanChecked() {
                var isAnyLoanChecked = false;
                for (var i = tblForm.elements.length; --i >= 0;) {
                    if (tblForm.elements[i].type === 'checkbox' && tblForm.elements[i].checked) {
                        isAnyLoanChecked = true;
                        break;
                    }
                }
                return isAnyLoanChecked;
            }

            function adjustLoansStates() {
                if (isAnyLoanChecked())
                    go({
                        form: tblForm,
                        param: {
                            action: 'adjust'
                        }
                    });
                else
                    go({
                        form: tblForm,
                        param: {
                            action: 'adjust',
                            loansIds: getData(28)
                        }
                    });
            }

            function closeLoan() {
                if (confirm('<%=lang.get(si_confirm1)%>')) {
                    go({
                        form: tblForm,
                        param: {
                            action: 'close',
                            loanId: getData(28)
                        }
                    });
                }
            }

            function setLoansNormal() {
                if (isAnyLoanChecked() && confirm('<%=lang.get(si_confirm2)%>')) {
                    go({
                        form: tblForm,
                        param: {
                            action: 'restore'
                        }
                    });
                } else if (confirm('<%=lang.get(si_confirm2)%>')) {
                    go({
                        form: tblForm,
                        param: {
                            action: 'restore',
                            loansIds: getData(28)
                        }
                    });
                }
            }

            function openProlongHistory() {
                go({
                    url: "/ibs/ls/graphic/prolong/prolong_history.jsp?LOAN_ID=" + encodeURIComponent(getData(28)) + "&TYPE=PROLONG",
                    target: "new",
                    lock: false,
                    arg: "channelmode=1,directories=0,location=0,menubar=1,toolbar=0,resizable=1,scrollbars=1,status=1"
                });
            }

            function openGrowingHistory() {
                go({
                    url: "/ibs/ls/operations/history.jsp?loanId=" + encodeURIComponent(getData(28)) + "&ACTION_CODE=GROWING",
                    target: "new",
                    lock: false,
                    arg: "channelmode=1,directories=0,location=0,menubar=1,toolbar=0,resizable=1,scrollbars=1,status=1"
                });
            }

            function openTransferToTrialHistory() {
                go({
                    url: "/ibs/ls/operations/history.jsp?loanId=" + encodeURIComponent(getData(28)) + "&ACTION_CODE=COURT",
                    target: "new",
                    lock: false,
                    arg: "channelmode=1,directories=0,location=0,menubar=1,toolbar=0,resizable=1,scrollbars=1,status=1"
                });
            }

            function openOverdraftLimit() {
                go({
                    url: '../overdraft/overdraft_limit.jsp?loan_id=' + encodeURIComponent(getData(28)),
                    target: "modalE",
                    lock: false,
                    arg: "channelmode=1,directories=0,location=0,menubar=1,toolbar=0,resizable=1,scrollbars=1,status=1"
                });
            }

            function cancelCount() {
                if (getData(42) != '-6') return;
                go({form: tblForm, param: {loanId: getData(28), action: "send"}, lock: false, callback: modalResponse});
            }

            function requestLimits() {
                if (confirm('<%=lang.get(si_confirm3)%>')) {
                    go({
                        form: tblForm,
                        param: {
                            action: 'requestLimits',
                            loanId: getData(28)
                        }
                    });
                }
            }

            function setSignEBRD() {
                if (!isAnyLoanChecked()) {
                    alert('<%=lang.get(si_alert4)%>');
                    return;
                }

                if (confirm('<%=lang.get(si_confirm4)%>')) {
                    go({
                        form: tblForm,
                        param: {
                            action: 'setSignEBRD'
                        }
                    });
                }
            }

            function transferLNB() {
                if (isAnyLoanChecked())
                    go({
                        form: tblForm,
                        param: {
                            action: 'transferToLNB'
                        }
                    });
                else
                    go({
                        form: tblForm,
                        param: {
                            action: 'transferToLNB',
                            loansIds: getData(28)
                        }
                    });
            }

            function modifyLoansStates() {
                var action = getDOM('actions').getValue();
                if (action == 'adjust')
                    adjustLoansStates();
                else if (action == 'close')
                    closeLoan();
                else if (action == 'restore')
                    setLoansNormal();
                else if (action == 'requestLimits')
                    requestLimits();
                else if (action == 'setSignEBRD')
                    setSignEBRD();
                else if (action == 'transferLNB')
                    transferLNB();
                else if (action == 'prolongHis')
                    openProlongHistory();
                else if (action == 'growingHis')
                    openGrowingHistory();
                else if (action == 'trialHis')
                    openTransferToTrialHistory();
                else if (action == 'showOverdraftGraph')
                    openOverdraftLimit();
                else if (action == 'docs')
                    docs();
                else if (action == 'contract')
                    contract();
                else if (action == 'oferta')
                    file_print(3);
                else if (action == 'warning')
                    warning();
                else if (action == 'guarantors')
                    guarantors();
                else if (action == 'compensation')
                    compensation();
                else if (action == 'cancelBsCount')
                    cancelCount();
                // loan_type 34 uchun shablon monitoring ishlashi uchun
                else if (action == 'showMonitoring')
                    showMonitoring();
                else if (action == 'showMonitoringIpoteka')
                    showMonitoringIpoteka();
                else
                    alert(["<%=lang.get(si_alert5)%> : '", action, "'"].join(""));
            }

            function qrForm() {
                go({
                    url: 'qrcode.jsp',
                    target: 'modalE',
                    param: {
                        id: getData(28)
                    },
                    dialogHeight: 350,
                    dialogWidth: 800
                });
            }

            function guarantors() {
                go({
                    url: '../reports/guar_contract.jsp',
                    target: 'modalE',
                    param: {
                        loan_id: getData(28)
                    },
                    dialogHeight: 400,
                    dialogWidth: 600
                });
            }

            function compensation() {
                go({
                    url: '../reports/compensation_reestr.jsp',
                    target: 'modalE',
                    dialogHeight: 150,
                    dialogWidth: 400
                });
            }

            // function graphic(){
            // go({url:'../reports/graphic_debt.jsp', target:'modalE', param:{loan_id:getData(1)}, dialogHeight:400, dialogWidth:600});
            // }
            function printFile() {
                go({
                    url: '../reports/loan_claim.jsp',
                    target: 'modalE',
                    param: {
                        loan_id: getData(28)
                    },
                    dialogHeight: 400,
                    dialogWidth: 600
                });
            }

            function plugin() {
                return document.getElementById('plugin0');
            }

            function getContract(fileId, temp_type) {
                getFile(fileId, temp_type);

                go({
                    url: '../reports/graphic_debt.jsp',
                    param: {
                        loan_id: getData(28)
                    },
                    target: 'modalE',
                    dialogHeight: 200,
                    dialogWidth: 400,
                    lock: false
                });
            }

            function contract() {
                ajax.load({
                    url: '/ibs/ls/util/references2.jsp',
                    POST: {
                        request: 'get_template_file_id',
                        product_id: getData(42),
                        template_type: 1
                    },
                    onSuccess: function (d) {
                        getContract(d[0], "L");
                    },
                    onError: function (d) {
                        alert(d);
                    }
                });
            }

            function warning() {
                ajax.load({
                    url: '/ibs/ls/util/references2.jsp',
                    POST: {
                        request: 'get_template_file_id',
                        product_id: getData(42),
                        template_type: 2
                    },
                    onSuccess: function (d) {
                        getFile(d[0], "L");//getWarningLetter(d[0], "L");
                    },
                    onError: function (d) {
                        alert(d);
                    }
                });
            }

            function file_print(t) {
                ajax.load({
                    url: '/ibs/ls/util/references2.jsp',
                    POST: {
                        request: 'get_template_file_id',
                        product_id: getData(42),
                        template_type: 1
                    },
                    onSuccess: function (d) {
                        getFile(d[0], "L");
                        //getContract(d[0], "L");
                    },
                    onError: function (d) {
                        alert(d);
                    }
                });
            }

            function guarantors() {
                ajax.load({
                    url: '/ibs/ls/util/references2.jsp',
                    POST: {
                        request: 'get_template_file_id',
                        product_id: getData(42),
                        template_type: 4
                    },
                    onSuccess: function (d) {
                        getFile(d[0], "L");
                    },
                    onError: function (d) {
                        alert(d);
                    }
                });
            }

            /*
            function guarantors() {
              go({
                url: '../reports/guar_contract.jsp',
                target: 'modalE',
                param: {
                  loan_id: getData(1)
                },
                  dialogHeight: 400,
                dialogWidth: 600
              });
            }
            */
            $(function () {
                /*$('#f3').focus(function () {
                  $(this).stop().animate({
                    width: 350
                  }, 500)
                  });
               $('#f3').focusout(function () {
                 $(this).stop().animate({
                   width: 120
                 }, 500)
                 }); */
                $('#sumControls').append("<span><img class=\"qrcode\" onclick=\"qrForm()\" src=\"../util/qrcode.png\" alt=\"QRcode\" class=\"qrcode2\" width=\"20\" height=\"20\" /></span>")
            });

            function goBack() {
                go({url: 'parent_cards_list.jsp'});
            }

            function addChildLoan() {
                go({
                    url: 'form.jsp?parentLoanId=' + encodeURIComponent("<%=en_parentLoanId%>"),
                    target: 'modalE',
                    dialogWidth: 1350,
                    dialogHeight: screen.availHeight,
                    lock: false,
                    callback: modalResponse
                });
            }

            function showCreditCycle() {
                go({
                    url: '/ibs/ls/credit_card/send_reject_claims.jsp',
                    target: 'modalE',
                    dialogWidth: 1000,
                    dialogHeight: 800,
                    lock: false,
                    callback: modalResponse
                });
            }

            function onBeforeInit() {
                getDOM('f3').style.width = '150px';
                if (screen.availWidth < 1200) {
                    var o = getDOM('filterControls')
                    o.innerHTML = o.innerHTML.replace('<%=lang.get(si_condition)%>:', '');

                    if (is.def('f5')) hideDOM('f5');
                }
            }

            function showMonitoring() {
                go({
                    url: '/ibs/ls/card/monitoring.jsp',
                    param: {loanId: getData(28)},
                    target: 'modalE',
                    dialogWidth: 400,
                    dialogHeight: 200,
                    callback: function (d) {
                        if (d == null) return;
                        ajax.load({
                            url: '/ibs/ls/card/requests.jsp',
                            POST: {
                                request: 'get_file_id_for_monitoring',
                                date: d['date']
                            },
                            onSuccess: function (d) {
                                getFile(d[0], "M");
                            },
                            onError: function (d) {
                                alert(d);
                            }
                        });
                    }
                });
            }

            function showMonitoringIpoteka() {
                go({
                    url: '/ibs/ls/card/monitoring.jsp',
                    param: {loanId: getData(28)},
                    target: 'modalE',
                    dialogWidth: 400,
                    dialogHeight: 200,
                    callback: function (d) {
                        if (d == null) return;
                        ajax.load({
                            url: '/ibs/ls/util/references2.jsp',
                            POST: {
                                request: 'Get_File_Id_For_Mon_Iptka',
                                date: d
                            },
                            onSuccess: function (d) {
                                getFile(d[0], "M");
                            },
                            onError: function (d) {
                                alert(d);
                            }
                        });
                    }
                });
            }

            function prepare_monitorng_option() {
                // testlash uchun
                //getDOM('showMonitoringOption').disabled = false; return;

                //real
                if (!dataExist()) {
                    getDOM('showMonitoringOption').disabled = true;
                    getDOM('showMOptionIpoteka').disabled = true;
                } else {
                    //LOAN_TYPE_CODE
                    if (getData(27) != '34') {
                        getDOM('showMonitoringOption').disabled = true;
                    } else {
                        getDOM('showMonitoringOption').disabled = false;
                    }
                    if (getData(27) != '24') {
                        getDOM('showMOptionIpoteka').disabled = true;
                    } else {
                        getDOM('showMOptionIpoteka').disabled = false;
                    }
                }
            }

            function getFile(fileId, temp_type) {
                go({
                    url: "/ibs/sb/sb/print_form.jsp?module_code=LN&order_print=N",
                    param: {
                        file_id: fileId,
                        loan_id: getData(67),
                        claim_id: '',
                        temp_type: temp_type
                    },
                    target: "modalE",
                    dialogHeight: 200,
                    dialogWidth: 400,
                    lock: false
                });
            }

            function getFilePDF() {
                go({
                    url: "/ibs/ls/templates.jsp",
                    param: {
                        rep_id: 2,
                        lang_name: 2
                    },
                    target: "modalE",
                    dialogHeight: 200,
                    dialogWidth: 400,
                    lock: false
                });
            }

            function modalResponse(r) {
                if (r) go({});
            }

            function docs() {
                go({
                    url: "family_docs.jsp?loanId=" + encodeURIComponent(getData(28)),
                    //param: {
                    //  loanId: getData(28)
                    //},
                    target: "modalE",
                    dialogWidth: 1000,
                    dialogHeight: 700
                });
            }

            function viewOffer() {
                ajax.load({
                    url: 'offers.jsp',
                    POST: {
                        request: 'viewOfferFile',
                        productId: getData(-42),
                        loanId: getData(28)
                    },
                    onSuccess: function (d) {
                        if (typeof d === 'undefined') {
                            alert("bu product uchun offerta mavjut emas!");
                        } else {
                            //alert("here you are!");
                            go({url: "/ibs/ls/file/offers/download.jsp?fileId=" + encodeURIComponent(d), lock: false});
                        }
                    },
                    onError: function (err) {
                        alert(err)
                    }
                });
            }
        </script>
        <style>
            #sumControls {
                position: absolute;
                right: 40px;
                top: 0;
                top: var(--size-8, 0);
                color: white !important;
            }

            #sumControls b {
                color: white !important;
            }

            select#actions {
                width: 280px;
                text-indent: 4px;
                cursor: pointer;
            }

            .qrcode {
                position: absolute;
                top: 0;
                top: var(--size-3, 0);
                right: -30px;
            }

            .filter-box {
                background-color: #E4E8FF;
                background-color: var(--color-white);
            }

            .isCross .formToolbar {
                border-spacing: var(--size-4, 4px);
                padding-bottom: 0px;
            }

            #filterControls {
                font-style: italic;
                color: #1E396D;
                color: var(--color-black, #1E396D);
                background-color: #E4E8FF;
                background-color: var(--color-blue10, #E4E8FF);
            }

            .isCross #filterControls {
                padding: 4px 0px !important;
            }

            .isCross #filterControls * {
                margin-bottom: 0px !important;
            }

            select#f5 {
                width: 275px;
            }
        </style>
        
        <table align=center class=formToolbar>
            <tr>
                <td><select id="actions">
                    <option><%=lang.get(si_loan_action)%></option>
                    <optgroup id="loan_action" label="<%=lang.get(si_loan_action)%>">
                        <option id="adjust" value="adjust"><%=lang.get(si_sync_status)%>
                        </option>
                        <option id="close"  value="close"><%=lang.get(si_loan_close)%>
                        </option>
                        <%
                            if (isHamkorBank) {
                        %>
                        <option id="set_sign_ebrd" value="setSignEBRD">
                        <%=lang.get(si_set_sign)%><%
                        }
                        if (isHeaderBank) {
                    %>
                        <option id="restore" value="restore"><%=lang.get(si_restore)%>
                                <%
                      }%>
                    </optgroup>
                    <%
                        if (isLimitsControlUsed && !isHeaderBank) {
                    %>
                    <optgroup></optgroup>
                    <optgroup id="limits" label="<%=lang.get(si_limits)%>">
                        <option id="request_limits" value="requestLimits"><%=lang.get(si_limit_request)%>
                    </optgroup>
                    <%
                        }
                    %>
                    <optgroup id="others" label="<%=lang.get(si_others)%>">
                        <option id="prolong_his" value=prolongHis><%=lang.get(si_prolong_hisory)%>
                        <option id="growing_his" value=growingHis><%=lang.get(si_growing_history)%>
                        <option id="trial_his" value=trialHis><%=lang.get(si_trial_history)%>
                        <option id="transfer_hNB" value=transferLNB><%=lang.get(si_transfer_to_LNB)%>
                    </optgroup>
                    <optgroup id="overdraft" label="<%=lang.get(si_overdraft)%>">
                        <option id="show_overdraft_graph" value="showOverdraftGraph"><%=lang.get(si_show_Limit_graph)%>
                        <option id="cancel_bs_count" value="cancelBsCount"><%=lang.get(si_cancel_bs_count)%>
                    </optgroup>
                    <optgroup id="documents" label="<%=lang.get(si_documents)%>">
                        <option id="contract" value="contract"><%=lang.get(si_contract)%>
                        </option>
                        <option id="guarrantors" value="guarantors"><%=lang.get(si_guarantors)%>
                        </option>
                        <option id="opComp" value="compensation"><%=lang.get(si_compensation)%>
                        </option>
                        <option id="oferta" value="oferta"><%=lang.get(si_oferta)%>
                        </option>
                        <option id="warning" value="warning"><%=lang.get(si_warning)%>
                        </option>
                        <option id="famDocs" value="docs"><%=lang.get(si_docs)%>
                        </option>
                    </optgroup>
                    <optgroup id="monitoring" label="<%=lang.get(si_monitoring)%>">
                        <option
                                id="showMonitoringOption"
                                value="showMonitoring"
                                disabled=""><%=lang.get(si_act_monitoring)%>
                        </option>
                        <option
                                id="showMOptionIpoteka"
                                value="showMonitoringIpoteka"
                                disabled=""><%=lang.get(si_monitoring_ipoteka)%>
                        </option>
                    </optgroup>
                </select>
                    <input type=button id="modifyLnState" value="<%=lang.get(si_modify_ln_states)%>"
                           onclick="modifyLoansStates( )">
                    <input type="button" id="btnContract" value="<%=lang.get(si_contract)%>"
                           onclick="contract( )">
                    <input type=button hidden="true" id="btnAddChildLoan" value="<%=lang.get(si_add_child_loan)%>"
                           onclick="addChildLoan( )">
                    <input type=button id=btnOffers disabled value="<%=lang.get(si_view_offer)%>"
                           onclick="viewOffer( )"/>
                    <div id=sumControls style="display: none !important;"></div>
                <td align="right" id="tableControls">
                            <% if ( parentLoanId > 0 ) {%>
                    <input id="btn_back" type=button name=btnBack value="<%= lang.get(si_btn_back) %>" onclick="goBack()"
                           style="color:blue;font-weight:bold;">
                            <% }%>
            <tr class="filter-box">
                <td align=center colspan="2" id=filterControls ></td>
        </table>
        <t:table from="LN_V_CARD" where="<%=WHERE%>" sessionName="<%= sessionName %>">
            <t:field id="60" name="CLIENT_UID" label="<%=si_client_uid%>">
                <t:filter operator="_like_" size="10" mask="10|0-9"/>
            </t:field>
            <% if ("09002".equals(headerCode)) { %>
            <t:field id="61" name="nbu_card_id" labelText="NBU CARD ID">
                <t:filter operator="_like_" size="90"/>
            </t:field>
            <% } %>
            <t:field id="80" name="BRANCH_ID" label="<%= si_branch_id %>">
                <t:filter mask="5|0-9" operator="_like_" size="5"/>
            </t:field>
            <t:field id="1" name="LOAN_ID" labelText="<span></span>">
                <t:filter mask="10|0-9" label="<%= si_loan_id %>" showInGrid="" size="10" value="0"/>
            </t:field>
            <t:field id="67" name="LOAN_ID" encrypted="Y" entityName="LN_CARD"/>
            <t:field id="55" name="CLAIM_ID" label="<%= si_claim_id %>">
                <t:filter mask="10|0-9" size="10"/>
            </t:field>
            <t:field id="28" name="LOAN_ID" encrypted="Y" entityName="LN_CARD"/>
            <% if (isHeaderBank) { %>
            <t:field id="4" name="FILIAL_CODE" label="<%= si_filial_code %>">
                <t:filter size="4" mask="mfo" operator="like_" referenceName="filials"
                          referenceURL="/ibs/ls/util/references3.jsp" requestName="filials"
                          requestURL="/ibs/ls/util/references3.jsp"/>
            </t:field>
            <% } else { %>
            <t:field id="4" name="FILIAL_CODE" label="<%= si_filial_code %>"/>
            <% } %>
            <t:field id="66" name="LOCAL_CODE" label="<%= si_local_code %>">
                <t:filter showInGrid="" size="4" mask="5|0-9A-z" referenceName="locals"
                          referenceURL="/ibs/ls/util/refs.jsp" requestName="getLocalName"
                          requestURL="/ibs/ls/util/refs.jsp"/>
            </t:field>
            <t:field id="30" name="NIK_ID" label="<%= si_niki_id %>">
                <t:filter mask="10|0-9" showInGrid="" size="10"/>
            </t:field>
            <t:field id="2" name="CLIENT_CODE" label="<%= si_client_code %>">
                <t:filter mask="8|0-9" operator="like" showInGrid="" size="10"/>
            </t:field>
            <t:field id="3" name="CLIENT_NAME" label="<%= si_client_name %>" type="quote">
                <t:filter size="90" operator="_search_" showInGrid=""/>
            </t:field>
            <t:field id="48" name="INN" label="<%= si_inn %>">
                <t:filter mask="9|0-9" size="10"/>
            </t:field>
            <t:field id="75" name="PINFL"										label="<%= si_pinfl %>" >
		<t:filter mask="14|0-9" size="15" />
	    </t:field>
            <t:field id="49" name="DOC_NUMBER" label="<%= si_doc_number %>">
                <t:filter mask="{2|A-Z}-{7|0-9}" size="10"/>
            </t:field>
            <t:field id="44" name="CLIENT_SUBJECT_CODE" label="<%= si_CL_SUBJECT_CODE %>">
                <t:filter
                        optionSQL="select '<option value=''' || CODE || '''>' || CODE || ' - ' || NAME from v_subject_type"/>
            </t:field>
            <t:field id="45" name="CLIENT_TYPE" label="<%= si_CLIENT_TYPE %>">
                <t:filter
                        optionSQL="select '<option value=''' || CODE || '''>' || CODE || ' - ' || NAME from ref_type_client_v"/>
            </t:field>
            <t:field id="46" name="BORROWER" label="<%= si_BORROWER %>">
                <t:filter
                        optionSQL="select '<option value=''' || ALL_CODE || '''>' || ALL_CODE || ' - ' || NAME from ln_v_borrower"/>
            </t:field>
            <t:field id="43" name="PRODUCT_ID||' : '||PRODUCT_NAME" label="<%= si_product %>" type="quote"/>
            <t:field id="-42" name="PRODUCT_ID" encrypted="Y" entityName="LN_PRODUCTS"/>
            <t:field id="42" name="PRODUCT_ID" label="<%= si_product %>">
                <t:filter mask="12|0-9-" referenceName="product2" referenceURL="/ibs/ls/util/references2.jsp"
                          requestName="product2" requestURL="/ibs/ls/util/references2.jsp"/>
            </t:field>

            <t:field id="70" name="GRAPH_CALC_TYPE_NAME" label="<%= si_calculation %>">
            </t:field>

            <t:field id="71" name="GRAPH_CALC_TYPE" label="<%= si_calculation %>">
                <t:filter
                        optionSQL="select '<option value=''' || CODE || '''>' || NAME from Ln_v_References where object_name = 'IS_ANNUITET'"/>
            </t:field>

            <t:field id="6" name="CONDITION_NAME" label="<%= si_condition %>" type="quote"/>
            <t:field id="9" name="CLAIM_NUMBER" label="<%= si_claim_number %>">
                <t:filter mask="5|0-9" size="5"/>
            </t:field>
            <t:field id="10" name="LOAN_NUMBER" label="<%= si_loan_number %>">
                <t:filter mask="5|0-9" size="5"/>
            </t:field>
            <t:field id="13" name="CONTRACT_CODE" label="<%= si_contract_code %>" type="quote">
                <t:filter mask="14|" size="14"/>
            </t:field>
            <t:field id="14" name="CONTRACT_DATE" label="<%= si_contract_date %>"/>
            <t:field id="16" name="OPEN_DATE" label="<%= si_open_date %>" type="date">
                <t:filter mask="date" operator="range"/>
            </t:field>
            <t:field id="17" name="CLOSE_DATE" label="<%= si_close_date %>" type="date">
                <t:filter mask="date" operator="range"/>
            </t:field>
			<t:field id="81" name="change_condition_date"			label="<%= si_date_modify %>" type="date">
			    <t:filter mask="date" operator="range"/>
	        </t:field>
            <t:field id="19" name="CURRENCY_CODE" label="<%= si_currency %>">
                <t:filter mask="{3|0-9}" size="3" operator="like_" referenceName="currency"
                          referenceURL="/ibs/ls/util/references3.jsp" requestName="currency"
                          requestURL="/ibs/ls/util/references3.jsp"/>
            </t:field>
            <t:field id="20" name="AMOUNT" label="<%= si_summ %>" type="sum">
                <t:filter mask="number(20,2)" operator="range" size="15"/>
                <t:sum label="<%=si_total_amount%>" type="sum"/>
            </t:field>
            <t:field id="26" name="LOAN_TYPE_NAME" label="<%= si_loan_type %>" type="quote"/>
            <t:field id="27" name="LOAN_TYPE_CODE" label="<%= si_loan_type %>">
                <t:filter mask="2|0-9" operator="like_" referenceName="loanTypes"
                          referenceURL="/ibs/ls/util/references3.jsp" requestName="loanTypes"
                          requestURL="/ibs/ls/util/references3.jsp"/>
            </t:field>

            <t:field id="33" name="PURPOSE_CODE" label="<%= si_loan_purpose %>">
                <t:filter mask="6|0-9" operator="like_" referenceName="purposes"
                          referenceURL="/ibs/ls/util/references3.jsp" requestName="purposes"
                          requestURL="/ibs/ls/util/references3.jsp"/>
            </t:field>
            <t:field id="7" name="CLAIM_TYPE_CODE" label="<%= si_claim_type %>">
                <t:filter
                        optionSQL="select '<option value=''' || CODE || '''>' || CODE || ' - ' || NAME from LN_V_CLAIM_TYPE"/>
            </t:field>
            <t:field id="8" name="CLAIM_TYPE_NAME" label="<%= si_claim_type %>" type="quote"/>
            <t:field id="5" name="CONDITION_CODE" label="<%= si_condition %>" type="quote">
                <t:filter value="11" size="11" operator="like_" showInGrid=""
                          optionSQL="select '<option value=''' || CODE || '''>' || NAME from LN_V_LOAN_STATUS_EXT t"/>
            </t:field>
            <t:field id="31" name="NK_STATE_CODE" label="<%= si_niki_state %>">
                <t:filter
                        optionSQL="select '<option value=''' || CODE || '''>' || CODE || ' - ' || NAME from NK_V_REQUEST_CONDITIONS"/>
            </t:field>
            <t:field id="32" name="NK_STATE_NAME" label="<%= si_niki_state %>" type="quote"
                     color="d(31)!='O'?'red':'black'"/>
            <t:field id="34" name="PURPOSE_NAME" label="<%= si_loan_purpose %>" type="quote"/>
            <t:field id="35" name="Eco_Sec_Name" label="<%= si_eco_sec %>" type="quote"/>
            <t:field id="36" name="Err_Mess" label="<%= si_nk_err_mess %>" type="quote"
                     color="d(31)!='O'?'red':'black'"/>
            <t:field id="37" name="Nvl(SALDO, 0)" label="<%= si_saldo %>" type="sum" color="'black; font-weight:bold;'">
                <t:filter mask="number(20,2)" operator="range"/>
                <t:sum label="<%=si_total_saldo%>" type="sum"/>
            </t:field>
            <t:field id="38" name="Ln_Api2.Has_Account_In_Card(Loan_Id, 1)" label="<%= si_main_account %>">
                <t:filter mask="20|0-9" size="25"/>
            </t:field>
            <t:field id="39" name="Ln_Api2.Has_Inspector_In_Card(Loan_Id)" label="<%= si_inspector %>">
                <t:filter mask="100|" size="90"/>
            </t:field>
            <t:field id="40" name="LOAN_UID" label="<%= si_loan_uid %>">
                <t:filter mask="10|" size="15"/>
            </t:field>

            <t:field id="41" name="Nvl(UNUSED_SUMM_LOAN, 0)" label="<%= si_unused_summ_loan %>" type="sum"/>
            <t:field id="47" name="client_id"/>
            <t:field id="50" name="Card_Number" label="<%=si_card_number%>">
                <% if (module_code.equals("LNO") || module_code.equals("LNCC")) {%>
                <t:filter operator="_like_" mask="24|0-9"/>
                <%}%>
            </t:field>
            <t:field id="51" name="Card_Name" label="<%=si_card_type%>" type="quote"/>
            <t:field id="53" name="bs_state" label="<%=si_bs_state%>"/>
            <t:field id="54" name="bs_state_name" label="<%=si_bs_state%>" type="quote"/>
            <t:field id="56" name="nibbd_code" label="<%=si_nibbd_code%>">
                <t:filter operator="_like_" size="15" mask="10|0-9"/>
            </t:field>
            <t:field id="52" name="Card_Type" label="<%=si_card_type%>">
                <% if (module_code.equals("LNO") || module_code.equals("LNCC")) {%>
                <t:filter option="<%=si_option%>"/>
                <%}%>
            </t:field>
            <t:field id="57" name="department_name" label="<%= si_departament_id %>" type="quote"/>
            <t:field id="58" name="department_id" label="<%= si_departament_id %>">
                <t:filter
                        optionSQL="select '<option value=''' || department_id || '''>' || department_id||' - ' ||name from ln_v_blank_departments"/>
            </t:field>
            <t:field id="63" name="creator_name" label="<%= si_creator_code %>" type="quote"/>
            <t:field id="64" name="creator_code" label="<%= si_creator_code %>">
                <t:filter option="<%=si_option1%>"/>
            </t:field>
            <t:field id="65" name="mobile_number" label="<%= si_mobile_number %>"/>
            <t:grid page="25" withoutCursor="">
                <t:column for="28" type="checkbox" name="loansIds"/>
                <t:column for="4"/>
                <t:column for="80"/>
                <t:column for="66"/>
                <t:column for="2"/>
                <t:column for="3" align="left"/>
                <t:column for="9"/>
                <t:column for="10"/>
                <t:column for="13"/>
                <t:column for="19"/>
                <t:column for="20" align="right"/>
                <t:column for="37" align="right"/>
                <t:column for="41" align="right"/>
                <t:column for="70"/>
<% if (module_code.equals("LNO") || module_code.equals("LNCC")) {%>
                <t:column for="50"/>
<%}%>
                <t:column for="6"/>
				<t:column for="81"/>
                <% if (module_code.equals("LNMO")) {%>
                <t:column for="65"/>
                <%}%>
                <% if ("09002".equals(headerCode)) { %>
                <t:column for="61"/>
                <t:column for="75"/>
                <%}%>
                <t:foot>
                    <t:row>
                        <t:cell for="1" size="90%"/>
                        <t:cell for="16" size="90%"/>
                        <t:cell for="17" size="90%"/>
                        <t:cell for="32" size="90%"/>
                    </t:row>
                    <t:row>
                        <% if (module_code.equals("LNO") || module_code.equals("LNCC")) {%>
                        <t:cell for="51" size="100%" colspan="1"/>
                        <%}%>
                        <t:cell for="8" size="90%"/>
                        <t:cell for="43" size="90%" align="left"/>
                        <t:cell for="30" size="90%"/>
                        <t:cell for="65" size="90%"/>
                    </t:row>
                    <t:row>
                        <t:cell colspan="3" for="26" size="96%" align="left"/>
                        <t:cell for="63" size="90%"/>
                    </t:row>
                    <% if (module_code.equals("LNO") || module_code.equals("LNCC")) {%>
                    <t:row>
                        <t:cell for="34" colspan="5" size="96%" align="left"/>
                        <t:cell for="51" size="90%" colspan="1"/>
                    </t:row>
                    <t:row>
                        <t:cell colspan="5" for="35" size="96%" align="left"/>
                        <t:cell for="54" size="90%" align="left"/>
                    </t:row>
                    <%} else {%>
                    <t:row>
                        <t:cell for="34" colspan="3" size="96%" align="left"/>
                        <t:cell for="35" colspan="3" size="96%" align="left"/>
                    </t:row>
                    <%}%>
                    <t:row>
                        <t:cell colspan="8" for="36" size="98%" align="left"/>
                    </t:row>
                </t:foot>
            </t:grid>
        </t:table>
    </t:form>
</t:page>
<%!
    static final int si_form_title = SI("Кредитные договора", "Кредит шартномалари", "Kredit shartnomalari", "Loan agreement");
    static final int si_alert1 = SI("Договор успешно закрыт!", "Шартнома муваффа&#1179;иятли ёпилди!", "Shartnoma muvaffaqiyatli yopildi!", "Contract closed successfully!");
    static final int si_alert2 = SI("Запрос лимита успешно отправлен в ГО!", "Бош банкга лимит сўрови муваффа&#1179;иятли юборилди!", "Bosh bankga limit so`rovi muvaffaqiyatli yuborildi!", "Query limit successfully sent to the HO!");
    static final int si_alert3 = SI("Данные успешно сохранены!", "Маълумотлар муваффа&#1179;иятли са&#1179;ланди", "Ma`lumotlar muvaffaqiyatli saqlandi", "Data saved successfully");
    static final int si_alert5 = SI("Неопознанное выполнение кода", "Таниб бўлмаган  бажариш коди", "Tanib bo`lmagan  bajarish kodi", "Undefined action code");
    static final int si_confirm1 = SI("Вы действительно хотите закрыть выделенный кредит?", "Белгиланган кредитни &#1203;а&#1179;и&#1179;атда ёпмо&#1179;чимисиз?", "Belgilangan kreditni haqiqatda yopmoqchimisiz?", "Are you sure you want to close the selected loan?");
    static final int si_confirm2 = SI("Вы действительно хотите перевести отмеченные галочкой кредиты в состояние", "Сиз &#1203;а&#1179;и&#1179;атан &#1203;ам давлатга бэлги &#1179;о'ыилган крэдитларни бэрис&#1203;ни хо&#1203;лаысиз", "Siz haqiqatan ham davlatga belgi qo'yilgan kreditlarni berishni xohlaysiz", "Are you sure you want to transfer credits to marked products in the state of");
    static final int si_confirm3 = SI("Вы действительно хотите отправить в ГО запрос на лимит по выделенному кредиту?", "Белгиланган кредит бўйича  Бош банкга лимит сўровини юбормо&#1179;чимисиз!", "Belgilangan kredit bo`yicha  Bosh bankga limit so`rovini yubormoqchimisiz!", "Are you sure you want to send in a request to HO limit on a loan?");
    static final int si_alert4 = SI("Отметьте галочкой кредиты, выданные отделом Микрофинансирования!", "Микромолиялаш бўлими томонидан берилган кредитларни", "Mikromoliyalash bo`limi tomonidan berilgan kreditlarni", "Tick ??loans to Microfinance department!");
    static final int si_confirm4 = SI("Вы уверены, что отмеченные галочкой кредиты выданы отделом Микрофинансирования?", "Ис&#1203;онc&#1203;им комилки, тасди&#1179; бэлгиси томонидан бэрилган крэдитлар микромолиыа бо'лими томонидан бэрилдими?", "Ishonchim komilki, tasdiq belgisi tomonidan berilgan kreditlar mikromoliya bo'limi tomonidan berildimi?", "Are you sure you marked with a tick loans issued Microfinance department?");
    static final int si_loan_action = SI("Действия над кредитами", "Кредитлар устида амаллар", "Kreditlar ustida amallar", "Operations on loans");
    static final int si_sync_status = SI("Синхронизация состояний", "&#1202;олатларни мослаштириш", "Holatlarni moslashtirish", "State Synchronization");
    static final int si_loan_close = SI("Закрытие кредита", "Кредитни ёпиш", "Kreditni yopish", "Closing credits");
    static final int si_set_sign = SI("Установ. признак выдачи отделом Микрофинанс.", "Микромолиялаш бўлими томонидан берилиши белгисини ўрнатиш", "Mikromoliyalash bo`limi tomonidan berilishi belgisini o`rnatish", "SET. sign extradition Microfinance Department.");
    static final int si_restore = SI("Возврат в состояние 'Текущая ссуда'", "&#1202;озирги крэдит &#1203;олатига &#1179;аытис&#1203; '", "Hozirgi kredit holatiga qaytish '", "Return to a state of 'Current loan'");
    static final int si_limits = SI("Лимиты", "Лимитлар", "Limitlar", "Limit");
    static final int si_limit_request = SI("Запрос лимита", "Лимит сўрови", "Limit so`rovi", "Query limit");
    static final int si_modify_ln_states = SI("Выполнить", "Бажариш", "Bajarish", "Implement");
    static final int si_prolong_hisory = SI("История пролонгации", "Муддатини узайтириш тарихи", "Muddatini uzaytirish tarixi", "History of prolongation");
    static final int si_growing_history = SI("История не наращивания", "Ўстирмаслик тарихи", "O`stirmaslik tarixi", "History of not increasing the reporting");
    static final int si_trial_history = SI("История суд. разбир.", "Суд му&#1203;окамаси тарихи", "Sud muhokamasi tarixi", "The history of the court. Analyzing.");
    static final int si_loan_id = SI("ID договора", "", "", "");
    static final int si_branch_id = SI("Код БХМ", "", "", "");
    static final int si_claim_id = SI("ID заявки", "Ариза ID си", "Ariza ID si", "Claim ID");
    static final int si_loan_uid = SI("Логин ID", "Login ID", "Login ID", "Login ID");
    static final int si_client_code = SI("Код клиента", "Мижоз коди", "Mijoz kodi", "Clinet code");
    static final int si_client_name = SI("Наименование клиента", "Мижоз номи", "Mijoz nomi", "Client name");
    static final int si_filial_code = SI("Филиал", "Филиал", "Filial", "Branch");
    static final int si_condition = SI("Состояние", "&#1202;олати", "Holati", "Status");
    static final int si_claim_type = SI("Тип договора", "Шартнома тури", "Shartnoma turi", "Type of contract");
    static final int si_loan_type = SI("Вид кредитования", "Кредитлаш тури", "Kreditlash turi", "Type of crediting");
    static final int si_claim_number = SI("№ заявки", "Буюртма №", "Buyurtma №", "№ application");
    static final int si_loan_number = SI("Поряд. № кредита", "Кредитнинг тартиб №", "Kreditning tartib №", "№ application");
    static final int si_contract_code = SI("№ договора", "Шартнома №", "Shartnoma №", "№ contract");
    static final int si_contract_date = SI("Дата подписания договора", "Шартномани имзолаш санаси", "Shartnomani imzolash sanasi", "Date of sign contract");
    static final int si_open_date = SI("Дата начала договора", "Шартноманинг бошланиш санаси", "Shartnomaning boshlanish sanasi", "Start date of the contract");
    static final int si_close_date = SI("Дата окончания договора", "Шартноманинг Тугаш санаси", "Shartnomaning Tugash sanasi", "The agreement expires");
    static final int si_currency = SI("Валюта", "Валюта", "Valyuta", "Cuurency");
    static final int si_summ = SI("Сумма по договору", "Шартнома бўйича сумма", "Shartnoma bo`yicha summa", "The amount sum under the contract");
    static final int si_niki_id = SI("№ договора в ГРКИ", "ГРКИда шартноманинг уникал №", "RCIda shartnomaning unikal №", "Unique. agreement number in RCI");
    static final int si_niki_state = SI("Статус ГРКИ", "ГРКИ статуси", "RCI statusi", "RCI Status");
    static final int si_loan_purpose = SI("Цель кредита", "Кредит ма&#1179;сади", "Kredit maqsadi", "The purpose of the loan");
    static final int si_currency2 = SI("Справочник валют", "Валюталар маълумотномаси", "Valyutalar ma`lumotnomasi", "Currency reference");
    static final int si_loan_types = SI("Виды кредитования", "Кредитлаш турлари", "Kreditlash turlari", "Type of crediting");
    static final int si_eco_sec = SI("Экономический сектор", "И&#1179;тисодий сектор", "Iqtisodiy sektor", "Economic sector");
    static final int si_nk_err_mess = SI("Причина отбраковки ГРКИ", "ГРКИ да носозликга чи&#1179;ариш сабаблари", "RCI da nosozlikga chiqarish sabablari", "The reason for the rejection of RCI");
    static final int si_transfer_to_LNB = SI("Перевод в модуль &quot;Учет пробленных кредитов&quot;", "Модулга ва &#1179;уватни &#1203;исобга олис&#1203;, муаммоларни &#1203;исобга олис&#1203; ва котировка;", "Modulga va quvatni hisobga olish, muammolarni hisobga olish va kotirovka;", "Transfer to the module & quot; taking into account problem loans & quot;");
    static final int si_QRCode = SI("Инфо (QR код)", "Ма'лумот (&#1178;Р коди)", "Ma'lumot (QR kodi)", "Info (QR code)");
    static final int si_saldo = SI("Остаток", "&#1178;олган &#1179;исми", "Qolgan qismi", "Remainder");
    static final int si_others = SI("Другое", "Бос&#1203;&#1179;а", "Boshqa", "Other");
    static final int si_documents = SI("Документы", "&#1202;ужжатлар", "Hujjatlar", "Documents");
    static final int si_main_account = SI("Основной ссудный счет", "Асосиы крэдит &#1203;исоби", "Asosiy kredit hisobi", "The main loan account");
    static final int si_inspector = SI("Инспектор", "Инспэктор", "Inspektor", "Inspector");
    static final int si_total_amount = SI("Общая - Сумма договора", "Жами - с&#1203;артноманинг ми&#1179;дори", "Jami - shartnomaning miqdori", "Total - amount of the contract");
    static final int si_total_saldo = SI("Остаток", "&#1178;олган &#1179;исми", "Qolgan qismi", "Remainder");
    static final int si_show_Limit_graph = SI("Лимит", "Лимит", "Limit", "Limit");
    static final int si_cancel_bs_count = SI("Списание долгов со страхового полиса (Benefit Supreme)", "Суг'урта полисининг &#1179;арзларини то'лас&#1203; (ыу&#1179;ори даражадаги фоыда кэлтиради)", "Sug'urta polisining qarzlarini to'lash (yuqori darajadagi foyda keltiradi)", "Writing off debts from the insurance policy (Benefit Supreme)");
    static final int si_overdraft = SI("Овердрафт", "Овэрдрафт", "Overdraft", "Overdraft");
    static final int si_unused_summ_loan = SI("Неисп. част.", "Бэма'нилик.&#1179;исмлари.", "Bema'nilik.qismlari.", "Nonsense.parts.");
    static final int si_product = SI("Кредитный продукт", "Крэдит ма&#1203;сулоти", "Kredit mahsuloti", "Credit product");
    static final int si_CL_SUBJECT_CODE = SI("Тип субъекта", "Мавзу тури", "Mavzu turi", "Type of subject");
    static final int si_CLIENT_TYPE = SI("Тип клиента", "Мижоз тури", "Mijoz turi", "Client type");
    static final int si_BORROWER = SI("Тип заёмщика", "&#1178;арз олувc&#1203;и тури", "Qarz oluvchi turi", "Type of borrower");
    static final int si_docs = SI("Ссылки на семейные документы", "Оилавиы &#1203;ужжатларга &#1203;аволалар", "Oilaviy hujjatlarga havolalar", "Links to family documents");
    static final int si_contract = SI("Договор", "С&#1203;артнома", "Shartnoma", "Treaty");
    static final int si_guarantors = SI("Договор поручительства", "Кафолат с&#1203;артномаси", "Kafolat shartnomasi", "Guarantee agreement");
    static final int si_compensation = SI("Реестр компенсаций", "Компэнсатсиыа рэыэстри", "Kompensatsiya reyestri", "Register of compensation");
    static final int si_graphic = SI("График договора", "С&#1203;артнома жадвали", "Shartnoma jadvali", "Contract schedule");
    static final int si_inn = SI("Инн", "&#1178;алаы", "Qalay", "TIN");
    static final int si_pinfl = SI("Пинфл", "Пинф", "Pinf", "Pinfl");
    static final int si_doc_number = SI("Серия и номер паспорта", "Сэриыа ва паспорт ра&#1179;ами", "Seriya va pasport raqami", "Series and passport number");
    static final int si_plagin = SI("Плагин для печати не установлен!", "C&#1203;оп этис&#1203; уc&#1203;ун плагин о'рнатилмаган!", "Chop etish uchun plagin o'rnatilmagan!", "The plugin for printing is not installed!");
    static final int si_download = SI("Скачать плагин", "Плагини ыуклаб олинг", "Plagini yuklab oling", "Download plugin");
    static final int si_credit_source_code = SI("Код источника финансирования", "Молиыалас&#1203;тирис&#1203; манбаи", "Moliyalashtirish manbai", "Source of financing");
    static final int si_btn_back = SI("Назад", "Ор&#1179;ага &#1179;аытис&#1203;", "Orqaga qaytish", "Back");
    static final int si_add_child_loan = SI("Добавить дочерний договор", "С&#1203;ахсиы с&#1203;артнома &#1179;о'с&#1203;инг", "Shaxsiy shartnoma qo'shing", "Add a subsidiary agreement");
    static final int si_view_offer = SI("Оферты", "Таклифлар", "Takliflar", "Offers");
    static final int si_source_cred = SI("Источник финансирования", "Молиыалас&#1203;тирис&#1203; манбаи", "Moliyalashtirish manbai", "Source of financing");
    static final int si_departament_id = SI("Департамент", "Департамент", "Department", "Department");
    static final int si_client_uid = SI("Клиент UID", "Мижоз УИД", "Mijoz UID", "Client UID");
    static final int si_loan_pr_customer = SI("Код цели потреб. кредита", "Ма&#1179;сад коди истэ'мол &#1179;илинади.&#1179;арз", "Maqsad kodi iste'mol qilinadi.qarz", "The target code is consumed.loan");
    static final int si_card_number = SI("Номер карты", "Карта ра&#1179;ами", "Karta raqami", "Card number");
    static final int si_card_type = SI("Тип карты", "Карта тури", "Karta turi", "Type of card");
    static final int si_bs_state = SI("Состояние Benefit Supreme", "Фоыдали &#1203;олати олиы", "Foydali holati oliy", "The state of Benefit Supreme");
    static final int si_option = SI("<option value='SV'>Uzcard<option value='GL'>Humo", "<Вариант Wилиалы = Б СУВ> УзНКРД <вариант = Коммэрсант> Хум", "<Variant Wilialy = B SUV> UzNKRD <variant = Kommersant> Xum", "<Option Valuya = b SUV> Uznkrd <Option Valuy = Kommersant> Humo");
    static final int si_option1 = SI("<option value='LN'>iABS<option value='FBCRM'>CRM<option value='LNMO'>Мобильный", "<Апдамктунэ &#1179;иымат = 'лн'> ИАБ <'ФБCРМ'> CРМ <'ЛНМО'> Мобилэ", "<Apdamktune qiymat = 'ln'> IAB <'FBCRM'> CRM <'LNMO'> Mobile", "<APTION VALUE = 'LN'> IABS <option value = 'FBCRM'> CRM <option Value = 'Lnmo'> Mobile");
    static final int si_group = SI("Группа", "Гуру&#1203;", "Guruh", "Group");
    static final int si_monitoring = SI("Мониторинг", "Мониторинг", "Monitoring", "Monitoring");
    static final int si_act_monitoring = SI("Акт мониторинга", "Мониторинг &#1203;аракати", "Monitoring harakati", "Act of monitoring");
    static final int si_nibbd_code = SI("Код НИББД", "Ниббд коди", "Nibbd kodi", "NIBBD code");
    static final int si_oferta = SI("Договор оферты", "С&#1203;артнома бэрис&#1203; с&#1203;артномаси", "Shartnoma berish shartnomasi", "Offer agreement");
    static final int si_creator_code = SI("Истк. формирования заявки", "С&#1203;ар&#1179;.Ариза с&#1203;акллантирис&#1203;", "Sharq.Ariza shakllantirish", "East.application forming");
    static final int si_mobile_number = SI("Номер телефон", "Ра&#1179;амли тэлэфон", "Raqamli telefon", "Number phone");
    static final int si_monitoring_ipoteka = SI("Мониторинг ипотеки", "Ипотека мониторинги", "Ipoteka monitoringi", "Monitoring");
    static final int si_local_code = SI("Подразделение", "Бо'линма", "Bo'linma", "Subdivision");
    static final int si_calculation = SI("Расчет", "&#1202;исоблас&#1203;", "Hisoblash", "Calculation");
    static final int si_warning = SI("Письмо оповещение", "Огохлантириш хати", "Ogohlantirish xati", "Warning mail");
	static final int si_date_modify = SI("Дата изменения состояния","Холати узгарган сана","Xolati o`zgargan sana","State change date");
%><%@ include file="/language.jsp" %>
