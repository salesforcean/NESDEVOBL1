/**
 * Created by Ashish on 07-01-2019.
 */
({
    handleInit: function(component,event,helper) {
      
        console.log('In init');
        component.set("v.onRegistrationPage",location.href.indexOf('/registration')>-1);
        var action = component.get('c.getSitePrefix');
        action.setCallback(this, function(response){
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set('v.baseUrl', result);
                this.fetchSfBaseURL(component);
            }
        });
        $A.enqueueAction(action);

        var isGuestAction = component.get('c.isGuestUser');
        isGuestAction.setCallback(this, function(response){
            component.set('v.isGuest', response.getReturnValue());
        });

        $A.enqueueAction(isGuestAction);

        var isGuestAction2 = component.get('c.getGuestType');
        isGuestAction2.setCallback(this, function(response){
            //component.set('v.isGuest', response.getReturnValue());
            console.log('Getting user type');
            console.log(response.getReturnValue());
        });

        $A.enqueueAction(isGuestAction2);
    },
    fetchLogo: function(component,schoolId) {
        var action = component.get('c.retrieveLogo');
        action.setParams({'instituteId': schoolId});
     //   console.log(schoolId);
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set('v.logoName', result);
                console.log(result);
            }
        });
        $A.enqueueAction(action);
    },
    fetchSfBaseURL: function(component) {
      
        var action = component.get('c.getSalesforceBaseURL');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                component.set('v.sfbaseUrl', response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },

})