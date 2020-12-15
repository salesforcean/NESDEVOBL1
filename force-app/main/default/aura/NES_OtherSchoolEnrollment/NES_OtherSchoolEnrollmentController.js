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
    handleEnroll: function(component, event, helper)
    {
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
        if(component.get("v.schoolYear")!=null && component.get("v.schoolYear")!=''){
        helper.getGradeLevels(component, event, helper,component.get("v.School"),component.get("v.schoolYear"));
        }
    }
     
})