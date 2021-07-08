({
	saveAdditionalHouseHoldMember : function(component, event) {
		var action = component.get("c.saveAdditionalHouseHoldMember");
        action.setParams({ houseHoldMemberData : JSON.stringify(component.get("v.formData"))});
 
        // Create a callback that is executed after 
        // the server-side action returns
        component.set("v.showSpinner", true); 
        action.setCallback(this, function(response) {
            var state = response.getState();
             component.set("v.showSpinner", false); 
            if (state === "SUCCESS") {
                if(response.getReturnValue()==='SUCCESS'){
                    var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "type":"SUCCESS",
                            "message": "Caretaker has been created successfully."
                        });
                        toastEvent.fire();
                                    }
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                 component.set("v.showSpinner", false); 
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
	}
})