/**
 * Created by triciaigoe on 12/14/18.
 */
({
    grabCaretaker: function(component, event, helper) {
        var studentId = component.get("v.studentId");
        var action = component.get("c.getCaretakers");
        action.setParams({
            studentIdString : studentId
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS") {
                var peakResponse = response.getReturnValue();
                if(peakResponse.results) {
                    component.set("v.caretakerRecords", peakResponse.results);
                }
            } else {
                var error = response.getError();
                console.log("ERROR", error);
            }
        });

        $A.enqueueAction(action);
    }
})