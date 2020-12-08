/**
 * Created by karolbrennan on 10/11/18.
 */
({
    doInit : function(component,event,helper)
    {
       
        helper.handleInit(component,event,helper);
    },
    handleStep : function(component,event)
    {
        var currentStep = event.getParam("currentStep");
        component.set("v.currentRegistrationStep", currentStep);
        // Swapna:Added for GTM
        var appEvent = $A.get("e.c:NES_GTMEvent"); 
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DDTHH:mm:ss");
        appEvent.setParams({"eventNm":"event"});
        appEvent.setParams({"eventValue":"pageview"});
         appEvent.setParams({"step":"registrationStep"});
         appEvent.setParams({"stepValue":currentStep});
         appEvent.setParams({"pagePath":document.location.href});
		appEvent.setParams({"timeStamp":today}); 
        //	appEvent.setParams({"eventLabel":"Registration"});  
		appEvent.fire();
        
    },
    detectRegistrationStep : function(component,event)
    {
        component.set("v.onRegistrationPage", event.getParam("onRegistrationPage"));
    },
    handleLogin : function(component,event){
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            //"url": '/login'
         "url": '/dashboard'
        });
        urlEvent.fire();
    },
    handleSchoolIdEvent : function(component,event,helper) {
        console.log('event fired');
        var schoolId = event.getParam("schoolids");
     //   console.log(schoolId);
        if(schoolId === null) {
            component.set("v.logoName", null);
        } else {
            helper.fetchLogo(component,schoolId);
        }

    }

});