<%@ page import="java.sql.*,java.util.*, uz.fido_biznes.cms.*" %><%
%><%@ page import="oracle.sql.*, oracle.jdbc.*, java.io.*, java.net.URLEncoder" %>
<%@ taglib uri="/WEB-INF/cms.tld" prefix="t"%><%
%><jsp:useBean id="cods" class="iabs.oraDBConnection" scope="session" /><%
%><jsp:useBean id="stored" class="uz.fido_biznes.sql.StoredObject" scope="session"/><jsp:useBean id="storedObj" class="iabs.StoredObject" scope="session"/><%
%><jsp:useBean id="user" class="iabs.User" scope="session" /><%

    Connection conn = cods.getConnection();

    if (conn == null || user.getUserCode() == null)
        pageContext.setAttribute(Resource.SESSION_EXPIRED, Boolean.TRUE);

    Language lang = new Language(user.getLanguageIndex(), sentences);
    pageContext.setAttribute(Resource.STR_LANGUAGE, lang);
//-------------------------------------------------------------------------------------------------
%><t:page><%
    String fileId = stored.decryptValue(request.getParameter("fileId"), "LN_FILES");
    BLOB file                     = null;
    String fileMimeType           = null;
    String fileName               = null;
    OracleStatement st            = null;
    OracleResultSet rs            = null;
    final int DEFAULT_BUFFER_SIZE = 5000000; // 5Mb

    try
    {
        if ( fileId == null )
            throw new Exception(lang.get(si_exception));

        st = (OracleStatement)conn.createStatement();
        rs = (OracleResultSet)st.executeQuery("SELECT content, full_name, ln_file.get_mime_type_code(mime_type_id) AS mime_type_code FROM (SELECT content, full_name, mime_type_id FROM ln_files WHERE  id =" +fileId+
												"UNION ALL SELECT content, full_name, mime_type_id FROM ln_files_his WHERE  id =" + fileId+")");

        if ( rs.next() )
        {
            file         = rs.getBLOB(1);
            fileName     = Util.encode( rs.getString(2), "Cp1251", "ISO-8859-1" );
			if (fileName != null) fileName = fileName.replaceAll("\\?","_");
            fileMimeType = rs.getString(3);
        }
        else
            throw new Exception(lang.get(si_exception2) + "[" + fileId + "]");

        out.clearBuffer();
        //response.reset();

        response.setHeader("Expires", "0");
        response.setHeader("Cache-Control","cache");
        response.setHeader("Pragma", "cache");
        //response.setBufferSize( DEFAULT_BUFFER_SIZE );
        response.setHeader("Content-Encoding", "gzip");
        response.setContentType( fileMimeType );
        response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");
        response.setHeader("Content-Length", String.valueOf( file.length() ));

        InputStream in = file.getBinaryStream();

        BufferedOutputStream output = new BufferedOutputStream( response.getOutputStream() );

        byte[] buffer = new byte[DEFAULT_BUFFER_SIZE];
        for (int len; (len = in.read(buffer)) != -1;)
          output.write(buffer, 0, len);

        in.close();
        output.flush(); output.close();
    }
    catch (Exception ex)
    {
        Util.alertUserMessage(ex, out);
    }
    finally
    {
        if (rs != null)
            try { rs.close( ); } catch (SQLException ignore) { }

        if (st != null)
            try { st.close( ); } catch (SQLException ignore) { }
    }
%><t:form emptyForm="" /></t:page>
<%!
static final int si_exception  = SI("Не передан ID файла", "Файл ID си берилмаган", "Fayl ID si berilmagan", "Not passed the file ID");
static final int si_exception2 = SI("Не найден файл с указанным ID", "ID ли файл топилмади", "ID li fayl topilmadi", "The file with specified ID is not found");
static final int si_close      = SI("Закрыть", "Ёпиш", "Yopish", "Close");
//-------------------------------------------------------------------------------------------------
%><%@ include file="/language.jsp" %>
