/**
 * Created by karolbrennan on 11/25/18.
 */
({
    doInit: function(component, event, helper)
    {
        // stuff here
    },
    clickButton: function(component, event, helper)
    {
        console.log("CLICKY CLICKY!");
        var action = component.get("c.callBatchUpdateTimeConstraint");
        action.fire();
    },
    chooseOne: function(component, event, helper)
    {
        var selected = event.getSource().get("v.value");
        var action = component.get("c.retrieveLogo");
        action.setParams({
            instituteId: selected
        });
        action.setCallback(this, function(response){
            console.log("Get that logo son!");
            var state = response.getState();
            if(state === "SUCCESS"){
                console.log("Response: ", response);
            } else {
                console.log("ERROR!", response.getError());
            }
        });
        $A.enqueueAction(action);
    }
})