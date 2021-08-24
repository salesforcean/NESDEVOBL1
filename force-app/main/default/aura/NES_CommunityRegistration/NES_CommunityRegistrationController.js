/**
 * Created by karolbrennan on 12/11/18.
 * Change Log:
 *         2019-10-03 #US102165 Additional fields for the Registration process (Mark Membrino) 
 */
({
    /*  doInit
     *  Initialize component
     */
    doInit: function(component, event, helper)
    {
        // Detect if the user is on the registration page
        // This will relay back to the community theme
        // and display the sign in button if the user
        // is on the first step / hasn't begun registration yet.
        var detectRegistrationPage = $A.get("e.c:NES_DetectRegistrationPage");
        detectRegistrationPage.setParams({
            "onRegistrationPage" : true
        });
        detectRegistrationPage.fire();
        
        // Initialize formData for storing user inputs
        // and controlling UI elements related to inputs
        helper.initFormData(component);
        
        // init component
        component.set("v.isInit", true);
        
    },
    /*  togglePassword
     *  get existing formData, and reverse current showPassword value
     */
    togglePassword: function(component, event, helper)
    {
        var formData = component.get("v.formData");
        formData.showPassword = !formData.showPassword;
        component.set("v.formData", formData);
    },
    goToURL : function (component, event)
    {
        var url = event.target.dataset.link;
        // set default to dashboard if url doesn't exist
        if(!url){
            url = "/dashboard"
        }
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": url
        });
        urlEvent.fire();
    },
    /*  Handle input
     *  Processes user inputs
     */
    handleInput: function(component,event, helper)
    {
        var formData = component.get("v.formData");
        var field = event.getSource().get("v.name");
        
        // Remove spaces from certain inputs
        if(field === 'email' || field === 'uName' || field === 'password')
        {
            formData[field] = formData[field].replace(" ", "");
            if(field === 'password')
            {
                //Commented  Begin for #US 153312
                //formData[field] = formData[field].replace(/[^a-zA-Z0-9_@.-]/g, '');
                //Commented End for #US 153312
            }
            //component.set("v.formData", formData);
            //added by jagdaeesh
            if(field === 'uName'){
                	component.set("v.step2UsernameCheck",false);
                    component.set("v.checkingFlag",false);
                    component.set("v.disableFlag",false);
                    component.set("v.checkUserFlag",true);
                    //Start as part of 166467 by Jagadish Babu
                    component.set("v.UserAvailFlag", false);
					component.set("v.UserNotAvailFlag", false);
                    component.set("v.passwordDisableFlag", true);
					component.set("v.formData.password", "");	
                	//End as part of 166467 by Jagadish Babu
            }
        } 
        
        
        // execute different actions based on which field
        switch(field){
            case 'email':
                helper.validateEmailAddress(component, event, helper, formData[field]);
                break;
            case 'uName':
                formData.usernameIsValid = /^([A-Za-z0-9]{3,50})$/.test(formData[field]);
                break;
            case 'password':
                helper.validatePassword(component, event, helper);
                break;
            case 'postalCode':
                helper.validatePostalCode(component, event, helper, formData[field]);
                break;
            case 'phoneNumber':
                helper.validatePhoneNumber(component, event, helper, formData[field]);
                break;
            default:
                break;
        }
        helper.validateSteps(component, event, helper);
        component.set("v.formData", formData);
    },
    togglePasswordHelper: function(component,event,helper){
        window.setTimeout(
            $A.getCallback(function(){
                var passwordInput = component.find("passwordInput");
                var formData = component.get("v.formData");
                if(!formData.passwordIsValid){
                    $A.util.addClass(passwordInput,'slds-has-error');
                } else {
                    $A.util.removeClass(passwordInput,'slds-has-error');
                }
                component.set("v.showPasswordPopup", false);
            }), 750
        );
    },
    goToStep2: function(component, event, helper)
    {                
        helper.goToNextStep(component, event, helper);
    },
    handleSubmit: function(component, event, helper)
    {
        
        component.set("v.loading", true);
        component.set("v.errorMessage", null);
        component.set("v.creationMessage", null);
        var formData = component.get("v.formData");
        console.log('-=-=-=-=-='+JSON.stringify(formData));
        //Added below line as part of US200242 to get GTM hidden field values
        var gtmHiddenFields = helper.gtmHiddenFieldsData();
        console.log('-=-=-=-=-=gtmHiddenFields=='+JSON.stringify(gtmHiddenFields));
        var action = component.get("c.validateAndCreateRecords");
        var url = decodeURIComponent(window.location.search.substring(1));
        var urlParameters = url.split('&');
        var schoolId = "";
        for (var i = 0; i < urlParameters.length; i++) {
            var parameter = urlParameters[i].split('=');
            if (parameter[0] === 'school_id') {
                schoolId = parameter[1];
            }
        }
        console.log('-=-=-=-=-=schoolId=='+JSON.stringify(schoolId));
        var optOut;
        if (formData.SMSOptIn == true)
            optOut = false;
        else
            optOut = true;
        console.log('optOut--'+optOut);
        action.setParams({
            'fName': formData.fName.trim(), //Added trim() for #BUG 185616 by Jagadeesh Bokam
            'lName': formData.lName.trim(), //Added trim() for #BUG 185616 by Jagadeesh Bokam
            'email': formData.email,
            'uName': formData.uName,
            'password': formData.password,
            'schoolId': schoolId,
            'mName' : formData.mName,
            'suffix' : formData.suffix,
            'zipCode' : formData.postalCode,
            'state' : formData.stateCode,
            'phoneType' : formData.phoneType,
            'phone' : formData.phoneNumber.replace(/-/g, ''),
            'smsOptOut' : optOut,
            'gtmHiddenFields' : gtmHiddenFields
        });
        
        action.setCallback(this, function(response){
            var peakResponse = response.getReturnValue();
            
            if(peakResponse.success) {
                component.set("v.creationMessage", "Account created!");
                helper.goToNextStep(component, event, helper);
            } else {
                component.set("v.loading", false);
                if(peakResponse.messages[2] && peakResponse.messages[2] == "Invalid FirstName.") {
                    component.set("v.errorMessage", "Invalid characters in the First Name field. Characters < > & ? \" are not allowed.");
                }
                else if(peakResponse.messages[2] && peakResponse.messages[2] == "Invalid LastName.") {
                    component.set("v.errorMessage", "Invalid characters in the Last Name field. Characters < > & ? \" are not allowed.");
                }
                    else if(peakResponse.messages[2] && peakResponse.messages[2] == "Invalid Email.") {
                        component.set("v.errorMessage", "Please provide a valid Email Address."); //Fix in the message #US140695 (Krishna Peddanagammol)
                    }
                        else if(peakResponse.messages[2] && peakResponse.messages[2] == "Username already exists.") { 
                            component.set("v.errorMessage", "This Username is not available. Please try another.");
                        }else {
                            component.set("v.errorMessage", "An error has occurred. Please try again. "+peakResponse.messages[2]); //Fix in the error message #US140695 (Krishna Peddanagammol)
                        }
            }
        });
        $A.enqueueAction(action);
    },
    
    //Begin: added for the US166467 : Jagadeesh
    /** purpose : to verify usename availability **/
    checkUsernameAvailability: function(component, event, helper)
    {
        var formData = component.get("v.formData");
        var field = 'uName';
        // Remove spaces from certain inputs	
        formData[field] = formData[field].replace(" ", "");
        // execute different actions based on which field
        formData.usernameIsValid = /^([A-Za-z0-9]{3,50})$/.test(formData[field]);
        helper.validateSteps(component, event, helper);
        component.set("v.formData", formData);
        if(formData[field].length < 3)
            return;
        component.set("v.checkingFlag", true);
        component.set("v.checkUserFlag", false);
        component.set("v.UserAvailFlag", false);
        component.set("v.UserNotAvailFlag", false);
        component.set("v.passwordDisableFlag", false);
        helper.checkUserNameAvailability(component, event, helper);
        
    }
    
});