<%--
overriding adobe js libs
--%><%
%><%@page session="false" %><%
%><%@include file="/libs/granite/ui/global.jsp"%><%
%><ui:includeClientLib js="handlebars"/>
<ui:includeClientLib js="coralui2"/>
<ui:includeClientLib js="cq.authoring.editor"/>
<ui:includeClientLib js="cq.authoring.editor.hook"/>
<ui:includeClientLib js="cq.authoring.editor.hook.assetfinder"/>
<ui:includeClientLib js="cq.authoring.editor.hook.annotate"/>
<ui:includeClientLib categories="cq.authoring.editor.hook.tests"/>
<ui:includeClientLib js="cq.authoring.dialog"/>
<ui:includeClientLib js="cq.authoring.tour"/>
<ui:includeClientLib js="cq.dev.ui.tests"/>
<ui:includeClientLib js="apps.testswork.all"/>
<ui:includeClientLib js="cq.authoring.editor.hook.myflag"/>
