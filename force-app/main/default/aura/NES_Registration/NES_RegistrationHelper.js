/**
 * Created by karolbrennan on 10/24/18.
 */
({
//    Commenting for the sake of the Demo on the Monday 26/11
//    isUsernameAvailable: function(component, event, helper)
//    {
//        component.set("v.loading", true);
//        var username = component.get("v.uName");
//        var action = component.get('c.checkUserNameAvailibility');
//        action.setParams({
//            'userInput' : username
//        });
//        action.setCallback(this, function(response){
//            var state = response.getState();
//            if(state === "SUCCESS"){
//                component.set("v.usernameAvailable", response.getReturnValue());
//                component.set("v.usernameChecked", true);
//                component.set("v.loading", false);
//                helper.validateStep2(component, event, helper);
//            }
//        });
//        $A.enqueueAction(action);
//    },
    goToNextStep: function(component, event, helper) {
        var currentStep = parseInt(component.get("v.currentStep")) + 1;
        var newStep = currentStep.toString();
        if(currentStep !== 4){
            var changeStep = $A.get("e.c:NES_RegistrationStepEvent");
            changeStep.setParams({
                "currentStep" : newStep
            });
            changeStep.fire();
            component.set("v.currentStep", newStep);
        }
    },
    processInput: function(component, event, helper)
    {
        /* Get form data */
        var formData = component.get("v.formData");
        /* Get field and value */
        var field = event.getSource().get("v.name");
        var value = event.getSource().get("v.value");

        switch(field)
        {
            case 'email':
                formData[field] = value.replace(" ", "");
                component.set("v.email", formData[field]);
                component.set("v.formData", formData);
                helper.validateEmail(component, event, helper);
                if(component.get("v.step1Complete") === true){
                    var action = component.get('c.emailExists');
                    action.setParams({
                        'email': formData.email
                    });
                    action.setCallback(this, function(response){
                        var state = response.getState();

                        if(state === "SUCCESS"){
                            if(response.getReturnValue() === true){
                                component.set("v.emailExists",true);
                                component.set("v.step1Complete",true);
                            }
                            else{
                                component.set("v.emailExists",false);
                                component.set("v.step1Complete",true);
                            }
                        }
                    });
                    $A.enqueueAction(action);
                }
                else{
                            component.set("v.emailExists",false);
                        }
                break;
            case 'uName':
                formData[field] = value.trim();
                component.set("v.uName", formData[field]);
                console.log('uname>>>',component.get('v.uName'));
                component.set("v.formData", formData);
                helper.validateStep2(component, event, helper);
                break;
            case 'password':
                // only allow select characters
                var newPassword = value.replace(/[^a-zA-Z0-9_@.-]/g, '');
                formData[field] = newPassword;
                component.set("v.password", newPassword);
                component.set("v.formData", formData);
                helper.validatePassword(component, event, helper);
                break;
            default:
                formData[field] = value;
                component.set("v.formData", formData);
                helper.validateStep1(component, event, helper);
                break;
        }
    },
    validateEmail: function(component, event, helper)
    {
        var formData = component.get("v.formData");
        var regExpEmailFormat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        formData.validEmail = regExpEmailFormat.test(formData.email);
        component.set("v.formData", formData);
        helper.validateStep1(component, event, helper);
    },
    validateUsername: function(component, event, helper)
    {
        var that = this;
        /* Reset username available and username checked */
        component.set("v.usernameValid", false);
        component.set("v.usernameAvailable", false);
        component.set("v.usernameChecked", false);
        /* Check username validity */
        var formData = component.get("v.formData");
        /* Valid usernames should be 3-50 characters long with no spaces or special characters */
        formData.validUsername = /(?=.{3,50})^[A-Za-z0-9]+(?:[ _-][A-Za-z0-9]+)*$/.test(formData.uName);
        component.set("v.usernameValid", formData.validUsername);
        console.log('validateUsername>>>',component.get("v.usernameValid"));
        component.set("v.formData", formData);
        that.validateStep2(component, event, helper);
    },
    validatePassword: function(component, event, helper)
    {
        var formData = component.get("v.formData");
        var password = component.get("v.password");

        formData.passwordValidation = {
            'hasLowercase': /[a-z]+/.test(password),
            'hasUppercase': /[A-Z]+/.test(password),
            'hasNumber': /[0-9]+/.test(password),
            'hasSpecialChar': /[_@.\-]+/.test(password)
        };
        formData.passwordUniqueness = {
            'hasEight': /.{8,}/.test(password),
            'hasUsername': !password.toLowerCase().includes(formData.uName.toLowerCase()),
            'hasFirstName': !password.toLowerCase().includes(formData.fName.toLowerCase()),
            'hasLastName': !password.toLowerCase().includes(formData.lName.toLowerCase())
        }; // to lower case to make the check case insensitive

        var validTallies = 0;
        Object.values(formData.passwordValidation).forEach(tally => {
            if(tally)
            {
                validTallies++;
            }
        });

        if(Object.values(formData.passwordUniqueness).includes(false)){
            formData.validPassword = false;
        } else {
            formData.validPassword = (validTallies >= 3);
        }

        component.set("v.formData", formData);
        helper.validateStep2(component, event, helper);
    },
    validateStep1: function(component, event, helper)
    {
        var formData = component.get("v.formData");
        if(formData.hasOwnProperty('fName')
            && formData.hasOwnProperty('lName')
            && formData.hasOwnProperty('email')
            && formData.validEmail === true)
        {
            component.set("v.step1Complete", true);
        } else
        {
            component.set("v.step1Complete", false);
        }
    },
    validateStep2: function(component, event, helper)
    {
        var formData = component.get("v.formData");
        var uname = component.get('v.uName');
        var isValiduName =/(?=.{3,50})^[A-Za-z0-9]+(?:[ _-][A-Za-z0-9]+)*$/.test(uname);
        if(!isValiduName){
            component.set("v.usernameValid", false);
        }else{
            component.set("v.usernameValid", true);
        }
        if(formData.validPassword === true && isValiduName)
        {
            component.set("v.step2Complete", true);
        } else
        {
            component.set("v.step2Complete", false);
        }
    },
    // Added by ajith for demo purpose
    checkUserNameAndProceed: function(component, event, helper)
    {
        console.log('In checkUserNameAndProceed');
        component.set("v.loading", true);
        var username = component.get("v.uName");
        var action = component.get('c.checkUserNameAvailability');
        action.setParams({
            'userInput' : username
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            var _error = component.find("userError");
            if(state === "SUCCESS"){
                console.log('response'+response.getReturnValue());
                if(response.getReturnValue()){
                   console.log('In Success');
                   $A.util.removeClass(_error, "slds-show");
                   $A.util.addClass(_error, "slds-hide");
                   helper.createRecord(component, event, helper);
                }else{
                   console.log('In Error');
                   $A.util.removeClass(_error, "slds-hide");
                   $A.util.addClass(_error, "slds-show");
                   component.set("v.loading", false);
                }
            }
        });
        $A.enqueueAction(action);
    },
    createRecord: function(component, event, helper)
    {
        var user = component.get("v.formData");
        var errors = false;
        //
        // if(typeof user.uName === 'undefined' || !component.get("v.usernameAvailable")) {
        //     errors = true;
        // }
        if(typeof user.password === 'undefined') {
            errors = true;
        }
        if(!errors)
        {
            component.set("v.formData", user);

            var action = component.get('c.validateAndCreateRecords');
            action.setParams({
                'fName' : user.fName,
                'lName' : user.lName,
                'email' : user.email,
                'uName' : user.uName,
                'password' : user.password,
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if(state === "SUCCESS"){
                    component.set("v.step2Complete", true);
                    helper.goToNextStep(component, event, helper);
                } else {
                    console.log(state.getAuraErrorMessage());
                }
            });
            $A.enqueueAction(action);
        }
    },
    goToURL : function (component, url) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": url
        });
        urlEvent.fire();
    }
})