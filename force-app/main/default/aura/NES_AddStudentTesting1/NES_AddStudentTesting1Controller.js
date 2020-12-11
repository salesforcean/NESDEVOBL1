({
    doInit: function(component, event, helper)
    {
//        addStudent();
                //var studentData = component.get("v.newStudentData");
       helper.getNewStudent(component, event, helper, false);
    },
    confirm: function(component, event, helper)
    {
        var studentData = component.get("v.newStudentData");
        /* If any of the follow fields have been entered, open confirmation */  //added middle name and suffix for US116612
        if( studentData.firstName ||studentData.middleName|| studentData.lastName ||studentData.suffix || studentData.relationshipType || studentData.selectedSchoolYear || studentData.selectedSchoolId) {
            component.set("v.confirmOpen", true);
        } else {
            helper.cancel(component,event, helper);
        }
    },
    /* Used to close the add student block */
    cancel : function(component, event, helper)
    {
        helper.cancel(component,event,helper);
    },
    /* Used to open the add student block */
    addStudent: function(component, event, helper)
    {
        helper.getNewStudent(component, event, helper, true);
    },
    /* Used to submit the add student form */
    handleSubmit: function(component, event, helper)
    {
        component.set("v.loading", true);
        helper.submitStudentData(component, event, helper);
    },
    /* Select input handlers */
    handleYearSelect: function(component, event, helper)
    {
        helper.handleSchoolYearSelect(component, event,helper);
    },
    handleSchoolSelect: function(component, event, helper)
    {
        helper.handleSchoolSelect(component, event,helper);
    },
    relationshipChanged: function(component, event, helper)
    {
        component.set("v.showRelationshipError",false);
        component.set("v.newStudentData.relationshipType",event.currentTarget.getAttribute("value"));
    },
    /* Tells us whether the caretaker's students have loaded - if they have students close add student form */
    handleStudentsLoaded: function(component, event, helper) {
        var numberOfStudents = parseInt(event.getParam("numberOfStudents"));
        if(numberOfStudents > 0){
            component.set("v.addStudentActive", false);
        } else {
            component.set("v.addStudentActive", true);
        }
        component.set("v.numberOfStudents", numberOfStudents);
    },
    validateDate: function(component, event, helper) {
        console.log('We are here ready to remove the error');
        helper.validateDate(component, event, helper);
    },
     handleAddStudentAppEvent2: function(component, event, helper) {       
        var msg = event.getParam("message");
         alert('Hai');
         console.warn(msg);
        /* helper.getNewStudent(component, event, helper, true); */
         component.set("v.isOpen", true);
    } 
   
   
   
})