({
    handleEnroll: function(component, event, helper)
    {
        var action = component.get("c.otherSchoolEnrollment");
        action.setParams({
            studentId:component.get("v.selectedStudentId"),
            instituteNam:component.get("v.School"),
            schoolYear:component.get("v.schoolYear"),
            gradeLevels:component.get("v.grade"),
            callType:'application',
            enrollFlag:true,
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var returnedResponse = response.getReturnValue();
                component.set("v.loaded", true);
                component.find('notifLib').showToast({
                    "variant": "SUCCESS",
                    "title": "SUCCESS",
                    "message": "Successfully reactivated.",
                });
                $A.get("e.force:closeQuickAction").fire();
            }else {
                var error = response.getError();
                console.log("Error: ", error);
            }
        })
        $A.enqueueAction(action);
        
    },
	getSchoolsToAttend : function(component, event, helper,selectedStudentId) {
        var action = component.get("c.getSchoolsToAttend");
        console.log("*****selectedStudentId  = "+selectedStudentId);
        action.setParams({
            selectedStudentId:selectedStudentId,  
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var returnedResponse = response.getReturnValue();
                //alert(JSON.stringify(returnedResponse));
                if(response.getReturnValue().length > 0){
                    component.set("v.noSchoolYears", false);
                    component.set("v.schoolsToAttend", returnedResponse);
                } else{
                    component.find('notifLib').showToast({
                        "variant": "warning",
                        "title": "Warning!",
                        "message": "No available Schools to select."
                    });
                }
                
            } else {
                var error = response.getError();
                console.log("Error: ", error);
            }
        })
        $A.enqueueAction(action);
	},
    	getSchoolYears : function(component, event, helper,selectedSchool) {
        var action = component.get("c.getSchoolYears");
            alert(JSON.stringify("selectedSchool== "+selectedSchool));
        action.setParams({
            selectedSchool:selectedSchool,  
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var returnedResponse = response.getReturnValue();
                alert(JSON.stringify(returnedResponse));
                if(response.getReturnValue().length > 0){
                    //component.set("v.noSchoolYears", false);
                    component.set("v.schoolYears", returnedResponse); 
                } else{
                    component.find('notifLib').showToast({
                        "variant": "warning",
                        "title": "Warning!",
                        "message": "There are no years available for slected school."
                    });
                }
                
            } else {
                var error = response.getError();
                console.log("Error: ", error);
            }
        })
        $A.enqueueAction(action);
	},
    
    	getGradeLevels : function(component, event, helper,selectedSchool,instituteName,selectedYr) {
        var action = component.get("c.getGradeLevels");
        action.setParams({
            selectedYr:selectedYr, 
            instituteName:instituteName,
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var returnedResponse = response.getReturnValue();
                
                alert(JSON.stringify("getGradeLevels== "+returnedResponse));
                if(response.getReturnValue().length > 0){
                    component.set("v.grades", returnedResponse);
                } else{
                    component.find('notifLib').showToast({
                        "variant": "warning",
                        "title": "Warning!",
                        "message": "There are no grades available for slected school and year."
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