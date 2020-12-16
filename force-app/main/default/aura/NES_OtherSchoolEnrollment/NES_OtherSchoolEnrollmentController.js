({
	
    doInit : function(component, event,helper) {
        //get method paramaters
        var params = event.getParam('arguments');
        if (params) {
            var selectedStudentId = params.selectedStudentId;
            var isOtherSchoolEnrollment = params.isOtherSchoolEnrollment;
            var selectedStudentName = params.selectedStudentName;
            component.set("v.selectedStudentId",selectedStudentId); 
            component.set("v.selectedStudentName",selectedStudentName);
            component.set("v.isOtherSchoolEnrollment","true");
            component.set("v.isLoaded","true");
            helper.getSchoolsToAttend(component, event,helper,selectedStudentId);
            
        }
    },
    closeOtherSchoolEnrollmentModel: function(component, event, helper)
    {
        helper.closeOtherSchoolEnrollmentModel(component, event, helper);
    },
    handleEnroll: function(component, event, helper)
    {
        component.set("v.isLoaded", "false");
         helper.handleEnroll(component, event, helper);
    },
    schoolSelect: function(component, event, helper)
    {
        if(component.get("v.School")!=null && component.get("v.School")!=''){
        helper.getSchoolYears(component, event, helper,component.get("v.School"));
        }
    },
    schoolYearSelect: function(component, event, helper)
    {
        alert('jjjjjj'+component.get("v.schoolYear"));
        if(component.get("v.schoolYear")!=null && component.get("v.schoolYear")!=''){
        helper.getGradeLevels(component, event, helper);
        }
    }
     
})