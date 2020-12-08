/**
 * Created by karolbrennan on 11/9/18.
 */
({
    doInit: function(component, event, helper)
    {
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var caretakerId = helper.getUrlParameter('caretakerId');

        if(caretakerId) {
            if(userId === caretakerId) {
                helper.grabSchool(component, event, helper);
                helper.grabStudentName(component, event, helper);
            } else {
                component.set("v.invalidUser", true);
            }
        } else {
            if(component.get('v.recordId') != null) {
                helper.initializeComponent(component,event,helper);
            } else {
                component.set("v.invalidUser", true);
            }
        }
    },

    goToDashboard: function(component, event, helper) {
        helper.goToDashboard(component, event, helper);
    },

    scriptsLoaded: function(component, event, helper)
    {
        console.log('scripts loaded!');
    }
});