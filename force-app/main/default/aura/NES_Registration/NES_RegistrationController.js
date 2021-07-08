/**
 * Created by karolbrennan on 10/16/18.
 */
({
    doInit: function(component, event, helper)
    {
        var detectRegistrationPage = $A.get("e.c:NES_DetectRegistrationPage");
        detectRegistrationPage.setParams({
            "onRegistrationPage" : true
        });
        detectRegistrationPage.fire();
    },
    isUsernameAvailable: function(component, event, helper)
    {
        helper.isUsernameAvailable(component, event, helper);
    },
    togglePassword: function(component, event, helper) {
        var showPassword = component.get("v.showPassword");
        component.set("v.showPassword", !showPassword);
    },
    handleInput: function(component, event, helper)
    {
        var formData = component.get("v.formData");
        /* Get existing formData if any - if not, initialize as empty object */
        if(formData === null){
            formData = {
                passwordValidation: {
                    hasLowercase: false,
                    hasUppercase: false,
                    hasNumber: false,
                    hasSpecialChar: false
                },
                passwordUniqueness:{
                    hasEight: false,
                    hasUsername: false,
                    hasFirstName: false,
                    hasLastName: false
                },
                validEmail: false,
                validUsername: true
            };
        }
        component.set("v.formData", formData);
        helper.processInput(component, event, helper);
    },
    nextStep: function(component, event, helper)
    {
        var currentStep = parseInt(component.get("v.currentStep"));
        switch(currentStep)
        {
            case 1:
                helper.goToNextStep(component, event, helper);
                break;
            case 2:
                helper.goToNextStep(component, event, helper);
                break;
            default:
                var detectRegistrationPage = $A.get("e.c:NES_DetectRegistrationPage");
                detectRegistrationPage.setParams({
                    "onRegistrationPage" : false
                });
                detectRegistrationPage.fire();
                helper.goToURL(component, 'dashboard');
                break;
        }
    },
    createAccount: function(component, event, helper)
    {
        //helper.createRecord(component, event, helper);
        helper.checkUserNameAndProceed(component, event, helper);
    },
    
    navigate: function(component, event, helper){
        helper.goToURL(component, 'dashboard');
    }
});