({
	
    doInit : function(component, event,helper) {
        //get method paramaters
        var params = event.getParam('arguments');
        if (params) {
            var selectedStudentId = params.selectedStudentId;
            var isOtherSchoolEnrollment = params.isOtherSchoolEnrollment;
            var selectedStudentName = params.selectedStudentName;
            alert(selectedStudentId + " 888888" + isOtherSchoolEnrollment+'selectedStudentId'+selectedStudentName);
            component.set("v.selectedStudentId",selectedStudentId); 
            component.set("v.selectedStudentName",selectedStudentName);
            component.set("v.isOtherSchoolEnrollment","true");
            helper.getSchoolsToAttend(component, event,helper,selectedStudentId);
            
        }
    },
    closeOtherSchoolEnrollmentModel: function(component, event, helper)
    {
        component.set("v.isOtherSchoolEnrollment",'false');
    },
     
})