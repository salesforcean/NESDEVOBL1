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
                
                component.find('notifLib').showToast({
                    "variant": "SUCCESS",
                    "title": "SUCCESS",
                    "message": "Successfully Enrolled.",
                });
                helper.closeOtherSchoolEnrollmentModel(component, event, helper);
            }else {
                var error = response.getError();
                console.log("Error: ", error);
            }
        })
        $A.enqueueAction(action);
        
    },
        closeOtherSchoolEnrollmentModel: function(component, event, helper)
    {
        component.set("v.isOtherSchoolEnrollment",'false');
        component.set("v.isLoaded",'false');
        component.set("v.noSchools",'true');
        component.set("v.noYears",'true');
        component.set("v.noGradeLevel",'true');
        
        component.set("v.schoolsToAttend",[]);
        component.set("v.schoolYears",[]);
        component.set("v.grades",[]);
        
        component.set("v.selectedStudentId",'');
        component.set("v.selectedStudentName",'');
        $A.get('e.force:refreshView').fire();
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
        //alert(JSON.stringify("selectedSchool== "+selectedSchool));
        action.setParams({
            instituteName:selectedSchool,  
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var returnedResponse = response.getReturnValue();
                //alert(JSON.stringify(returnedResponse));
                if(response.getReturnValue().length > 0){
                    component.set("v.noSchools", false);
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
    
    	getGradeLevels : function(component, event, helper,selectedSchool) {
        var action = component.get("c.getGradeLevels");
            var instituteName= component.get("v.School");
            var selectedYr= component.get("v.schoolYear")
            //alert('instituteName== '+instituteName);
            //alert('selectedYr== '+selectedYr);
        action.setParams({
            instituteName:instituteName,
            selectedYr:selectedYr, 
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var returnedResponse = response.getReturnValue();
                //alert(JSON.stringify(returnedResponse));
                if(response.getReturnValue().length > 0){returnedResponse.forEach(grade => {
                        if(grade.hasOwnProperty('Name')){
                        
                        var studentGradeLevel = null;
                        switch(grade.Name){
                        case 'K':
                        grade.index = '0';
                        studentGradeLevel = 'Kindergarten';
                        break;
                        case '1':
                        grade.index = grade.Name;
                        studentGradeLevel = '1st Grade';
                        break;
                        case '2':
                        grade.index = grade.Name;
                        studentGradeLevel = '2nd Grade';
                        break;
                        case '3':
                        grade.index = grade.Name;
                        studentGradeLevel = '3rd Grade';
                        break;
                        default:
                        grade.index = grade.Name;
                        studentGradeLevel = grade.Name + 'th Grade';
                        break;
                    }
                                             grade.Name = studentGradeLevel;
                                             }
                                             });
                    
                    returnedResponse.sort(function(a, b) {
                        return a.index - b.index;
                    });
                    component.set("v.noYears", false);
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