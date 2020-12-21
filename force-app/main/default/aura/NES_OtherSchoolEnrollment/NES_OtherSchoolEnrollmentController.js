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
    // called when Close Button is clicked
    closeOtherSchoolEnrollmentModel: function(component, event, helper)
    {
        helper.closeOtherSchoolEnrollmentModel(component, event, helper);
    },
    // called when Enroll Button is clicked
    handleEnroll: function(component, event, helper)
    {
        //component.set("v.isLoaded", "false");
        helper.handleEnroll(component, event, helper);
    },
    // called when School is selected
    schoolSelect: function(component, event, helper)
    {
        if(component.get("v.School")!=null && component.get("v.School")!=''){
            helper.getSchoolYears(component, event, helper,component.get("v.School"));
        } else{
            component.find("Year").set("v.value","");
            component.find("grade").set("v.value","");
            component.set("v.noSchools", true); 
            component.set("v.noYears", true); 
        }
    },
    // called when year is selected
    schoolYearSelect: function(component, event, helper)
    {
        var schoolYear = component.find("Year").get("v.value");
        if(schoolYear!=null && schoolYear!=''){
            helper.getGradeLevels(component, event, helper);
        }
    },
     closeModal: function (component,event,helper)
    {
        component.set('v.isOpen',false);
    },
    
})