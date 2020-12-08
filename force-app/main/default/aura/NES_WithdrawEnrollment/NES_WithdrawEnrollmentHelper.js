/**
 * Created by karolbrennan on 1/15/19.
 */
({
    handleInit: function(component,event,helper)
    {
        helper.clearMessages(component,event,helper);
        /* Get termination reasons */
        var action = component.get("c.getTerminationReasons");
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var result = response.getReturnValue();
                if(result.pickListValues) {
                    component.set("v.terminationReasons", result.pickListValues);
                }
            } else {
                console.log("Error:", response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    clearMessages: function(component,event,helper)
    {
        component.set("v.success", false);
        component.set("v.hasError", false);
        component.set("v.errorMessage", null);
        component.set("v.confirmationOpen",false);
    },
    submitWithdrawal: function(component,event,helper)
    {
        helper.clearMessages(component,event,helper);
        // Get withdrawal reason and program enrollment ids
        var withdrawalReason = component.get("v.withdrawalReason");
        var programEnrollmentId = component.get("v.programEnrollmentId");

        // If we don't have this information then we throw an error.
        if(!withdrawalReason || !programEnrollmentId || (!withdrawalReason && !programEnrollmentId)){
            component.set("v.hasError",true);
        } else {
            component.set("v.hasError",true);
            component.set("v.errorMessage",null);

            // Action for terminating application
            var action = component.get("c.terminateApplication");
            action.setParams({
                opportunityId: programEnrollmentId,
                withdrawalReason: withdrawalReason
            });
            action.setCallback(this, function(response){
                var peakResponse = response.getReturnValue();
                if(peakResponse.success){
                    component.set("v.success", true);
                    // If successful we show a brief message then redirect to the dashboard
                    window.setTimeout(
                        $A.getCallback(function(){
                            var redirect = $A.get("e.force:navigateToURL");
                            redirect.setParams({
                                "url" : "/dashboard"
                            });
                            redirect.fire();
                        }), 3000
                    );
                } else {
                    component.set("v.hasError",true);
                    component.set("v.errorMessage", peakResponse.messages[0]);
                }
            });
            
            $A.enqueueAction(action);
        }
    }
})