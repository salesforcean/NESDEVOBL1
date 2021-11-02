/**
* Created by karolbrennan on 1/16/19.
*/
({
    // Added by Chinnamanaidu- task 120281
    doInit: function(component, event, helper)
    {
        //add by Maddileti for US # 335371 on 12/04/2020 
        var yearValue = component.get("v.schoolYeara");
        helper.getGrades(component, event, helper, yearValue);
        helper.getSchoolYears(component, event, helper);
        //helper.InvokeReactive(component,event,helper);
        //have to change method name as ("EnrollmentInfo")
        helper.getEnrollmentInfo(component, event, helper);        
    },
    closeModal: function (component,event,helper)
    {
        component.set('v.isOpen',false);
        component.set('v.enrollmentSuccessMessage',false);
    },
    handleSubmit: function (component, event, helper)
    {
        component.set("v.hasError",false);
        component.set("v.success",false);
        component.set("v.message",null);
        component.set('v.isOpen', true);
        var programEnrollmentId = component.get("v.programEnrollmentId");
        
        // Action for terminating application
        var action = component.get("c.reactivateStudent");
        action.setParams({
            programEnrollmentId: programEnrollmentId          
        });
        action.setCallback(this, function(response){
            var peakResponse = response.getReturnValue();
            console.log(peakResponse);
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
                component.set("v.message", peakResponse.messages[0]);
            }
        });
        
        $A.enqueueAction(action);
    },
    // Open Modal window -Added by Chinnamanaidu- task 120281
    openModel: function(component, event, helper) {
        // Set isModalOpen attribute to true
        
        var set = component.get('v.isSet')
        if(set){
            
            component.set("v.isModalOpen", true);
        }
    },
    closeModel: function(component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.isModalOpen", false);
    },
    
    // Add by Maddileti for US #335371
    reactivateAction: function (component, event, helper)
    {
        
        var button=event.target.id;
        
        console.log('Button Clicked :'+button);
        if(button=='reenroll'){
            console.log('display re enroll button ');
            component.set("v.enrollFlag",true);
            component.set("v.reactiveFlag",false);
            component.set("v.disableGrade",true);
        } 
        else if(button=='reactive'){
            component.set("v.reactiveFlag",true);
            component.set("v.enrollFlag",false);
            
        }
        var schoolYeara=component.get('v.schoolYeara');
        console.log('schoolYeara:'+schoolYeara);
        
        var gradeLevelId=component.get('v.gradeLevelId');
        console.log('gradeLevelId:'+gradeLevelId);
        var  studentGradeLevel = null;
        switch(gradeLevelId){
            case 'Kindergarten':
                studentGradeLevel = 'K';
                break;
            case '1st Grade':
                studentGradeLevel = '1';
                break;
            case '2nd Grade':
                studentGradeLevel = '2';
                break;
            case '3rd Grade':
                studentGradeLevel = '3';
                break;
            default:
                studentGradeLevel = gradeLevelId.toString().slice(0,-8);
                break;
        }
        console.log('studentGradeLevel=='+studentGradeLevel);
        component.set('v.gradeLevelId',studentGradeLevel);
        component.set('v.isOpenReactivation', true);
        
        //  component.set('v.enrollFlag',true);
        
        var year=component.find('Year');
        year.set('v.value',component.get('v.schoolYeara'));
        // alert(component.get('v.schoolYeara'));
        var grade=component.find('Grade');
        grade.set('v.value',component.get('v.gradeLevelId'));
        
        
    },
    
    reReactivate : function(component, event, helper){
        var validity1 = component.find("Year").checkValidity();
        var validity2 = component.find("Grade").checkValidity();
        if(!validity1 || !validity2) return;
        
        var newSchoolYear=component.find('Year').get('v.value');
        var gradeNew=component.find('Grade').get('v.value');
        console.log('New School Year :'+newSchoolYear);
        console.log('New Grade Selected :'+gradeNew);
        var previousSchoolYear=component.get('v.schoolYeara');
        var previousGrade=component.get("v.gradeLevelId");
        
        //alert('Value of Result1' + component.get("v.peEnrollmentType"));
        var Result = component.get("v.EnrollmentInfo");
        //alert('Result');
        //alert('Value of Result2' + Result);
        
        //Added by Ravi # Us345735 on 01/19/2021
        if(newSchoolYear<previousSchoolYear){
            component.set("v.reactivateMessage",true);
        }
        // Ended Here 
        //TODO:::: PE Status = 'Inactive' and Enrollment type =’Returning Student’ 
        //else if( Result = 'ReActivation' && previousSchoolYear==newSchoolYear) 
        
        else if( Result =='InitReActivation' && previousSchoolYear==newSchoolYear) 
        {
            //alert('I am here');
            //alert('Value of Result3' + Result);
            helper.reactivateORreenrolledSameYear(component,event,helper);  
        }
       /* else if(previousSchoolYear==newSchoolYear){ 
                if(previousGrade==gradeNew){
                    component.set("v.isError",false);
                    
                    //this.handleSubmit(component, event, helper);
                    var a = component.get('c.handleSubmit');
                    $A.enqueueAction(a);
                    helper.InvokeReactive(component,event,helper);
                }
                else{
                    
                    
                    
                    component.set("v.isError",true);
                    
                }
            } */
        else if(previousSchoolYear==newSchoolYear)
        {
              //alert('Value of Result4' + Result);
            if(Result =='InitReActivation')
              
                helper.reactivateORreenrolledSameYear(component,event,helper);
            
            else if(previousGrade==gradeNew){
                component.set("v.isError",false);
                //this.handleSubmit(component, event, helper);
               // alert('handle');
                    var a = component.get('c.handleSubmit');
                $A.enqueueAction(a);
                helper.InvokeReactive(component,event,helper);
            }
                else{
                   // alert('erro');
                    component.set("v.isError",true);
                }
        } 
            else{ 
               // alert('else ro');
                component.set('v.isOpen', true);
                var stId=component.get('v.studentId');
                var acName=component.get("v.acadName");
                var studentName=component.get("v.studentName");
                console.log('std:'+stId);
                var action = component.get("c.nextYearEnrollment");
                action.setParams({
                    studentId: stId, 
                    instituteNam:acName,
                    schoolYear : newSchoolYear,
                    gradeLevels : gradeNew,
                    
                    callType: 'community',
                    enrollFlag: component.get("v.enrollFlag") ,
                    programEnrollmentId: component.get("v.programEnrollmentId") 
                });
                action.setCallback(this, function(response){
                    var peakResponse = response.getReturnValue();
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
                        
                        
                    } else {
                        component.set("v.hasError",true);
                        component.set("v.message", peakResponse.messages[0]);
                    }
                });
                $A.enqueueAction(action);
            }
        
    },
    
    // End by Maddileti for US #335371
    closeModals: function (component,event,helper)
    {
        component.set('v.isOpenReactivation',false);
        
    }, 
    
    reEnrollmentAction : function (component, event, helper){
        helper.getNextYearAvailability(component, event, helper);          
    },
    
    // Add by Maddileti for US # 332934 on 12/16/2020 
    gradeSelect: function (component,event,helper){
        component.set("v.isError",false);
        
        //Added By Ravi # Us345735 on 01/19/2021
        component.set("v.reactivateMessage",false);
        component.set("v.reEnrollmentMessage",false);
        var newSchoolYear=component.find('Year').get('v.value');
        console.log('New School Year :'+newSchoolYear);
        var previousSchoolYear=component.get('v.schoolYeara');
        console.log('previousSchoolYear Selected :'+previousSchoolYear);
        if(component.get("v.enrollFlag")){
            if(previousSchoolYear==newSchoolYear){ 
                
                component.set("v.disableGrade",true);
            } else if (previousSchoolYear!= newSchoolYear){
                
                component.set("v.disableGrade",false);
                
                
            }
        }
        //var newSchoolYear=component.find('Year').get('v.value');
        component.set("v.gradeLevels",[]);
        component.find('Grade').set('v.value','');
        helper.getGrades(component, event, helper,newSchoolYear);
        
    },
    reEnrollingNewSY : function (component,event,helper){
        var validity1 = component.find("Year").checkValidity();
        var validity2 = component.find("Grade").checkValidity();
        if(!validity1 || !validity2) return; 
        
        var newSchoolYear=component.find('Year').get('v.value');
        var gradeNew=component.find('Grade').get('v.value');
        console.log('ReEnroll New School Year :'+newSchoolYear);
        console.log('ReEnroll New Grade Selected :'+gradeNew);
        var previousSchoolYear=component.get('v.schoolYeara');
        var previousGrade=component.get("v.gradeLevelId");
        var Result = component.get("v.EnrollmentInfo"); // added by Maddileti
        //alert(Result);
        
        // Added by Ravi # Us345735 
        if(newSchoolYear<previousSchoolYear){
            component.set("v.reactivateMessage",true);  
        }
        // Ended Here 
        //TODO:::: PE Status = 'Withdrawn' and the latest Enrollment record's Withdrawal category = 'No Show')
        //else if( Result= ReEnrollment && previousSchoolYear==newSchoolYear) 
        
        /*** 
        else if( Result == 'ReEnrollment' && previousSchoolYear==newSchoolYear) 
        {
            helper.reactivateORreenrolledSameYear(component,event,helper);  
        }
        else if(previousSchoolYear==newSchoolYear){
            
            component.set("v.reEnrollmentMessage",true);
            
        }
           ***/
        else if(previousSchoolYear==newSchoolYear)
        {
            if(Result == 'InitReEnrollment')
                helper.reactivateORreenrolledSameYear(component,event,helper);
            
            else
                component.set("v.reEnrollmentMessage",true);
        } else {
            component.set("v.reEnrollmentMessage",false);
            component.set('v.enrollmentSuccessMessage', true);
            var stId=component.get('v.studentId');
            var acName=component.get("v.acadName");
            var studentName=component.get("v.studentName");
            console.log('std:'+stId);
            var action = component.get("c.nextYearEnrollment");
            action.setParams({
                studentId: stId, 
                instituteNam:acName,
                schoolYear : newSchoolYear,
                gradeLevels : gradeNew,
                callType: 'community',
                enrollFlag: component.get("v.enrollFlag") ,
                programEnrollmentId: component.get("v.programEnrollmentId") 
            });
            action.setCallback(this, function(response){
                var peakResponse = response.getReturnValue();
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
                    
                    
                } else {
                    component.set("v.hasError",true);
                    component.set("v.message", peakResponse.messages[0]);
                }
            });
            $A.enqueueAction(action); 
        }       
        
    },
    
    // End by Maddileti for US # 332934 on 12/16/2020
    // Add by Maddileti for Defect # 345663 on 12/22/2020
    gradeChange : function (component,event,helper) {
        
        var newSchoolYear=component.find('Year').get('v.value');
        var gradeNew=component.find('Grade').get('v.value');
        var previousSchoolYear=component.get('v.schoolYeara');
        var previousGrade=component.get("v.gradeLevelId");
        
        if(newSchoolYear == previousSchoolYear && gradeNew == previousGrade){
            component.set("v.isError",false);
        }         
    }
    // End by Maddileti for Defect # 345663 on 12/22/2020
    
    
})