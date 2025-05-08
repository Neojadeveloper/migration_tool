<%@ page contentType="text/html;charset=WINDOWS-1251" language="java"%><%
%><%@ page import="java.sql.*,java.util.*, uz.fido_biznes.cms.*" %><%
%><%@ page import="oracle.sql.*, oracle.jdbc.driver.*" %><%
%><%@ taglib uri="/WEB-INF/cms.tld" prefix="t"%><%
%><jsp:useBean id="cods" class="iabs.oraDBConnection" scope="session" /><%
%><jsp:useBean id="stored" class="uz.fido_biznes.sql.StoredObject" scope="session"/><jsp:useBean id="storedObj" class="iabs.StoredObject" scope="session"/><%
%><jsp:useBean id="user" class="iabs.User" scope="session" /><%
    Connection conn = cods.getConnection();
    if (conn == null || user.getUserCode() == null)
        pageContext.setAttribute(Resource.SESSION_EXPIRED, Boolean.TRUE);
    Language lang = new Language(user.getLanguageIndex(), sentences);
    pageContext.setAttribute(Resource.STR_LANGUAGE, lang); storedObj.setConnection(conn, "70904");
//-------------------------------------------------------------------------------------------------
%><t:page><%
    String log = "";
    String logAsoki = "";
    try
    {
        ServletCallableStatement cs1 = new ServletCallableStatement(stored, request);
        cs1.setProcedure("Ln_Api2.Send_Asoki_Request_020");
        cs1.setEncryptedParameter("owner_id","OWNER_ID");
		cs1.setNumberParameter("i_owner_id", "owner_id");
        cs1.registerString("o_Report");
        cs1.execute();
        logAsoki = cs1.getString("o_Report");
        if ( log == null && logAsoki == null )
        {
            %><script>window.close( );</script><%
        }
    }
    catch (Exception err)
    {
        Util.alertUserMessage( err, out );
    }
%><t:form emptyForm="">
     <style>
         #resultDiv
          {
              width:95%; height:90%;
              text-align:center;
              font: normal 12px/1.6 "Trebuchet MS", Tahoma, Verdana, sans-serif; letter-spacing:1px;
              padding:5px
          }
          hr
          {
              height:1px
          }
     </style>
    <pre id="resultDiv">
      <%=log%> <br><br><br>
      <%=(logAsoki == null)?"":logAsoki%>
    </pre>
    <div style="text-align: center">
        <button name="do" onclick="window.close()"><%=lang.get(si_exit)%></button>
    </div>
</t:form></t:page>
<%!
static final int si_exit = SI("Закрыть", "Ёпиш", "Yopish", "Close");
static final int si_easd = SI("Закрыть", "", "", "");
//-------------------------------------------------------------------------------------------------
%><%@ include file="/language.jsp" %>