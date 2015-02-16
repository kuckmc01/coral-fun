<%@page session="false" import="java.net.URLEncoder,
                                    java.security.Principal,
                                    java.text.SimpleDateFormat,
                                    java.util.Calendar,
                                    java.util.Collection,
                                    java.util.LinkedHashSet,
                                    java.util.ResourceBundle,
                                    java.util.Set,
                                    javax.jcr.RepositoryException,
                                    javax.jcr.security.AccessControlManager,
                                    javax.jcr.security.Privilege,
                                    javax.jcr.Session,
                                    org.apache.jackrabbit.api.JackrabbitSession,
                                    org.apache.jackrabbit.api.security.principal.PrincipalIterator,
                                    org.apache.jackrabbit.api.security.user.Authorizable,
                                    org.apache.sling.api.resource.Resource,
                                    org.apache.sling.api.resource.ResourceUtil,
                                    org.apache.sling.api.resource.ValueMap,
                                    com.adobe.cq.wcm.launches.utils.LaunchUtils,
                                    com.adobe.granite.ui.components.AttrBuilder,
                                    com.adobe.granite.ui.components.Config,
                                    com.adobe.granite.security.user.UserPropertiesManager,
                                    com.adobe.granite.security.user.util.AuthorizableUtil,
                                    com.adobe.cq.contentinsight.ProviderSettingsManager,
                                    com.day.cq.commons.date.RelativeTimeFormat,
                                    com.day.cq.security.util.CqActions,
                                    com.day.cq.wcm.api.Page,
                                    com.day.cq.wcm.api.components.Component,
                                    com.day.cq.wcm.msm.api.LiveRelationshipManager,
                                    com.day.cq.wcm.msm.api.BlueprintManager" %><%
%><%@include file="/libs/granite/ui/global.jsp" %><%

    ResourceBundle resourceBundle = slingRequest.getResourceBundle(slingRequest.getLocale());

    AccessControlManager acm = null;
    Session session = resourceResolver.adaptTo(Session.class);
    Authorizable authorizable = resourceResolver.adaptTo(Authorizable.class);

    try {
        acm = session.getAccessControlManager();
    } catch (RepositoryException e) {
        log.error("Unable to get access manager", e);
    }

    Page targetPage = null;

    // get page object from suffix
    String pagePath = slingRequest.getRequestPathInfo().getSuffix();
    if( pagePath != null ) {
        Resource pageResource = slingRequest.getResourceResolver().resolve(pagePath);
        if( pageResource != null ) {
            targetPage = pageResource.adaptTo(Page.class);
        }
    }

    if( targetPage == null ) return;

    // page properties
    ValueMap targetPageProperties = targetPage.getProperties();
    

    Calendar modifiedDateRaw = targetPage.getLastModified();
    String modifiedDate = modifiedDateRaw == null ?
            i18n.get("never") :
            toRelativeTime(modifiedDateRaw, resourceBundle);
    String modifiedBy = xssAPI.filterHTML(AuthorizableUtil.getFormattedName(resourceResolver, targetPage.getLastModifiedBy()));

    Calendar publishedDateRaw = targetPageProperties.get("cq:lastReplicated", Calendar.class);
    String publishedDate = publishedDateRaw == null ?
            i18n.get("never") :
            toRelativeTime(publishedDateRaw, resourceBundle);
    String publishedBy = xssAPI.filterHTML(AuthorizableUtil.getFormattedName(resourceResolver, targetPageProperties.get("cq:lastReplicatedBy", "")));

    String lastReplicationAction = targetPageProperties.get("cq:lastReplicationAction", String.class);
    Calendar lastReplicationDateRaw = targetPageProperties.get("cq:lastRolledout", Calendar.class);
    String rolledOutDate = lastReplicationDateRaw == null ?
            i18n.get("never") :
            toRelativeTime(lastReplicationDateRaw, resourceBundle);
    boolean isDeactivated = "Deactivate".equals(lastReplicationAction);
    String publishStatus = "";
    if(isDeactivated){
        publishStatus = xssAPI.filterHTML(i18n.get("Page has been deactivated"));
    }else if(publishedDateRaw == null){
        publishStatus = xssAPI.filterHTML(i18n.get("Page is not published"));
    }else{
        publishStatus = xssAPI.filterHTML(i18n.get("Page has been published {0}", null, publishedDate));
    }

    boolean canModify = false;
    try {
        // Get the set of principals for authorizable
        Set<Principal> principals = new LinkedHashSet<Principal>();
        Principal principal = authorizable.getPrincipal();
        principals.add(principal);

        for (PrincipalIterator it = ((JackrabbitSession) session).getPrincipalManager().getGroupMembership(principal); it.hasNext();) {
            principals.add(it.nextPrincipal());
        }

        // Test the modify permission from allowed actions
        CqActions cqActions = new CqActions(session);
        Collection<String> allowedActions = cqActions.getAllowedActions(targetPage.getPath(), principals);
        canModify = allowedActions.contains("modify");
    } catch (RepositoryException e) {
        log.error("Unable to retrieve allowed user actions", e);
    }
    
    LiveRelationshipManager relationshipManager = sling.getService(LiveRelationshipManager.class);
    BlueprintManager bpm = resourceResolver.adaptTo(BlueprintManager.class);
    boolean isBlueprint = false;
    if (relationshipManager != null) {
        isBlueprint =  bpm != null
                && bpm.getContainingBlueprint(targetPage.getPath()) != null
                && relationshipManager.isSource(targetPage.adaptTo(Resource.class));
    }

    ProviderSettingsManager providerSettingsManager = sling.getService(ProviderSettingsManager.class);
    boolean hasAnalytics = false;
    if(providerSettingsManager != null) {
        hasAnalytics = providerSettingsManager.hasActiveProviders(targetPage.adaptTo(Resource.class));
    }

    // dom attributes
    Config cfg = new Config(resource);
    AttrBuilder divAttrs = new AttrBuilder(request, xssAPI);
    divAttrs.add("id", cfg.get("id", String.class));
    divAttrs.addOther("path", resource.getPath());
    divAttrs.addOthers(cfg.getProperties(), "id");

    String propertyConfig = cfg.get("propertyURL", "/libs/wcm/core/content/sites/properties.html");
    String propertyURL = request.getContextPath() + propertyConfig + "?" + cfg.get("propertyURLParam", "item") + "=" + URLEncoder.encode(targetPage.getPath(), "utf-8");

    String publishLabel = xssAPI.filterHTML(i18n.get("Publish"));
    String unpublishLabel = xssAPI.filterHTML(i18n.get("Unpublish"));
    String adminViewLabel = xssAPI.filterHTML(i18n.get("View in Admin"));
    String propertiesLabel = xssAPI.filterHTML(i18n.get("Properties"));
    String analyticsLabel = xssAPI.filterHTML(i18n.get("Analytics & Recommendations"));
    String lockPageLabel = xssAPI.filterHTML(i18n.get("Lock Page"));
    String rolloutPageLabel = xssAPI.filterHTML(i18n.get("Rollout Page"));

    boolean hasPermission = hasPermission(acm, targetPage, "crx:replicate");
    if (!hasPermission) {
        publishLabel = xssAPI.filterHTML(i18n.get("Request publication"));
        unpublishLabel = xssAPI.filterHTML(i18n.get("Request unpublication"));
    }
    
    boolean hasLockUnlockPermission = hasPermission(acm, targetPage, "jcr:lockManagement");
    
    Component component = resourceResolver.getResource(targetPage.getContentResource().getResourceType()).adaptTo(Component.class);
    Resource dialog = component.getLocalResource("cq:dialog");
    if (dialog == null) {
        dialog = component.getLocalResource("dialog");
    }
    String contentPath = targetPage.getContentResource().getPath();
    String dialogSrc = request.getContextPath() + dialog.getResourceResolver().map(dialog.getPath()) + ".html" + contentPath;

    boolean isLaunchResource = LaunchUtils.isLaunchResourcePath(contentPath);
    
    AttrBuilder adminViewActivatorAttrs = new AttrBuilder(request, xssAPI);
    adminViewActivatorAttrs.add("data-adminurl", cfg.get("adminURL", "/sites.html"));
    if (targetPage.getParent() != null) {
        adminViewActivatorAttrs.add("data-parentpath", targetPage.getParent().getPath());
    }

    AttrBuilder propertiesActivatorAttrs = new AttrBuilder(request, xssAPI);
    propertiesActivatorAttrs.addClass("properties-activator");
    propertiesActivatorAttrs.add("data-path", contentPath);
    propertiesActivatorAttrs.add("data-dialog-src", dialogSrc);

%>
<div <%= divAttrs.build() %>>

    <div class="myflag-statusandactions">
        <ul class="coral-Popover-content coral-List coral-List--minimal myflag-pagestatus">
            <li class="coral-List-item info myflag-title">
                <h1 class="coral-Heading coral-Heading--1"><%= xssAPI.filterHTML(targetPageProperties.get("jcr:title", "")) %></h1>
            </li>

            <li class="coral-List-item info myflag-status">
                <i class="coral-Icon coral-Icon--fire coral-Icon--sizeXS" title="<%= xssAPI.filterHTML(i18n.get("Modified")) %>"></i>
                <span>
                <span><%= modifiedDate %></span> <%= xssAPI.filterHTML(i18n.get("by")) %> <span class="myflag-user"><%= modifiedBy %></span>
                </span>
            </li>
        </ul>

        <ul class="coral-Popover-content coral-List coral-List--minimal myflag-pageactions">
            <li class="coral-List-item myflag-adminview myflag-pageaction" <%= adminViewActivatorAttrs.build() %>>
                <i class="coral-Icon coral-Icon--properties coral-Icon--sizeS" title="<%= adminViewLabel %>"></i><%= adminViewLabel %>
            </li>

        </ul>
    </div>

</div>

<%!

    private boolean hasPermission(AccessControlManager acm, Page page, String privilege) {
        try {
            if (acm != null) {
                Privilege p = acm.privilegeFromName(privilege);
                return acm.hasPrivileges(page.getPath(), new Privilege[]{p});
            }
        } catch (RepositoryException e) {
            // ignore
        }
        return false;
    }

    private String toRelativeTime(Calendar date, ResourceBundle rb) {
        String dateText = null;
        try {
            RelativeTimeFormat tf = new RelativeTimeFormat(RelativeTimeFormat.SHORT, rb);
            dateText = tf.format(date.getTimeInMillis(), true);
        } catch (IllegalArgumentException e) {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            dateText = sdf.format(date.getTime());
        }
        return dateText;
    }
%>