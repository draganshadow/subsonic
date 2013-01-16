<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="iso-8859-1" %>

<%@page import="java.io.File"%>
<%@page import="java.io.FileReader"%>
<%@page import="java.io.BufferedReader"%>
<%@page import="java.util.regex.Pattern"%>
<%@page import="java.util.regex.Matcher"%>
<%@page import="net.sourceforge.subsonic.domain.MediaFile"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%--@elvariable id="model" type="java.util.Map"--%>

<html><head>
	<%@ include file="head.jspf" %>
</head><body class="mainframe bgcolor1">
<c:set var="dir" value='${model.dir}'/>
<% 
		MediaFile dir = (MediaFile) pageContext.getAttribute("dir");
		if(!dir.isRoot()){
			pageContext.setAttribute("parent",dir.getParent().getName());
		}
		
    	String xmlPath = dir.getPath().concat("/series.xml");
		String parentXmlPath = dir.getPath().concat("/../series.xml");
		String folderImgPath = dir.getPath().concat("/folder.jpg");
		pageContext.setAttribute("folderImgExists", (new File(folderImgPath)).exists()); 
		
        String overview = "";
    	File f = new File(xmlPath);
    	if(f.exists()) {
        	FileReader freader = new FileReader(f);
            BufferedReader reader = new BufferedReader(freader);
            StringBuilder sb = new StringBuilder();
            String line;

            while((line = reader.readLine())!= null){
                sb.append(line);
            }
            String metadata = sb.toString();
            Pattern pattern = Pattern.compile("verview>(.*?)</");
            Matcher matcher = pattern.matcher(metadata);
            if (matcher.find())
            {
            	overview = matcher.group(1);
            }
    	}
    	else{
        	File fp = new File(parentXmlPath);
        	if(fp.exists()) {
            	FileReader freader = new FileReader(fp);
                BufferedReader reader = new BufferedReader(freader);
                StringBuilder sb = new StringBuilder();
                String line;

                while((line = reader.readLine())!= null){
                    sb.append(line);
                }
                String metadata = sb.toString();
                Pattern pattern = Pattern.compile("verview>(.*?)</");
                Matcher matcher = pattern.matcher(metadata);
                if (matcher.find())
                {
                	overview = matcher.group(1);
                }
        		
        	}
    	}
        pageContext.setAttribute("metaOveview",overview);
    %>
    <h1>

	<c:if test="${model.dir.root eq false}">
		<sub:url value="main.view" var="parentUrl"><sub:param name="path" value="${model.dir.parent.path}"/></sub:url>
			<a href="${parentUrl}" title="..">${parent}</a> >
	</c:if>
${model.dir.name}</h1>
    <div>
		<div style="width:700px;">
		    <div style="float:left;">
				<c:if test="${folderImgExists}">
				    <c:import url="coverArt.jsp">
				        <c:param name="coverArtPath" value="${model.dir}/folder.jpg"/>
				        <c:param name="coverArtSize" value="120"/>
				    </c:import>
				</c:if>
			</div>
			${metaOveview}
		</div>
		<br style="clear:both;" />
	</div>

	<c:forEach items="${model.subDirectories}" var="subDirectory" varStatus="loopStatus">
		<c:if test="${!(subDirectory.name eq 'metadata')}">
			<sub:url value="main.view" var="subDirectoryUrl"><sub:param name="path" value="${subDirectory.path}"/></sub:url>
			<% 
				MediaFile subdir = (MediaFile) pageContext.getAttribute("subDirectory");
				String subFolderImgPath = subdir.getPath().concat("/folder.jpg");
		    	String sxmlPath = subdir.getPath().concat("/series.xml");
				pageContext.setAttribute("subFolderImgExists", (new File(subFolderImgPath)).exists());
				String soverview = "";
		    	File sf = new File(sxmlPath);
		    	if(sf.exists()) {
		        	FileReader freader = new FileReader(sf);
		            BufferedReader reader = new BufferedReader(freader);
		            StringBuilder ssb = new StringBuilder();
		            String line;

		            while((line = reader.readLine())!= null){
		                ssb.append(line);
		            }
		            String smetadata = ssb.toString();
		            Pattern pattern = Pattern.compile("verview>(.*?)</");
		            Matcher matcher = pattern.matcher(smetadata);
		            if (matcher.find())
		            {
		            	soverview = matcher.group(1);
		            }
		    	}
		        pageContext.setAttribute("smetaOveview",soverview);
			%>
			<c:if test="${!(smetaOveview eq '')}">
			<div style="clear:both;"/>
			</c:if>
			<div style="float:left;">
			
			<h1>
				<a href="${subDirectoryUrl}" title="${subDirectory.name}">
					<span style="white-space:nowrap;">${fn:escapeXml(subDirectory.name)}</span>
				</a>
			</h1>
			<div>
			    <div style="float:left;">
					<c:if test="${subFolderImgExists}">
					    <c:import url="coverArt.jsp">
					        <c:param name="coverArtPath" value="${subDirectory}/folder.jpg"/>
					        <c:param name="coverArtSize" value="120"/>
					    </c:import>
					</c:if>
					<c:if test="${!subFolderImgExists}">
					    <c:import url="coverArt.jsp">
					        <c:param name="coverArtPath" value=""/>
					        <c:param name="coverArtSize" value="120"/>
					    </c:import>
					</c:if>
				</div>
				<c:if test="${!(smetaOveview eq '')}">
				<div style="float:left;width:700px;">
				${smetaOveview}
				</div>
				</c:if>
			</div>
			</div>
			<c:if test="${!(smetaOveview eq '')}">
			<div style="clear:both;"/>
			</c:if>
		</c:if>
	</c:forEach>
	
	<br/>

	<c:if test="${fn:length(model.files) > 0}">
		<h2>
			<a href="javascript:noop()" onclick="top.playlist.onPlay(${model.trackIds}, 'P');">Play all</a> |
			<a href="javascript:noop()" onclick="top.playlist.onPlay(${model.trackIds}, 'E');">Enqueue all</a> |
			<a href="javascript:noop()" onclick="top.playlist.onPlay(${model.trackIds}, 'A');">Add all</a>
		</h2>
		<table style="border-collapse:collapse;white-space:nowrap">
			<c:forEach items="${model.files}" var="file" varStatus="loopStatus">
				<tr>
					<c:import url="playAddDownload.jsp">
						<c:param name="id" value="[${file.id}]"/>
						<c:param name="video" value="${file.video and model.player.web}"/>
						<c:param name="starDisabled" value="true"/>
						<c:param name="playEnabled" value="${model.user.streamRole}"/>
						<c:param name="enqueueEnabled" value="${model.user.streamRole}"/>
						<c:param name="addEnabled" value="${model.user.streamRole}"/>
						<c:param name="downloadEnabled" value="${model.user.downloadRole}"/>
						<c:param name="asTable" value="true"/>
					</c:import>
					<td style="padding-right:1.25em;white-space:nowrap">${fn:escapeXml(file.title)}</td>
				</tr>
			</c:forEach>
		</table>
	</c:if>

</body>
</html>