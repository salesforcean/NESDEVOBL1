/**
 * Created by karolbrennan on 11/21/18.
 */
({
    doInit: function(component, event, helper)
    {
        // get list of students
        helper.getStudents(component, event, helper);
    },
    callOtherSchoolEnrollment: function(component, event, helper)
    {
        var selectedStudentId = event.currentTarget.value;
        alert(selectedStudentId);
        var selectedStudentName = event.currentTarget.name;
        alert(JSON.stringify(selectedStudentName));
        //console.log(selectedStudentId);
        //component.set("v.selectedStudentId",selectedStudentId);
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
    navigate: function(component, event)
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
        if (event.currentTarget.dataset.buttonlbl == 'TELL US ABOUT NEXT YEAR'){
            alert('TELL US ABOUT NEXT YEAR');
        }
       
		//added for the US 335364 by Jagadish babu : End    
        var url = event.currentTarget.dataset.link;
        var userId = $A.get("$SObjectType.CurrentUser.Id");
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
        $A.get("e.force:navigateToURL").setParams({
            "url": url
        }).fire();
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