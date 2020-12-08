/**
 * Created by Ashish Pandey on 03-12-2018.
 */
({
    getAnnouncements : function(component, event, helper) {
        helper.doCallout(component, "c.retrieveAnnouncements").then($A.getCallback(function(response){
            if(response.success){
                component.set('v.contactAnnouncements', response.results);
                component.set("v.showDismissingSpinner", false);
                console.log('contactAnnouncements'+v.contactAnnouncements);

                var indicator1 = component.find('indicator-id-01');
                var content1 = component.find('content-id-01');

                $A.util.addClass(content1, 'slds-show');
                $A.util.removeClass(content1, 'slds-hide');

                $A.util.removeClass(component.find('indicator-id-01'), 'slds-is-active');
                $A.util.removeClass(component.find('indicator-id-02'), 'slds-is-active');
                $A.util.removeClass(component.find('indicator-id-03'), 'slds-is-active');
                $A.util.addClass(indicator1, 'slds-is-active');


            }else{
                console.log('ERROR getting messages');
                console.log(response.messages[0]);
            }
        }));
    },

    dismissAnnouncement : function(component, event, helper, contactAnnouncementId) {
        var params = { 'contactAnnouncement' : contactAnnouncementId};

        component.set("v.showDismissingSpinner", true);

        helper.doCallout(component, "c.dismissAnnouncement", params).then(function(response){
            if(response.success){
                component.set('v.messages', response.results);
                helper.getAnnouncements(component, event, helper);
                //$A.get('e.force:refreshView').fire();
            }else{
                component.set("v.showDismissingSpinner", false);
                console.log('ERROR getting messages');
                console.log(response.messages[0]);
            }
        });
    },

})