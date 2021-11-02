/**
 * Created by karolbrennan on 11/21/18.
 */
({
    doInit: function(component, event, helper)
    { 
        
       helper.getStudents(component, event, helper);
        // get list of students
        
    },
   
  
    /* US:332932 --- commented for deployment */
    callOtherSchoolEnrollment: function(component, event, helper)
    {
        var selectedStudentId = event.currentTarget.value;
        var selectedStudentName = event.currentTarget.name;
        component.set("v.isOtherSchoolEnrollment",'true'); 
        var OSEcmp = component.find("OSEcmp");
        var message = OSEcmp.getMessage(selectedStudentId,selectedStudentName,'true');
    },
    closeOtherSchoolEnrollmentModel: function(component, event, helper)
    {
        component.set("v.isOtherSchoolEnrollment",'false');
        // get list of students
        //helper.getStudents(component, event, helper);
    },
    closeModal: function(component)
    {
        component.set("v.message",null);
    },
    /* Navigates to the selected url */
    navigate: function(component, event,helper)
    {
        //Swapna:for GTM
        if(event.currentTarget.dataset.buttonlbl == 'Contact Us')
        {
            var appEvent = $A.get("e.c:NES_GTMEvent"); 
            var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DDTHH:mm:ss");
            appEvent.setParams({"eventNm":"event"});
            appEvent.setParams({"eventValue":"pageview"});
            appEvent.setParams({"step":"contactUS"});
            appEvent.setParams({"stepValue":"contactUS"});
            appEvent.setParams({"pagePath":document.location.href});
            appEvent.setParams({"timeStamp":today}); 
            appEvent.setParams({"status":event.currentTarget.dataset.status}); 
            appEvent.setParams({"houseHold":"12345"});
            appEvent.fire(); 
        }
         //added for the US 335364 by Jagadish babu : Begin
        else if (event.currentTarget.dataset.buttonlbl == 'TELL US ABOUT NEXT YEAR'){
            component.set("v.loading", true);
            var dataset = event.currentTarget.dataset;
            var userId = $A.get("$SObjectType.CurrentUser.Id");
            console.log(dataset.studentid);
            console.log(dataset.programenrollmentid); 
            console.log(userId);    
            var action = component.get("c.createITRforNextYear");  
            action.setParams({
                studentId: dataset.studentid,
                programEnrollmentId: dataset.programenrollmentid
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if(state === "SUCCESS") {
                    console.log('Successfully created ITR record');
                    var urlparams = response.getReturnValue();
                    component.set("v.loading", false); 
                    var url = '/enrollment';
                    url = url + '?studentId=' + encodeURIComponent(dataset.studentid)
                        + '&caretakerId=' + userId
                        + '&programEnrollmentId=' + encodeURIComponent(urlparams.programEnrollmentId)
                        + '&processId=' + encodeURIComponent(urlparams.processId)
                        + '&studentGrade=' + encodeURIComponent(urlparams.gradeLevel);
                    $A.get("e.force:navigateToURL").setParams({
                        "url": url
                    }).fire();
                   
                }else{
                    console.log('Error');
                    component.set("v.loading", false);
                }
            });
            $A.enqueueAction(action);   
                    
        }
            else{
                   //added for the US 335364 by Jagadish babu : End    
                var url = event.currentTarget.dataset.link;
                var userId = $A.get("$SObjectType.CurrentUser.Id");
                //alert(url);
                if(url === '/enrollment') {
                    var dataset = event.currentTarget.dataset;
                    /**
             * changes added by anithap on 17/01/2019
             * added c__prefix to studentId,caretakerId,studentGrade,processId,programEnrollmentId.
             */
                   url = url + '?studentId=' + encodeURIComponent(dataset.studentid)
                    + '&caretakerId=' + userId
                    + '&programEnrollmentId=' + encodeURIComponent(dataset.programenrollmentid)
                    + '&processId=' + encodeURIComponent(dataset.processid)
                    + '&studentGrade=' + encodeURIComponent(dataset.placement);
                }
                /**
 * changes added by anithap on 17/01/2019
 * 
 */
                setTimeout(function(){ $A.get('e.force:refreshView').fire(); }, 5000);  //Added for Open Application User story 451172 -->DK
              	  $A.get("e.force:navigateToURL").setParams({
                       
                    "url": url
                     
                }).fire();
                              
              //helper.openApp(component, event, helper); 
             }
        
    },
    /* Handles add student submission */
    handleAddStudent: function(component, event, helper) {
        component.set("v.loading", true);
        var messageParam = event.getParam("message");
        if(messageParam !== undefined)
        {
            component.set("v.message", messageParam);
        }
        helper.getStudents(component, event, helper);
        
    },
    stepHover: function(component, event, helper) {
        helper.stepHover(component, event, helper);
    }
});