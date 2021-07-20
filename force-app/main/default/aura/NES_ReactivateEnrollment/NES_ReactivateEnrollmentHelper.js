({
    
    InvokeReactive: function(component,event,helper)
    {
        var studentId = component.get("v.studentId");
        var action = component.get("c.displayPopupReg");
        console.log("studentId", studentId);
        
        action.setParams({
            studentId: studentId,
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var result = response.getReturnValue();
                if(result) {
                    // component.set("v.isModalOpen", true);
                    component.set("v.isSet", true);
                    
                }
            } else {
                console.log("Error:", response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    // Add by Maddileti for US #335371
    getGrades : function(component, event, helper, yearvalue) {
        // var newSchoolYear=component.find('Year').get('v.value'); 
        var action = component.get("c.getGradeLevels");
        action.setParams({
            instituteName:component.get("v.acadName"),
            year : yearvalue
            
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var returnedResponse = response.getReturnValue();
                console.log(component.get("v.schoolYeara"));
                component.set("v.gradeLevels", returnedResponse);
                
            } else {
                var error = response.getError();
                console.log("Error: ", error);
            }
        })
        $A.enqueueAction(action);
    },
    getSchoolYears : function(component, event, helper) {
        var action = component.get("c.getSchoolYears");
        action.setParams({
            instituteName:component.get("v.acadName"),  
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var returnedResponse = response.getReturnValue();
                console.log(JSON.stringify(returnedResponse));
                component.set("v.schoolYears", returnedResponse);
                component.set('v.GradeFlag',true);
            } else {
                var error = response.getError();
                console.log("Error: ", error);
            }
        })
        $A.enqueueAction(action);
    },
    
    // End by Maddileti for US #335371 
    
    getNextYearAvailability: function(component, event, helper){
        console.log('----entered into helper-----');
        var schoolName = component.get("v.schoolName");
        var currentSchoolYr = component.get("v.schoolYeara");
        var action = component.get("c.getNextYearAvailability");        
        var result = true;
        action.setParams({
            instituteName:schoolName,  
            currentSchoolYear : currentSchoolYr,
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log(state);
            if(state === "SUCCESS"){
                var returnedResponse = response.getReturnValue();
                if(!returnedResponse){
                    component.set("v.hasError",true);
                    component.set("v.message", "Next school year is not available. Please contact Support");
                }
            }
            else {
                component.set("v.hasError",true);
                component.set("v.message", "Next school year is not available. Please contact Support")
            }
        });
        $A.enqueueAction(action);
        
        
    },
    // Added by Maddileti for US 389103 on 16/07/2021
    getpeEnrollmentType: function (component, event, helper){     
        var programEnrollmentId = component.get("v.programEnrollmentId");
        console.log('programEnrollmentId123:'+programEnrollmentId);
        var action = component.get("c.getPEEnrStatus");
        action.setParams({
            peId: programEnrollmentId          
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var returnedResponse = response.getReturnValue();
                console.log('getreeess:'+returnedResponse);
                //alert(returnedResponse);
                component.set("v.peEnrollmentType", returnedResponse);
                
            } else {
                var error = response.getError();
                console.log("Error: ", error);
            }
        })
        $A.enqueueAction(action);
        
    } ,
    reactivateORreenrolledSameYear : function(component, event, helper){
        //alert('NES_ReactivateEnrollmentHelper In reactivateORreenrolledSameYear');
        
        var stId=component.get("v.studentId");
        var programEnrollmentId = component.get("v.programEnrollmentId");
        
        var action = component.get("c.doReEnrollment");
        action.setParams({
            studentContactId: stId, 
            studentPeId: programEnrollmentId
        });
        action.setCallback(this, function(response){
            var peakResponse = response.getReturnValue();
            //alert('Response from Apex Controller '+ peakResponse.success);
            console.log(peakResponse);
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
				//$A.get('e.force:refreshView').fire();
                
            } else {
                component.set("v.hasError",true);
                component.set("v.message", peakResponse.messages[0]);
            }
        });
        $A.enqueueAction(action);
    }
    // End by Maddileti for US 389103 on 16/07/2021
    
})