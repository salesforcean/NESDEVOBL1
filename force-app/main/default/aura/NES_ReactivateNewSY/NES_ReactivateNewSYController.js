({
    // called in the intialisation from 'init' handler
    doInit : function(component, event, helper) {
        helper.doInit(component, event, helper);
    },
    // called on click of 'Continue' button
    handleFireContinue : function(component, event, helper) {
        component.set("v.loaded", false);
        helper.handleContinueHelper(component, event, helper);
    },
    // called on Year selection 
    onYearChange : function(component, event, helper) {
        if(component.get("v.schoolYear")!=null && component.get("v.schoolYear")!=''){
        helper.getGrades(component, event, helper,component.get("v.schoolYear"));
        }
    },

})