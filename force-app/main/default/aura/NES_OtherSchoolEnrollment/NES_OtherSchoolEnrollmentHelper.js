({
	getSchoolsToAttend : function(component, event, helper,selectedStudentId) {
        var action = component.get("c.getSchoolsToAttend");
        action.setParams({
            selectedStudentId:selectedStudentId,  
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var returnedResponse = response.getReturnValue();
                alert(JSON.stringify(schoolsToAttend));
                if(response.getReturnValue().length > 0){
                    //component.set("v.noSchoolYears", false);
                    component.set("v.schoolsToAttend", returnedResponse);
                } else{
                    component.find('notifLib').showToast({
                        "variant": "warning",
                        "title": "Warning!",
                        "message": "No new years Schools to select."
                    });
                }
                
            } else {
                var error = response.getError();
                console.log("Error: ", error);
            }
        })
        $A.enqueueAction(action);
	}
})