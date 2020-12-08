/**
 * Created by karolbrennan on 12/11/18.
 */
({
    initFormData : function(component)
    {
        var formData = {
            fName: '',
            mName: '',
            lName: '',
            suffix: '',
            email: '',
			postalCode: '',
			postalCodeIsValid: true,
			stateCode: '',
			phoneNumber: '',
			phoneNumberIsValid: true,
			phoneType:'',
			SMSOptIn:false,
            emailIsValid: false,
            emailExists: false,
            uName: '',
            usernameIsValid: true,
            password: '',
            passwordIsValid: false,
            // This is used to test the uniqueness of the password
            passwordUniqueness: {
                hasLowercase: false,
                hasUppercase: false,
                hasNumber: false
                //hasSpecialCharacter: false
            },
            // This is used to test the security of the password
            passwordValidation: {
                hasEightCharacters: false,
                hasUsername: false,
                hasFirstName: false,
                hasLastName: false,
                hasSpecialCharacter: false
            },
            showPassword: true,
            schoolId: ''
        };

        // Set formData on the component
        component.set("v.formData", formData);

		var pickvar = component.get("c.getStateValuesIntoList");
        pickvar.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var list = response.getReturnValue();
                component.set("v.stateOptions", list);
            }
            else if(state === 'ERROR'){
                alert('ERROR OCCURED Getting States.');
            }
        })
        $A.enqueueAction(pickvar);
		
		var pickvarPT = component.get("c.getPhoneTypeValuesIntoList");
        pickvarPT.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var list = response.getReturnValue();
                component.set("v.phoneTypeOptions", list);
            }
            else if(state === 'ERROR'){
                alert('ERROR OCCURED Getting Phone Types.');
            }
        })
        $A.enqueueAction(pickvarPT);

		var pickvarSuf = component.get("c.getSuffixValuesIntoList");
        pickvarSuf.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var listSuf = response.getReturnValue();
                component.set("v.suffixOptions", listSuf);
            }
            else if(state === 'ERROR'){
                alert('ERROR OCCURED Getting Suffixes.');
            }
        })
        $A.enqueueAction(pickvarSuf);

    },   
    goToNextStep: function(component, event, helper)
    {
        window.scrollTo(0, 0);
        component.set("v.loading", true);
        var currentStep = parseInt(component.get("v.currentStep")) + 1;
        var newStep = currentStep.toString();
        var changeStep = $A.get("e.c:NES_RegistrationStepEvent");
        
        changeStep.setParams({
            "currentStep" : newStep
        });
        changeStep.fire();
        component.set("v.currentStep", newStep);
        
        component.set("v.loading", false);
        //added by jagadeesh
        component.set("v.step2UsernameCheck", true);
        

        if(newStep === '3'){
            window.setTimeout(
                $A.getCallback(function(){
                    component.goToURL(component, event, helper);
                }), 2000
            );
        }
    },   
    validateEmailAddress: function(component, event, helper, email)
    {
        var formData = component.get("v.formData");
        var regExpEmailFormat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        formData.emailIsValid = regExpEmailFormat.test(formData.email);

        // if the email address is a valid one, check to see if it already exists
        if(formData.emailIsValid){
            helper.checkIfEmailExists(component, email);
        } else {
            // reset email exists message so we don't leave the message open
            formData.emailExists = false;
        } 
		//component.set("v.formData", formData);
    }, 
	
	validatePostalCode: function(component, event, helper, postalCode)
    {
        var formData = component.get("v.formData");
		var regexp = /^[0-9]{5}(?:-[0-9]{4})?$/;
		formData.postalCodeIsValid = regexp.test(postalCode);
    },

	validatePhoneNumber: function(component, event, helper, phoneNumber)
    {
        var formData = component.get("v.formData");
		var regexp1 = /^[0-9]{3}[\-][\0-9]{3}[\-][0-9]{4}$/;
		var regexp2 = /^[0-9]{10}$/;
		formData.phoneNumberIsValid = (regexp1.test(phoneNumber) || regexp2.test(phoneNumber));
    },

    checkIfEmailExists: function(component, email)
    {
        var action = component.get("c.emailExists");
        action.setParams({
            'email': email
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                var formData = component.get("v.formData");
                formData.emailExists = response.getReturnValue();
                component.set("v.formData", formData);
            } else {
                console.log("Error in checking for existing email.");
            }
        });
        $A.enqueueAction(action);
    },

    validatePassword: function(component, event, helper)
    {
        component.set("v.showPasswordPopup", true);
        var formData = component.get("v.formData");
        var password = formData.password;

        //We are preventing non-accepted characters from entry, so makes
        //more sense from a user standpoint to always return true here
		//commented : Begin - for Bug#159983
        //formData.hasSpecialCharacter = true
        ////commented : End - for Bug#159983

        formData.passwordValidation = {
            hasEightCharacters: /.{8,}/.test(password),
            hasUsername: !password.toLowerCase().includes(formData.uName.toLowerCase()),
            hasFirstName: !password.toLowerCase().includes(formData.fName.toLowerCase()),
            hasLastName: !password.toLowerCase().includes(formData.lName.toLowerCase()),
            //added : Begin - for Bug#159983
            hasSpecialCharacter: !/[^a-zA-Z0-9_@.-]/g.test(password)
            //added : End - for Bug#159983
        };
        formData.passwordUniqueness = {
            hasUppercase: /[A-Z]+/.test(password),
            hasNumber: /[0-9]+/.test(password)
        };

        var validTallies = 0;
        Object.values(formData.passwordUniqueness).forEach(tally => {
            if(tally){validTallies++}
        });

        formData.passwordIsValid = (!Object.values(formData.passwordValidation).includes(false) && validTallies == 2);

        component.set("v.formData", formData);

        if(formData.passwordIsValid){
            window.setTimeout(
                $A.getCallback(function(){
                    component.set("v.showPasswordPopup", false);
                }), 1500
            );
        } 
   },
    validateSteps: function(component, event, helper)
    {
        var formData = component.get("v.formData");
        // if there is a first name, last name, email address and a valid email, step 1 is complete
        component.set("v.step1Complete", (formData.fName != null && formData.fName.replace(/\s/g, '').length > 0 && formData.lName != null && formData.lName.replace(/\s/g, '').length > 0 && formData.email != null && formData.emailIsValid && formData.postalCode != null && formData.postalCode.replace(/\s/g, '').length > 0 && formData.stateCode.length > 0  && formData.phoneType.length > 0 && formData.phoneNumber != null && formData.phoneNumber.replace(/\s/g, '').length > 0 && formData.postalCodeIsValid && formData.phoneNumberIsValid) );
        // if there is a valid username and a valid password, step 2 is complete
        component.set("v.step2Complete", (formData.uName != null && formData.password != null && formData.usernameIsValid && formData.passwordIsValid));
        //added by jagadeesh
        component.set("v.step2UsernameCheck", (formData.uName != null && formData.usernameIsValid ));
    },
    //Added as part of US 200242 to take the hidden fields populated by GTM
    gtmHiddenFieldsData : function(){
        var gtmhiddenclientID = document.getElementById("clientID").value;
        var gtmhiddendevice_type = document.getElementById("device_type").value;
        var gtmhiddenkeyword = document.getElementById("keyword").value;
        var gtmhiddencampaignName = document.getElementById("campaignName").value;
        var gtmhiddenutm_source = document.getElementById("utm_source").value;
        var gtmhiddenutm_medium = document.getElementById("utm_medium").value;
        var gtmhiddenexperimentID = document.getElementById("experimentID").value;
        var gtmhiddentimestamp = document.getElementById("timestamp").value;
        var gtmhiddengclickid = document.getElementById("gclickid").value;
        var gtmhiddenObject = {
            'clientID':gtmhiddenclientID,
            'device_type':gtmhiddendevice_type,
            'keyword':gtmhiddenkeyword,
            'campaignName':gtmhiddencampaignName,
            'utm_source':gtmhiddenutm_source,
            'utm_medium':gtmhiddenutm_medium,
            'experimentID':gtmhiddenexperimentID,
            'timestamp':gtmhiddentimestamp,
            'gclickid':gtmhiddengclickid,
        };
        return JSON.stringify(gtmhiddenObject);
    },

    
    //Added for the US166467 : Jagadeesh
    checkUserNameAvailability: function(component, event, helper)
    {    
        console.log('In checkUserNameAvailability');
        var username = component.get("v.formData.uName");
        var respStatus = false;
        var action = component.get('c.VeriftyUserNameAvailability');
        action.setParams({
            'userInput' : username
        });
        action.setCallback(this, function(response){
           var str = response.toString();
            var state = response.getState();
            if(state === "SUCCESS"){
                respStatus = response.getReturnValue().success;
                console.log(respStatus);
                if(respStatus == true){
                    console.log('In Success');
                    component.set("v.checkingFlag", false);
                    component.set("v.disableFlag", true);
                    component.set("v.UserAvailFlag", true);
                    component.set("v.passwordDisableFlag", false);
                }else{
                    component.set("v.checkingFlag", false);
                    component.set("v.checkUserFlag", true);
                    component.set("v.UserNotAvailFlag", true);
                    component.set("v.passwordDisableFlag", true);
                }
            }
            else{
                component.set("v.checkingFlag", false);
                component.set("v.checkUserFlag", true);
            }
            
        });
        $A.enqueueAction(action);
    }
   
})