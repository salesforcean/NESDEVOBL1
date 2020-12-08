/*
 * 2019-10-04 added token cache #US109799/fixed #BUG112429  (Mark Membrino)
 */
({
    doInit: function(component, event, helper) {
        helper.getDocList(component, event);
        helper.getUtilitySettings(component, event);
    },
    handleIframeLoaded: function(component, event, helper) {
		var tokenExpiration = component.get("v.docTokenTimeout");
		var storedToken = JSON.parse(sessionStorage.getItem("documentTokenData"));
		if (!storedToken || !helper.isValidToken(storedToken, tokenExpiration)) {
        component.set("v.iframeLoaded", true);
        setTimeout(function() {
            helper.handleIframeLoaded(component, event);
        }, 3000);
        } else {
            helper.handleIframeLoaded(component, event);
        }

    },
    handleViewClick: function(component, event, helper) {
        helper.handleViewClick(component, event);
    },
    handleDownloadClick: function(component, event, helper) {
       helper.handleDownloadClick(component, event);
    }
})