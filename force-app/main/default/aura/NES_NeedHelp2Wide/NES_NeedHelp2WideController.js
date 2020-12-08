/**
 * Created by lukestevens on 2018-12-29.
 */
({
    doInit : function(component)
    {
        
        var action = component.get('c.getResourceUrl');
       
        action.setCallback(this, function(response){
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                 
                console.log("RESOURCE URL", result);
                component.set('v.resourceUrl', result);
            }
        });
        $A.enqueueAction(action);

        var schoolAppEvent = $A.get("e.c:NES_schoolId");
        schoolAppEvent.setParams({
            "schoolids" : null });
        schoolAppEvent.fire();
    },
    //Swapna: For GTM
    findanAnswer: function(component)
    {
        var appEvent = $A.get("e.c:NES_GTMEvent"); 
         var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DDTHH:mm:ss");
         appEvent.setParams({"eventNm":"event"});
         appEvent.setParams({"eventValue":"pageview"});
         appEvent.setParams({"step":"lookingForHelp"});
         appEvent.setParams({"stepValue":"Find an Answer"});
         appEvent.setParams({"pagePath":document.location.href});
		 appEvent.setParams({"timeStamp":today}); 
         appEvent.setParams({"houseHold":"12345"});
		 appEvent.fire(); 
    },
    AskaQues: function(component)
    {
        var appEvent = $A.get("e.c:NES_GTMEvent"); 
         var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DDTHH:mm:ss");
         appEvent.setParams({"eventNm":"event"});
         appEvent.setParams({"eventValue":"pageview"});
         appEvent.setParams({"step":"lookingForHelp"});
         appEvent.setParams({"stepValue":"Ask a Question"});
         appEvent.setParams({"pagePath":document.location.href});
		 appEvent.setParams({"timeStamp":today}); 
         appEvent.setParams({"houseHold":"12345"});
		 appEvent.fire(); 
    }
});