({
    // called from init method 
    doInit : function(component, event, helper) {
        // calling 'validatePE' method in the controller 'NES_ReactivationNewSYHelper'
        var action = component.get("c.validatePE");
        
        // passing recordID as parameter to the method
        action.setParams({
            programEnrollmentId:component.get("v.recordId"),  
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var returnedResponse = response.getReturnValue();
                if(returnedResponse.isValid=='valid'){
                    component.set("v.PErecordDetails",returnedResponse);
                    
                    helper.getSchoolYears(component, event, helper);   
                } else {
                    /*
                    component.set("v.isError",true);
                    component.set("v.errorMessage",JSON.stringify(returnedResponse.isValid));
                    */
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                    component.find('notifLib').showToast({
                        "variant": "error",
                        "title": "Invalid PE!",
                        "message": JSON.stringify(returnedResponse.isValid),
                    });
                    
                }
                
            } else {
                var error = response.getError();
                component.set("v.isError",true);
                component.set("v.errorMessage","Please try again; "+error);
                console.log("Error: ", error);
            }
        })
        $A.enqueueAction(action);
    },
    getGrades : function(component, event, helper, selectedYr) {
        var PErecordDetails = component.get("v.PErecordDetails");
        var action = component.get("c.getGradeLevels");
        
        action.setParams({
            selectedYr:selectedYr,
            instituteName:PErecordDetails.programEnrollment.hed__Account__r.Parent.Name,
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var returnedResponse = response.getReturnValue();
                console.log(JSON.stringify(response.getReturnValue()));
                if(response.getReturnValue().length > 0){
                    component.set("v.noGradeLevel", false);
                    
                    
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
                    
                    component.set("v.gradeLevels", returnedResponse);
                } else{
                    component.set("v.gradeLevels", '');
                    component.set("v.noGradeLevel", true);
                }
                
            } else {
                var error = response.getError();
                console.log("Error: ", error);
            }
        })
        $A.enqueueAction(action);
    },
    handleContinue : function(component, event, helper) {
        var action = component.get("c.newYearReactivate");
        var PErecordDetails = component.get("v.PErecordDetails");
        
        var grade = component.get("v.gradeLevel");
        action.setParams({
            studentId:PErecordDetails.programEnrollment.hed__Contact__c,
            instituteNam:PErecordDetails.programEnrollment.hed__Account__r.Parent.Name,
            schoolYear:component.get("v.schoolYear"),
            gradeLevels:grade=='0'?'K':grade,
            callType:'application',
            enrollFlag:true,
            programEnrollmentId:PErecordDetails.programEnrollment.Id
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
    getSchoolYears : function(component, event, helper) {
        var PErecordDetails = component.get("v.PErecordDetails");
        var action = component.get("c.getSchoolYears");
        action.setParams({
            instituteName:PErecordDetails.programEnrollment.hed__Account__r.Parent.Name,  
            omitPEYearId:PErecordDetails.programEnrollment.Start_Year__c,
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var returnedResponse = response.getReturnValue();
                
                if(response.getReturnValue().length > 0){
                    component.set("v.noSchoolYears", false);
                    component.set("v.schoolYears", returnedResponse);
                } else{
                    component.find('notifLib').showToast({
                        "variant": "warning",
                        "title": "Warning!",
                        "message": "No new years for the Academic Program."
                    });
                }
                component.set("v.loaded", true);
                
            } else {
                var error = response.getError();
                console.log("Error: ", error);
            }
        })
        $A.enqueueAction(action);
    }
    
})