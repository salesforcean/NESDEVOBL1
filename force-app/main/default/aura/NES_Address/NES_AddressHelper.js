/**
 * Created by Ashish Pandey on 19-12-2018.
 * Change Log: 
 * 2019-04-10 #109932 User Story Bug # 113012(Anitha P)
 */
({
    handleInit : function(component, event, helper) {
       
        var action = component.get("c.getSearchSettings");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.hierarchySettings", result);
                console.log(result);
            } else {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error on: " +errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);

    },
    grabQuestionsList: function(component, event, helper) {
        var groupId = component.get("v.questionGroupId");
        var enrollmentId = component.get("v.programEnrollmentId");
        var action = component.get("c.getQuestions");
        action.setParams({
            'groupId': groupId,
            'enrollmentId': enrollmentId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.questions", result);
                console.log(result);
            } else {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error on: " +errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    /** method is for the "0 results" bug after AJAX returns successful with records/results **/
    getDataForAutocomplete:function(component, event, helper){
        
        var userInput = component.get("v.searchKeyword").toLowerCase();
        console.log('mailing>>'+userInput);
        if(!userInput) {
            component.set("v.timerStarted", false);
            return;
        }
        component.set("v.timerStarted", false);
        var action = component.get("c.searchAddress");
        action.setParams({'address': userInput});
        action.setCallback(this, function(response){
            var state = response.getState();
            var searchResult = [];
            if (state === "SUCCESS") {
                var parsed = JSON.parse(response.getReturnValue());
                for (var i in parsed.results) {
                  searchResult.push(parsed.results[i]);
                }
                component.set("v.suggestionsModal", searchResult);
                component.set("v.isAddressLoaded",true);
            } else {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error on: " +errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    showSpinner: function (component) {
        component.set("v.isLoading",true); 
    },
    hideSpinner: function (component) {
        component.set("v.isLoading",false);
    },
    checkValidity: function(component,event){
        var minimumCharacters = component.get("v.hierarchySettings.Minimum_Characters__c");
        var userInput = component.get("v.searchKeyword").toLowerCase();
        var self = this;
        if(component.find("searchField"))
        {
            if(component.get("v.searchKeyword") && component.get("v.searchKeyword").trim().length > 1){

                console.log('is valid');
                component.set("v.isValid",true);
                self.getDataForAutocomplete(component, event,userInput);
            }
            else if(!component.get("v.searchKeyword") || component.get("v.searchKeyword").trim().length < minimumCharacters)
            {
                console.log('is not valid');
                component.set("v.isValid",false);
                component.set("v.searchResults", null);
            }
            else
            {
                component.set("v.searchResults", null);
            }
        }
    },
    fetchFormattedAddress:function(component,event, helper){
        var selectedAddressFormatURL = component.get("v.selectedAddressFormatURL");
        var val = selectedAddressFormatURL;
        var url = val.substr(val.indexOf('id'));
        var selectedAddressId=url.replace('id'+"=","");
        //selectedAddressId =selectedAddressId.split('%')[0];
        var action = component.get("c.getFormattedAddress");
        action.setParams({'addressId': selectedAddressId});
        action.setCallback(this, function(response){
            var state = response.getState();
            var searchResult = [];
            console.log('state', state);
            if (state === "SUCCESS") {
                var parsed = JSON.parse(response.getReturnValue());
                console.log(parsed.address);
                component.set("v.formattedAddress",parsed.address);
                helper.setQuestionFields(component, event, helper);
            } else {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error on: " +errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    setQuestionFields: function(component, event, helper) {
        var questions = component.get("v.questions");
        var address = component.get("v.formattedAddress");
        for(var i=0;i<questions.length;i++) {

            if(address != null) {
                if(questions[i].apiMapping === 'addressLine1') {
                    questions[i].targetField = address[0].addressLine1;
                    if(address[1].addressLine2) {
                        console.log("\n" + address[1].addressLine2);
                        questions[i].targetField += "\n" + address[1].addressLine2;
                        console.log(questions[i].targetField);
                        if(address[2].addressLine3) {
                            questions[i].targetField += "\n" + address[2].addressLine3;
                        }
                    }
                } else if(questions[i].apiMapping === 'locality') {
                    questions[i].targetField = address[3].locality;
                } else if(questions[i].apiMapping === 'province') {
                    questions[i].targetField = address[4].province;
                } else if(questions[i].apiMapping === 'postalCode') {
                    questions[i].targetField = address[5].postalCode;
                } else if(questions[i].apiMapping === 'country') {
                    questions[i].targetField = address[6].country;
                }
            } else {
                questions[i].targetField = null;
            }

        }
        component.set("v.isManualAddress",true);
        component.set("v.questions", questions);
        
    },

    isOriginalAPIAddress : function(component, event, helper) {
        var questions = component.get("v.questions");
        var address = component.get("v.formattedAddress");

        var falseValues = 0;

        if(address) {
            for(var i=0;i<questions.length;i++) {

                if(questions[i].apiMapping === 'addressLine1') {
                    falseValues = questions[i].targetField != address[0].addressLine1 ? falseValues+1 : falseValues;
                } else if(questions[i].apiMapping === 'addressLine2') {
                    falseValues = questions[i].targetField != address[1].addressLine2 ? falseValues+1 : falseValues;
                } else if(questions[i].apiMapping === 'addressLine3') {
                    falseValues = questions[i].targetField != address[2].addressLine3 ? falseValues+1 : falseValues;
                } else if(questions[i].apiMapping === 'locality') {
                    falseValues = questions[i].targetField != address[3].locality ? falseValues+1 : falseValues;
                } else if(questions[i].apiMapping === 'province') {
                    falseValues = questions[i].targetField != address[4].province ? falseValues+1 : falseValues;
                } else if(questions[i].apiMapping === 'postalCode') {
                    falseValues = questions[i].targetField != address[5].postalCode ? falseValues+1 : falseValues;
                } else if(questions[i].apiMapping === 'country') {
                    falseValues = questions[i].targetField != address[6].country ? falseValues+1 : falseValues;
                }
            }
        }

        if(falseValues === 0) {
            return true;
        } else {
            return false;
        }
    },

    saveAddress : function(component, event, helper) {
        var groupId = component.get("v.questionGroupId");
        var enrollmentId = component.get("v.programEnrollmentId");
        var questions = component.get("v.questions");
        var apiAddress = helper.isOriginalAPIAddress(component, event, helper);
        var action = component.get("c.saveAddressFields");
        action.setParams({
            groupId: groupId,
            programEnrollmentId : enrollmentId,
            questionJSON : JSON.stringify(questions),
            apiValidated: apiAddress
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("Successful save");
            } else {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error on: " +errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    validateForm: function (component, event, helper) {
        var formItems = component.find('addressFieldId');

        var allValid = false;
        var errorfocused = false;
        if(Array.isArray(formItems)) {
            allValid = component.find('addressFieldId').reduce(
                function (validSoFar, inputCmp) {
                    if(typeof inputCmp.showHelpMessageIfInvalid === "function") {
                        inputCmp.showHelpMessageIfInvalid();
                    //Start-User Story Bug # 113012(Anitha P)
                    //Checking each filed valid or missing and then focus 
                    if ( !errorfocused && (!inputCmp.get('v.validity').valid || inputCmp.get('v.validity').valueMissing)){
                        inputCmp.focus();		
                        errorfocused = true;
                    }
                   //End-User Story Bug # 113012(Anitha P)   
                        return validSoFar && inputCmp.get('v.validity').valid && !inputCmp.get('v.validity').valueMissing;
                    } else {
                        var dateValue = inputCmp.get("v.value");
                        //Have to set Regex for yyyy-mm-dd because when retrieving the value it auto changes mm/dd/yyyy to that
                        var dateFormatRegex = /^\d{4}\-(0?[1-9]|1[012])\-(0?[1-9]|[12][0-9]|3[01])$/;
                        if (dateValue.match(dateFormatRegex)) {
                            return validSoFar && true;
                        } else {
                            inputCmp.set("v.errors", [{message:"Incorrect format. Please use the format MM/DD/YYYY"}]);
                            return validSoFar && false;
                        }  
                    }
                }, true);

        } else if(formItems) {
            return !formItems.get('v.validity').valueMissing
        } else if(formItems === undefined){
            if(allValid === false){
                console.log('Unable to Submit Form. Please enter an Address'); 
                //START -- Added by Shravani for #135333
                var searchCmp = component.find('searchField');
                searchCmp.showHelpMessageIfInvalid();
                //END -- Added by Shravani for #135333
                //inputCmp.set("v.errors", [{message:"Unable to Submit Form. Please enter an Address"}]);         
            }            
        }      
          return allValid;
    }
})