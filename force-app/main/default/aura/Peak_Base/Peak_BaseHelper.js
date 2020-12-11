/**
 * Created by Ritvik on 28-09-2018.
 */
({
    getSitePrefix: function(component) {
        var action = component.get("c.getSitePrefix");
        action.setCallback(this, function(actionResult) {
            var sitePrefix = actionResult.getReturnValue();
            component.set("v.sitePrefix", sitePrefix);
        });
        $A.enqueueAction(action);
    },
    getIsGuest: function(component) {
        // Create the action
        var action = component.get("c.isGuestUser");

        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.isGuest", response.getReturnValue());
            }
            else {
                console.log("Failed with state: " + state);
            }
            // component.set("v.isInit", true);
        });
        component.set("v.isGuestInit", true);

        // Send action off to be executed
        $A.enqueueAction(action);
    },
    setLabel: function(component, extendedText, attribute) {
        var labelRegex = /^\$Label\.([a-zA-Z0-9_]*\.){1}([a-zA-Z0-9_]+)$/;
        var text = component.get('v.labelText');
        if(extendedText != undefined){
            text = extendedText;
        }
        if (text !== undefined && text !== '') {
            if (text.indexOf('$Label') !== -1) {
                var label = '';
                if (labelRegex.test(text)) {
                    label = $A.getReference(text);
                } else {
                    label = 'This is an invalid label. Please check it.'
                }
                if(extendedText != undefined){
                    component.set('v.' + attribute, label);
                }else{
                    component.set('v.label', label);
                }
            } else {
                component.set('v.label', text);
            }
        } else {
            component.set('v.label', text);
        }
    },
    /*
        Usage:
        helper.doCallout(component,"c.yourApexMethod",({"paramName" : component.get("v.propertyName")})).then(function(response){
                component.set("v.yourSaveProperty",response);

                if (!response.success){
                    helper.showMessage('Error',response.messages[0]);
                } else {
                    // Your success route
                }

            });

            // Why not showToast property like in some other uses... so that we can show either success OR error messages and put more control extending component, not base component
     */
    doCallout: function (component, method, params) {
        return new Promise($A.getCallback(function (resolve, reject) {
            // Set action and param
            // console.log(params);
            var action = component.get(method);
            if (params != null) {
                action.setParams(params);
            }
            // Callback
            action.setCallback(component, function (response) {
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
                    resolve(response.getReturnValue());
                } else {
                    var errors = response.getError();
                    reject(errors);
                }
            });
            $A.enqueueAction(action);
        }));
    },
    /*
        Great way to check for IE
     */
    checkForIE: function(){
        var ua = window.navigator.userAgent;
        var msie = ua.indexOf('MSIE ');
        if (msie > 0) {
            // IE 10 or older => return version number
            return parseInt(ua.substring(msie + 5, ua.indexOf('.', msie)), 10);
        }
        var trident = ua.indexOf('Trident/');
        if (trident > 0) {
            // IE 11 => return version number
            var rv = ua.indexOf('rv:');
            return parseInt(ua.substring(rv + 3, ua.indexOf('.', rv)), 10);
        }
        var edge = ua.indexOf('Edge/');
        if (edge > 0) {
            // Edge (IE 12+) => return version number
            return parseInt(ua.substring(edge + 5, ua.indexOf('.', edge)), 10);
        }
        // other browser
        return false;
    },
    showMessage: function(level, message) {
        // console.log("Message (" + level + "): " + message);
        level = level.toLowerCase();
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title" : level === "error" ? "Error" : "Message",
            "message" : message,
            "type" : level
        });
        toastEvent.fire();
    },
    validateField: function validateField(component, parentComponent, fieldName) {
        var findIn = null;
        if (parentComponent != null) {
            // Get the element's actual parent component (for example, something in <c:NestedComponent aura:id="NestedThang" />
            findIn = component.find(parentComponent);
        } else {
            findIn = component;
        }

        // Get the field itself
        var inputField = findIn.find(fieldName);

        // Get aura validity
        var validity = inputField.get("v.validity");

        if (!validity.valid) {
            inputField.showHelpMessageIfInvalid();
            return false;
        } else {
            return true;
        }
    },
    // Validate a field without aura
    rawValidateField: function rawValidateField(fieldName) {
        // Because some dynamically created components aren't found by aura :/
        // Why name and not ID? Because aura doesn't let you put an id on lightning:input or lightning:select!
        var fields = document.getElementsByName(fieldName);
        if (fields.length > 0) {
            if (fields[0].value != null && fields[0].value != '') {
                return true;
            } else {
                // Hm, trying to trigger the native aura blur effect for form validation fields[0].blur();
                return false;
            }
        }
    },
    // Validate a field against a certain value
    rawValidateFieldAgainst: function rawValidateFieldAgainst(fieldName, expectedValue, equals) {
        // Because some dynamically created components aren't found by aura :/
        var fields = document.getElementsByName(fieldName);
        if (fields.length > 0) {
            if (fields[0].value != null && fields[0].value != '') {
                // Check for equals
                if (equals) {
                    if (fields[0].value == expectedValue) {
                        return true;
                    }
                } else {
                    // Check not equals
                    if (fields[0].value != expectedValue) {
                        return true;
                    }
                }
            }
        }
        return false;
    },
    /*
     Validate an entire form.
     Pass in the component by reference
     parent component (if you are validating a nested component... so if you have Peak_Form which includes <c:Peak_FormPart>, you would call validateForm(component,Peak_FormPart...
     Array of fields - these will find inputs by their aura:id

     Usage: in your extending component's helper
     requiredFields: ['Name','Address','City','Country','State','Zip','Phone','Email'],
     validateFormAddressForm: function (component,event,helper) {
        var isValid = helper.validateForm(component,null,this.requiredFields);
     }
     */
    validateForm: function validateForm(component, parentComponent, requiredFields) {
        var valid = true;
        for (var x = 0; x < requiredFields.length; x++) {
            if (!this.validateField(component, parentComponent, requiredFields[x])) {
                valid = false;
            }
        }

        return valid;
    },
    /*
        Get a URL paramter by name, Locker Service safe!
        helper.getUrlParameter('YOURPARAMETER')
        Courtesy of https://developer.salesforce.com/forums?id=906F0000000g1blIAA
     */
    getUrlParameter: function getUrlParameter(sParam) {
        var sPageURL = decodeURIComponent(window.location.search.substring(1)),
            sURLVariables = sPageURL.split('&'),
            sParameterName,
            i;

        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('=');

            if (sParameterName[0] === sParam) {
                return sParameterName[1] === undefined ? true : sParameterName[1];
            }
        }

        return null;
    },
    /*
        Return true or false to indicate if in builder or preview mode
     */
    isInBuilder :function(){
        var urlToCheck = window.location.hostname;
        urlToCheck = urlToCheck.toLowerCase();
        return (urlToCheck.indexOf('sitepreview') >= 0 || urlToCheck.indexOf('livepreview') >= 0 || urlToCheck.indexOf('--live') >= 0);
    },
    /*
     If extending Peak_Base you can pass in a list of attributes you would like to convert into custom labels
     You can find an example in the Peak_FileUploader component.
     */
    setLabels: function(component, attributesToConvert) {
        for(var i = 0; i < attributesToConvert.length; i++){
            var value = component.get('v.' + attributesToConvert[i]);
            this.setLabel(component, value, attributesToConvert[i]);
        }
    },
    goToUrl: function(url) {
        var action = $A.get('e.force:navigateToURL');
        action.setParams({
            url: url
        });
        action.fire();
    }
})