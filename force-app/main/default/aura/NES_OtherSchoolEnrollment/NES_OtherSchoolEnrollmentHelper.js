({
    // called from 'handleEnroll' method
    handleEnroll: function(component, event, helper)
    {
        var schoolYear = component.find("Year").get("v.value");
        console.log('schoolYear='+schoolYear);
        var x = component.get("v.schoolYear");
        console.log('x=='+x);
        
        
        
        var action = component.get("c.otherSchoolEnrollment"); // calling 'otherSchoolEnrollment' method
        // setting parameters for the calling method
        action.setParams({
            studentId:component.get("v.selectedStudentId"),
            instituteNam:component.get("v.School"),
            //schoolYear:component.find("Year").get("v.value"),
            schoolYear:component.get("v.schoolYear"),
            
            gradeLevels:component.get("v.grade"),
           // callType:'application',   
            callType:'Household',
            enrollFlag:true,
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            // checking if the response state is 'SUCCESS'
            if(state === "SUCCESS"){
                var peakResponse = response.getReturnValue();
                // notifying 'SUCCESS' message 
                /*
                component.find('notifLib').showToast({
                    "variant": "SUCCESS",
                    "title": "SUCCESS",
                    "message": "Successfully Enrolled.",
                });
                */
                console.log(peakResponse);
                component.set("v.isOpen", true);
                if(peakResponse.success){
                    
                    component.set("v.success", true);
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
                    component.set("v.message", peakResponse.messages[0]);
                }
                //calling 'closeOtherSchoolEnrollmentModel' method
                //helper.closeOtherSchoolEnrollmentModel(component, event, helper);
            }else {
                var error = response.getError();
                console.log("Error: ", error);
            }
        })
        $A.enqueueAction(action);
        
    },
    // called from 'closeOtherSchoolEnrollmentModel' method
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
    // called from 'doInit' method
    getSchoolsToAttend : function(component, event, helper,selectedStudentId) {
        var action = component.get("c.getSchoolsToAttend"); // calling 'getSchoolsToAttend' method
        // setting parameters for the calling method
        action.setParams({
            selectedStudentId:selectedStudentId,  
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            // checking if the response state is 'SUCCESS'
            if(state === "SUCCESS"){
                var returnedResponse = response.getReturnValue();
                if(response.getReturnValue().length > 0){
                    component.set("v.noSchoolYears", false);
                    component.set("v.schoolsToAttend", returnedResponse);
                } else{
                    // notifying 'Warning' message
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
    // called from 'schoolSelect' method
    getSchoolYears : function(component, event, helper,selectedSchool) {
        var action = component.get("c.getSchoolYears");
        
        action.setParams({
            instituteName:selectedSchool,  
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var returnedResponse = response.getReturnValue();
                /*
                var blankVal = {"Id":"","Name":"-- -Select school year- --"};
                returnedResponse.unshift(blankVal);
                console.log('returnedResponse====='+JSON.stringify(returnedResponse));
                */
                if(response.getReturnValue().length > 0){
                    component.set("v.schoolYears", returnedResponse);
                    //component.find("Year").set("v.value",returnedResponse[returnedResponse.length-1].Name);
                    //component.find("Year").set("v.value",returnedResponse[0].Name);
                    
                    component.set("v.noSchools", false);
                    
                    var schoolYear = component.find("Year").get("v.value");
                    console.log('schoolYear00000=='+schoolYear);
                    //helper.getGradeLevels(component, event, helper);
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
    // called from 'schoolYearSelect' method
    getGradeLevels : function(component, event, helper,selectedSchool) {
        var action = component.get("c.getGradeLevels");
        var instituteName= component.get("v.School");
        var selectedYr= component.find("Year").get("v.value");
        action.setParams({
            instituteName:instituteName,
            selectedYr:selectedYr, 
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var returnedResponse = response.getReturnValue();
                if(response.getReturnValue().length > 0)
                {
                    /*
                    returnedResponse.forEach(grade => {
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
                                                         */
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