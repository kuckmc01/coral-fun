<%--
  ADOBE CONFIDENTIAL

  Copyright 2012 Adobe Systems Incorporated
  All Rights Reserved.

  NOTICE:  All information contained herein is, and remains
  the property of Adobe Systems Incorporated and its suppliers,
  if any.  The intellectual and technical concepts contained
  herein are proprietary to Adobe Systems Incorporated and its
  suppliers and may be covered by U.S. and Foreign Patents,
  patents in process, and are protected by trade secret or copyright law.
  Dissemination of this information or reproduction of this material
  is strictly forbidden unless prior written permission is obtained
  from Adobe Systems Incorporated.
--%><%
%><%@include file="/libs/granite/ui/global.jsp" %><%
%><%@page session="false"
          import="java.net.URI,
                  java.net.URISyntaxException,
                  org.apache.sling.api.SlingHttpServletRequest,
                  org.slf4j.Logger,
                  com.adobe.granite.ui.components.AttrBuilder,
                  com.adobe.granite.ui.components.ComponentHelper,
                  com.adobe.granite.ui.components.Config,
                  com.adobe.granite.ui.components.Tag" %><%--###
Hyperlink
=========

.. granite:servercomponent:: /libs/granite/ui/components/foundation/hyperlink

   Hyperlink is a component to represent a standard HTML hyperlink (<a>).

   It has the following content structure:

   .. gnd:gnd::

      [granite:Hyperlink] > granite:commonAttrs, granite:renderCondition

      /**
       * The href attribute.
       */
      - href (StringEL)

      /**
       * The href attribute. This is usually used to produce different value based on locale.
       */
      - href_i18n (StringEL) i18n

      /**
       * The target attribute.
       */
      - target (String)

      /**
       * The body text of the element.
       */
      - text (String) i18n

      /**
       * The x-cq-linkchecker attribute.
       */
      - 'x-cq-linkchecker' (String) < 'skip', 'valid'

      /**
       * The icon class.
       */
      - icon (String)

      /**
       * The size of the icon.
       */
      - iconSize (String) = 'S' < 'XS', 'S', 'M', 'L'

      /**
       * Visually hide the text.
       */
      - hideText (Boolean)
###--%><%

if (!cmp.getRenderCondition().check()) {
    return;
}

Config cfg = cmp.getConfig();
String icon = cfg.get("icon", String.class);
String iconSize = cfg.get("iconSize", "S");

String imagePath = cfg.get("imagePath",String.class);
String imageClass = cfg.get("imageClass",cfg.get("id","link")+"-image-icon");

Tag tag = cmp.consumeTag();

AttrBuilder attrs = tag.getAttrs();
cmp.populateCommonAttrs(attrs);

attrs.add("target", cfg.get("target", String.class));

attrs.add("x-cq-linkchecker", cfg.get("x-cq-linkchecker", String.class));

String href;
if (cfg.get("href_i18n", String.class) != null) {
    href = i18n.getVar(cmp.getExpressionHelper().getString(cfg.get("href_i18n", "")));
} else {
    href = cmp.getExpressionHelper().getString(cfg.get("href", ""));
}
handleHref(href, cfg, attrs, slingRequest, log);

attrs.addClass("coral-Link");

// start of attrs compatibility; please use cmp.populateCommonAttrs(attrs);
attrs.add("id", cfg.get("id", String.class));
attrs.addRel(cfg.get("rel", String.class));
attrs.addClass(cfg.get("class", String.class));
attrs.add("title", i18n.getVar(cfg.get("title", String.class)));
attrs.addBoolean("hidden", cfg.get("hidden", false));
if (cfg.get("itemscope", String.class) != null) {
    attrs.add("itemscope", "itemscope");
}
attrs.add("itemprop", cfg.get("itemprop", String.class));
attrs.addOthers(cfg.getProperties(), "id", "rel", "class", "title", "hidden", "itemscope", "itemprop", "href", "target", "text", "icon", "imagePath", "imageClass", "hideText", "allowEmptySuffix", "appendSuffix", "suffixMinLevel", "x-cq-linkchecker");
// end of attrs compatibility

%><a <%= attrs.build() %>><%
    if (icon != null  && icon.length() > 0) {
        %><i class="coral-Icon <%= cmp.getIconClass(icon) %> coral-Icon--size<%= iconSize %>"></i> <%
    }
	if(icon == null && imagePath != null){
		%><img src="<%=imagePath%>" class="<%=imageClass%>" /><%
	}
    if (!cfg.get("hideText", false)) {
        %><%= outVar(xssAPI, i18n, cfg.get("text", "")) %><%
    }
%></a><%!

private void handleHref(String href, Config cfg, AttrBuilder attrs, SlingHttpServletRequest req, Logger log) {
    // FIXME this is a wrong solution
    if (Boolean.TRUE.equals(req.getAttribute("pulldown_disabled"))) {
        attrs.addClass("is-disabled");
        return;
    }
    
    if (href == null) {
        return;
    }
    
    if (href.trim().length() > 0 && cfg.get("appendSuffix", false)) {
        log.warn("@deprecated appendSuffix of /libs/granite/ui/components/foundation/hyperlink; please use EL instead.");
        
        String suffix = req.getRequestPathInfo().getSuffix();
        if (suffix != null) {
            href += suffix;
        }
    }
    
    try {
        attrs.addHref("href", new URI(href).toASCIIString()); // GRANITE-5754
    } catch (URISyntaxException e) {
        log.debug("Invalid URI passed", e);
        attrs.addHref("href", href);
    }
}
%>