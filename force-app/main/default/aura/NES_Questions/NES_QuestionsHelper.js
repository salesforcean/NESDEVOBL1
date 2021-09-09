/**
 * Created by triciaigoe on 12/13/18.
 * Change Log: 
 * 2019-04-10 #109932 User Story Task # 111937(Anitha P)
 * 2019-10-07 Added Skip For Now #US108687 (Ali Khan)
 * 2020-02-20 [Prod] Date Regex Validation For Bug #140247 (Krishna Peddanagammol)
 * 2021-01-08:Sumanth: Added 'getAHIIncomeFormSubmitDate' method for US # 334973 & 334974
 */
({
    initiateQuestions: function (component, event, helper) {
        var vars = {};
        var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(m,key,value) {
            var newValue = decodeURIComponent(value);
            vars[key] = newValue.replace('+', ' ');
        });
        component.set("v.studentId", vars['studentId']);
        component.set("v.sectionId", vars['sectionId']);
        component.set("v.caretakerId", vars['caretakerId']);
        component.set("v.processId", vars['processId']);
        component.set("v.programEnrollmentId", vars['programEnrollmentId']);
        component.set("v.formName", vars['formName']);//Swapna:For GTM
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var caretakerId = component.get("v.caretakerId");
        if(caretakerId) {
            if(userId === caretakerId) {
                helper.getNameStudent(component, event, helper);
            } else {
                component.set("v.invalidUser", true);
                component.set("v.spinner", false);
            }
        } else {
            component.set("v.spinner", false); 
        }
    },
    getNameStudent: function(component, event, helper) {
        
        var action = component.get("c.grabNameOfStudent");
        
        action.setParams({
            studentId: component.get('v.studentId'),
            programEnrollmentId: component.get('v.programEnrollmentId')
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS") {
                if(response.getReturnValue() === 'InvalidUser') {
                    component.set("v.invalidUser", true);
                    component.set("v.spinner", false);
                } else {
                    component.set("v.studentName", response.getReturnValue());
                    helper.getQuestions(component, event, helper);
                    helper.getMessages(component, event, helper);
                    helper.grabLogo(component, event, helper);
                    helper.getSectionName(component, event, helper);
                    //Added by Sumanth for US # 334973 & 334974
                    helper.getAHIIncomeFormSubmitDate(component, event, helper);
                    //end by Sumanth 
                }
            } else {
                var error = response.getError();
                console.log("ERROR", error);
            }
            
        });
        
        $A.enqueueAction(action);
    },
    
    getSectionName: function(component, event, helper) {
        var action = component.get("c.getSectionName");
        
        action.setParams({
            sectionId: component.get('v.sectionId')
        });
        
        action.setCallback(this, function(response){
            component.set("v.sectionName", response.getReturnValue());
        });
        
        $A.enqueueAction(action);
        
    },
    
    //Added by Sumanth for US # 334973 & 334974
    getAHIIncomeFormSubmitDate: function(component, event, helper) {
        var action = component.get("c.getAHISubmitInformation");
        action.setParams({
            enrollmentId: component.get('v.programEnrollmentId')
        });
        action.setCallback(this, function(response){
            var stateVal = response.getState();
            if(stateVal === "SUCCESS") {
                var returnedResponse = response.getReturnValue();
                console.log("AHIIncomeSubmitDate", returnedResponse);
                if(returnedResponse) {
                  	component.set("v.AHIIncomeSubmitDate", returnedResponse); 
                }
            } else {
                var error = response.getError();
            }
         });
        $A.enqueueAction(action);
    },
    //end by Sumanth  
    grabLogo: function(component, event, helper) {
        console.log('fire logo');
        var programEnrollmentId = component.get("v.programEnrollmentId");
        var action = component.get("c.getSchoolId");
        action.setParams({
            enrollmentId: programEnrollmentId
            
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var returnedResponse = response.getReturnValue();
                if(returnedResponse) {
                    console.log("schoolId", returnedResponse);
                    var schoolAppEvent = $A.get("e.c:NES_schoolId");
                    schoolAppEvent.setParams({
                        "schoolids" : returnedResponse });
                    
                    schoolAppEvent.fire();
                }
            } else {
                var error = response.getError();
                console.log("ERROR", error);
            }
        });
        
        $A.enqueueAction(action);
    },
    
    assignmentEvaluation: function(component, event, helper) {
        console.log('before reset');
        helper.resetNoRequiredValidationErrorIfNeeded(component, event, helper);
        console.log('after reset');
        var processId = component.get("v.processId");
        var questionData = component.get("v.questions");
        console.log('In assigment eval');
        var questionDataCopy = JSON.parse(JSON.stringify(questionData));
        console.log(questionDataCopy);
        var questions = [];
        if(Array.isArray(questionDataCopy)) {
            for(var i=0;i<questionDataCopy.length;i++) {
                var question = questionDataCopy[i];
                console.log(question);
                
                if(question.hasOwnProperty('picklistValues') && question.questionType === 'Radio') {
                    question.picklistValues.forEach(function(item){
                        if(item.value.toString().toLowerCase() === 'true'){
                            item.value = 'true';
                        } else if(item.value.toString().toLowerCase() === 'false'){
                            item.value = 'false';
                        }
                        
                    })
                } else {
                    if(question.hasOwnProperty('targetField')) {
                        console.log('In if check');
                        if(question.targetField.toString().toLowerCase() === 'true') {
                            console.log('Setting to true');
                            question.targetField = true;
                            console.log('AFter that');
                        } else if(question.targetField.toString().toLowerCase() === 'false' || ($A.util.isEmpty(question.targetField) && question.questionType === 'Boolean')) {
                            question.targetField = false;
                        }
                        console.log('after checking for false');
                    }
                }
                
                if(question.questionType === 'Checkbox Group') {
                    if(question.targetField.length === 0) {
                        question.targetField = '';
                    } else if (Array.isArray(question.targetField)) {
                        var newTargetField = question.targetField[0];
                        for(var k=1; k < question.targetField.length; k++) {
                            console.log(question.targetField);
                            newTargetField = newTargetField + ';' + question.targetField[k];
                        }
                        question.targetField = newTargetField;
                    }
                }
                
                console.log(question);
                
                
                if(!question.groupId) {
                    questions.push(question);
                    console.log(questions);
                }
                
            }
        }
        
        console.warn('Below are the questions we are popping over');
        console.log(questions);
        
        if(questions) {
            var programEnrollmentId = component.get("v.programEnrollmentId");
            var sectionId = component.get("v.sectionId");
            var action = component.get("c.evaluateQuestion");
            action.setParams({
                enrollmentId: programEnrollmentId,
                questions: JSON.stringify(questions),
                sectionComponentId : sectionId,
                processId: processId
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if(state === "SUCCESS") {
                    var returnedResponse = response.getReturnValue();
                    console.warn('The new questions receiving in QuestionsHelper assignmentEval');
                    console.log('evaluateQuestion--responseState-->');// #384276
                    console.log(response.getReturnValue());
                    var newQuestions = [];
                    if(returnedResponse) {
                        for(var i=0;i<returnedResponse.length;i++) {
                            var question = returnedResponse[i];
                            if(question.hasOwnProperty('picklistValues') && question.picklistValues.length > 1){
                                question.picklistValues.sort(function(a, b){
                                    return a.order - b.order
                                });
                            }
                            
                            if(question.hasOwnProperty('picklistValues') && question.questionType === 'Radio') {
                                question.picklistValues.forEach(function(item){
                                    if(item.value.toString().toLowerCase() === 'true'){
                                        item.value = 'true';
                                    } else if(item.value.toString().toLowerCase() === 'false'){
                                        item.value = 'false';
                                    }
                                })
                            } else {
                                if(question.hasOwnProperty('targetField')) {
                                    console.log('In if check');
                                    if(question.targetField.toString().toLowerCase() === 'true') {
                                        console.log('Setting to true');
                                        question.targetField = true;
                                        console.log('AFter that');
                                    } else if(question.targetField.toString().toLowerCase() === 'false') {
                                        question.targetField = false;
                                    }
                                     // Added by Chinna for bug 141450
                                    if(question.questionTarget == "Acknowledgement__c.Agreement__c"){
                                        question.targetField = false;
                                    }
                                    console.log('after checking for false');
                                }
                            }
                            
                            if(question.questionType === 'Checkbox Group') {
                                if(question.hasOwnProperty('targetField')) {
                                    question.targetField = question.targetField.split(';');
                                } else {
                                    question.targetField = [];
                                }
                            }
                            newQuestions.push(question);
                            
                        }
                        newQuestions.sort(function(a, b){return a.order - b.order});
                        console.warn('The two arrays');
                        console.log(newQuestions);
                        console.log(questions);
                        var arrayEqual = helper.checkArrayForEquality(newQuestions,questions);
                        var runComplete = component.get("v.runCompletion");
                        console.log(questions);
                        console.log(newQuestions);
                        console.log(runComplete);
                        if(runComplete && arrayEqual) {
                            helper.submitAnswers(component,event,helper);
                        } else {
                            component.set("v.spinner", false);
                        }
                    }
                    if(arrayEqual) {
                        console.log('Returned questions are the same as current questions');
                    } else {
                        console.log('Not the same');
                        console.log(newQuestions);
                        component.set("v.questions", newQuestions);
                        component.set("v.spinner", false);
                        
                        //Now that new questions are set, let's focus the first unfilled in item,
                        //and give time for the aura:iteration to complete adding them
                        /*window.setTimeout($A.getCallback(function() {
                            var formElements = component.find("fieldId");
                             for(var i = 0; i < newQuestions.length; i++){
                                 if($A.util.isEmpty(newQuestions[i].targetField)){
                                     formElements[i].focus();
                                     break;
                                 }
                             }
                        }), 500);*/
                    }
                } else {
                    var error = response.getError();
                    console.log(JSON.parse(JSON.stringify(error)));
                    console.log("ERROR", error);
                    component.set("v.spinner", false);
                }
                
            });
            
            $A.enqueueAction(action);
        }
    },
    resetNoRequiredValidationErrorIfNeeded: function(component, event, helper) {
        var numberRequired = component.get("v.numberRequired");
        var fields = component.find('fieldId');
        console.log('fields===:');
        // Commented by Shravani for #352280 
        /*
       for(var idx = 0; idx < fields.length; idx++){
            console.log(fields[idx]);
            console.log(fields[idx].get("v.value"));
        }
        */
        if(numberRequired > 0 || fields == null){
            return;
        } else {
            if(!Array.isArray(fields)){
                if(fields.get("v.value")){
                    fields.setCustomValidity("");
                    fields.reportValidity;
                }
            } else {
                
                var hasValue = false;
                
                for(var activeIndex = 0; activeIndex < fields.length; activeIndex++){
                    if(fields[activeIndex].get("v.value")){
                        hasValue = true;
                    }
                }
                
                if(hasValue) {
                    for(var activeIndex = 0; activeIndex < fields.length; activeIndex++){
                        fields[activeIndex].setCustomValidity("");
                        fields[activeIndex].reportValidity();
                    }
                }
            }
        }
    },
    checkArrayForEquality: function(array1, array2) {
        var equal = true;
        
        if(array1.length != array2.length){
            return false;
        }
        
        for(var i = 0; i < array1.length; i++){
            for(var key in array1[i]){
                if(key !== 'picklistValues' && key !== 'targetField') {
                    equal = equal && (array1[i][key] === array2[i][key]);
                }
            }
        }
        
        return equal;
        
    },
    getQuestions: function (component, event, helper) {
        var sectionId = component.get("v.sectionId");
        var programEnrollmentId = component.get("v.programEnrollmentId");
        //console.log('Section Id' + sectionId);
        //console.log('PE Id' + programEnrollmentId);
        //alert('I am Here');
        //alert(sectionId);
        //alert(programEnrollmentId);
        var action = component.get("c.getRelatedQuestions2");
        action.setParams({
            sectionComponentId : sectionId,
            enrollmentId: programEnrollmentId
            
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS") {
                var returnedResponse = response.getReturnValue();
                console.warn('The getQuestions call in QuestionsHelper.js');
                console.log('*** returnedResponse ==> '+returnedResponse);
                if(returnedResponse) {
                    if(returnedResponse[0].questionId === 'Complete') {
                        component.set("v.alreadyCompleted", true);
                        component.set("v.spinner", false);
                        return;
                    }
                }
                var questions = [];
                var numberRequired = 0;
                if(returnedResponse) {
                    console.log(returnedResponse);
                    for(var i=0;i<returnedResponse.length;i++) {
                        console.log('Getting next question');
                        var question = returnedResponse[i];
                        console.log('*** question ==> '+question);
                        console.log('That was the question');
                        if(question.hasOwnProperty('required')) {
                            if(question.required) {
                                numberRequired++;
                            }
                        }
                        
                        if(question.hasOwnProperty('picklistValues') && question.picklistValues.length > 1){
                            question.picklistValues.sort(function(a, b){
                                return a.order - b.order
                            });
                        }
                        
                        if(question.hasOwnProperty('questionType')) {
                            if(question.questionType === 'Checkbox Group' && !question.hasOwnProperty('targetField')) {
                                question.targetField = [];
                            }
                        }
                        
                        if(question.hasOwnProperty('picklistValues') && question.questionType === 'Radio') {
                            question.picklistValues.forEach(function(item){
                                if(item.value.toString().toLowerCase() === 'true'){
                                    item.value = 'true';
                                } else if(item.value.toString().toLowerCase() === 'false'){
                                    item.value = 'false';
                                }
                                
                            })
                        } else {
                            if(question.hasOwnProperty('targetField')) {
                                console.log('In if check');
                                if(question.targetField.toString().toLowerCase() === 'true') {
                                    console.log('Setting to true');
                                    question.targetField = true;
                                    console.log('AFter that');
                                } else if(question.targetField.toString().toLowerCase() === 'false' || ($A.util.isEmpty(question.targetField) && question.questionType === 'Boolean')) {
                                    question.targetField = false;
                                }
                                 // Added by Chinna for bug 141450
                                if(question.questionTarget == "Acknowledgement__c.Agreement__c"){
                                    question.targetField = false;
                                }
                                console.log('after checking for false');
                            }
                        }
                        
                        console.log(question);
                        questions.push(question);
                        console.log('Just pushed that question');
                    }
                }
                console.log('*** numberRequired ==> '+numberRequired);
                component.set("v.numberRequired", numberRequired);
                console.log('*** Question *** '+questions);
                questions.sort(function(a, b){
                    return a.order - b.order
                });
                
                var testingDecimal = [3, 41, 42, 41.05, 3.0001, 3.0002];
                console.log(testingDecimal);
                testingDecimal.sort(function(a,b){
                    return a - b;
                });
                console.log(testingDecimal);
                
                console.log(questions.sort(function(a, b){return a.order - b.order}));
                questions.sort();
                var questionsCopy = JSON.parse(JSON.stringify(questions));
                questionsCopy.sort(function(a, b){return a.order - b.order});
                console.warn('Returned questions');
                console.log(questions);
                console.log(questionsCopy);
                component.set("v.questions", questions);
                component.set("v.spinner", false);
            } else {
                var error = response.getError();
                console.log(JSON.parse(JSON.stringify(response)));
                console.log("ERROR", error);
            }
        });
        
        $A.enqueueAction(action);
        
    },
    
    getMessages: function (component, event, helper) {
        var sectionId = component.get("v.sectionId");
        var programEnrollmentId = component.get("v.programEnrollmentId");
        var action = component.get("c.getRelatedMessages");
        action.setParams({
            enrollmentComponentId : sectionId,
            programEnrollmentId : programEnrollmentId
        }); 
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS") {
                var returnedResponse = response.getReturnValue();
                console.log('The messages returned were');
                console.log(returnedResponse);
                console.log(JSON.parse(JSON.stringify(returnedResponse)));
                component.set("v.messages", returnedResponse);
            } else {
                var error = response.getError();
                console.log("ERROR", error);
            }
        });
        
        $A.enqueueAction(action);
        
    },
    
    submitAnswers: function (component, event, helper) {
        component.set("v.spinner", true);
        var questions = component.get("v.questions");
        for(var i=0;i<questions.length;i++) {
            var question = questions[i];
            if(question.questionType === 'Checkbox Group') {
                if (Array.isArray(question.targetField)) {
                    var newTargetField = '';
                    for(var k=0; k < question.targetField.length; k++) {
                        newTargetField = newTargetField + question.targetField[k] + ';';
                    }
                    question.targetField = newTargetField;
                }
            }
            
            if(question.hasOwnProperty('targetField')) {
                if(question.targetField.toString().toLowerCase() === 'true') {
                    question.targetField = 'true';
                } else if(question.targetField.toString().toLowerCase() === 'false') {
                    question.targetField = 'false';
                }
            }
        }
        var enrollmentId = component.get("v.programEnrollmentId");
        var processId = component.get("v.processId");
        var sectionId = component.get("v.sectionId");
        var action = component.get("c.submitQuestions");
        console.log('At submitQuestions action');
        
        
        action.setParams({
            enrollmentId : enrollmentId,
            questions : JSON.stringify(questions),
            processComponentId : processId,
            sectionComponentId : sectionId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS") {
                var peakResponse = response.getReturnValue();
                console.log(peakResponse);
                if(peakResponse.success) {
                    console.log('Success');
                    console.log(peakResponse.messages[0]);
                    var event = $A.get("e.force:navigateToURL");
                    event.setParams({
                        "url": peakResponse.messages[0]
                    });
                    event.fire();
                    
                    /*
                    // Naveen
                    // Added to re-direct the CT back to allow the Auto Placement Process to Run and complete
                    var Sname = component.get('v.sectionName');
                    alert(Sname);
                    if(Sname === "Academic History"){
                        helper.goBack(component, event, helper);
                    }
                    else{
                    	event.fire();
                    }
                    */
                    
                } else {
                    console.log('Fail before go back');
                    component.set("v.spinner", false);
                    helper.goBack(component, event, helper);
                }
            } else {
                var error = response.getError();
                console.log("ERROR", error);
            }
        });
        
        $A.enqueueAction(action);
        
    },
    
    fireAppEvent: function(component, event, helper) {
        console.log('found appevent');
        var appEvent = $A.get("e.c:NES_SubmitQuestionsEvent");
        appEvent.fire();
        var validForm = helper.validateForm(component, event, helper);
        console.log('validForm ==> '+validForm);
        if(!validForm) {
            console.error('This form is not valid');
            component.set("v.spinner", false);
            return;
        }
       component.set("v.runCompletion", true);
       console.log('running on');
       helper.assignmentEvaluation(component, event, helper);
    },
    
    validateForm: function (component, event, helper) {
        console.log('in validate');
        var numberRequired = component.get("v.numberRequired");
       // console.log('*** numberRequired ==> '+numberRequired);
        var formItems = [];
        var fields = component.find('fieldId');
        var errorfocused = false;
        
        //Check to see if there were only group components in this section
        if(!$A.util.isEmpty(fields)){
            if(!Array.isArray(fields)) {
                formItems.push(fields);
            } else {
                formItems = fields;
            }
            // console.log(' formItems ==> '+formItems);
            var allValid = true;
            
            var newValid = formItems.reduce(
                function (validSoFar, inputCmp) {
                    console.log('inputCmp ==> '+inputCmp);
                    console.log('inputCmp Value ==> '+inputCmp.get('v.value'));
                    //This is needed to deal with a Salesforce bug where old iteration elements are being
                    //returned from component.find
                    
                    console.log('inputCmp: '+ inputCmp);
                    console.log(' inputCmp.isRendered() == '+inputCmp.isRendered());
                    if(inputCmp.isRendered()){
                        console.log('Checking if rendered');
                        if(typeof inputCmp.showHelpMessageIfInvalid === "function") {
                            console.log('*** Array.isArray(inputCmp.get("v.value")) ==> '+Array.isArray(inputCmp.get("v.value")));
                            //console.log('*** inputCmp.get("v.value").length ==> '+inputCmp.get("v.value").length);
                            //console.log('*** inputCmp.get("v.value")[0] ==> '+inputCmp.get("v.value")[0]);
                            //console.log('*** inputCmp.get("v.required") ==> '+inputCmp.get("v.required"));
                            if(Array.isArray(inputCmp.get("v.value")) && inputCmp.get("v.value").length == 1 && inputCmp.get("v.value")[0] === "" && inputCmp.get("v.required")){
                                inputCmp.set("v.value", "");                                
                            }
                            inputCmp.showHelpMessageIfInvalid();
                        }
                    } else {
                        return validSoFar;
                    }
                     //Start-User Story Task # 111937(Anitha P)
                    //Checking each filed valid or missing and then focus 
                    if ( !errorfocused && (!inputCmp.get('v.validity').valid || inputCmp.get('v.validity').valueMissing)){
                        inputCmp.focus();		
                        errorfocused = true;
                    }
                   //End-User Story Task # 111937(Anitha P)
                    
                 //  console.log('*** validSoFar ==> '+validSoFar);
                 //  console.log('*** inputCmp.get(\'v.validity\').valid ==> '+inputCmp.get('v.validity').valid);
                 //  console.log('*** !inputCmp.get(\'v.validity\').valueMissing ==> '+!inputCmp.get('v.validity').valueMissing);
                   return validSoFar && inputCmp.get('v.validity').valid && !inputCmp.get('v.validity').valueMissing;
                }, true);
            
            console.log('Before date items');
            var dateItems = [];
            var dateFields = component.find('dateField');
            if(dateFields) {
                if(dateFields.constructor === Array){
                    console.log('2');
                    console.log(dateFields.length);
                    var prunedDateFields = [];
                    dateFields.forEach(function(dateField){
                        if(dateField.isRendered()){
                            prunedDateFields.push(dateField);
                        }
                    });
                    dateItems = prunedDateFields;
                } else {
                    dateItems.push(dateFields);
                }
                console.log('dates',dateItems);
                if(dateItems) {
                    allValid = dateItems.reduce(
                        function (validSoFar, inputCmp) {
                            return validSoFar && helper.validateDate(inputCmp, null, helper);
                        }, true);
                }
            }
            if(numberRequired === 0 && formItems) {
                var unfilledOutQuestions = 0;
                for(var i=0; i<formItems.length; i++) {
                    console.log(formItems[i].get("v.value"));
                    if(formItems[i].get("v.value")) {
                        break;
                    } else {
                        formItems[i].setCustomValidity("Please enter one or the other");
                        unfilledOutQuestions++;
                    }
                }

              //  console.log('*** unfilledOutQuestions ==> '+unfilledOutQuestions);
             //   alert('*** unfilledOutQuestions ==> '+unfilledOutQuestions);
                
                if(unfilledOutQuestions === formItems.length) {
                    allValid = false;
                    for(var i=0; i<formItems.length; i++) {
                        formItems[i].reportValidity();
                        
                    }
                } else {
                    for(var i=0; i<formItems.length; i++) {
                        formItems[i].setCustomValidity("");
                        formItems[i].reportValidity();
                        
                    }
                }
            }
            
            console.log('through fields');
        //    console.log('*** allValid ==> '+allValid);
        //    console.log('*** newValid ==> '+newValid);
            return allValid && newValid;
            
        } else {
            return true;
        }
        
    },
    
    goBack: function (component, event, helper) {
        var caretaker = component.get("v.caretakerId");
        var studentId = component.get("v.studentId");
        var processId = component.get("v.processId");
        var programEnrollmentId = component.get("v.programEnrollmentId");
        var urlMap= $A.get("$Label.c.NES_Community_Stem_Url");
       
        var url = urlMap+'/enrollment?studentId=' + encodeURIComponent(studentId) 
        + '&caretakerId=' + encodeURIComponent(caretaker) 
        + '&processId=' + encodeURIComponent(processId) 
        + '&programEnrollmentId=' + encodeURIComponent(programEnrollmentId);
        var event = $A.get("e.force:navigateToURL");
        event.setParams({
            "url": url
        });
        event.fire();
    },
    
    validateDate: function(component, event, helper){
        debugger;
        var inputCmp = event == null ? component : event.getSource();
        var dateValue = inputCmp.get("v.value");
        //Have to set Regex for yyyy-mm-dd because when retrieving the value it auto changes mm/dd/yyyy to that
       // var dateFormatRegex = /^\d{4}\-(0?[1-9]|1[012])\-(0?[1-9]|[12][0-9]|3[01])$/;
       
        //var additionalFormatRegex = /([1-9]|0[1-9]|1[012])[- \/.]([1-9]|0[1-9]|[12][0-9]|3[01])[- \/.](19|20)\d\d/
        // Fix for Bug #140247
       // var dateFormatRegex = /^(?:(?:(?:0[13578]|1[02])(\/)31)\1|(?:(?:0[1,3-9]|1[0-2])(\/)(?:29|30)\2))(?:(?:19|[2-9]\d)\d{2})$|^(?:02(\/)29\3(?:(?:(?:19|20)(?:[02468][048]|[13579][26]))))$|^(?:(?:0[1-9])|(?:1[0-2]))(\/)(?:0[1-9]|1\d|2[0-8])\4(?:(?:19|20)?\d{2})$/i;
       //Fix for Bug #343496
       var dateFormatRegex = /^(?:(?:(?:0[13578]|1[02])(\/)31)\1|(?:(?:0[1,3-9]|1[0-2])(\/)(?:29|30)\2))(?:(?:19|[2-9]\d)\d{2})$|^(?:02(\/)29\3(?:(?:(?:19|20)(?:[02468][048]|[13579][26]))))$|^(?:(?:0[1-9])|(?:1[0-2]))(\/)(?:0[1-9]|1\d|2[0-8])\4(?:(?:19|20)?\d{4})$/i;
       
        if(typeof dateValue === "undefined") {
            console.log('here we are');
            if(inputCmp.get('v.required')) {
                inputCmp.setCustomValidity("Complete this field");
                inputCmp.reportValidity();
                return false;
            }
            //Added if(dateValue != "") for BUG 186661 by Jagadeesh
        } else if(dateValue != "") {
            console.log('test');
            // Commented for Bug #140247
            //if (dateValue.match(dateFormatRegex) || dateValue.match(additionalFormatRegex)) {
            if (dateValue.match(dateFormatRegex)) {
                inputCmp.setCustomValidity("");
                inputCmp.reportValidity();
                //inputCmp.set("v.errors", null);
                return true;
            } else {
                inputCmp.setCustomValidity("Incorrect date/format. Please enter a valid date in the format MM/DD/YYYY");
                inputCmp.reportValidity();
                //Added for Bug #147269(Jagadeesh)
                inputCmp.set("v.value", "");
                //inputCmp.focus();                
                return false;
            }
        }
    },
    
 	// #US108687 (Ali Khan)
    skipForNow: function(component, event, helper) {
        this.getformName(component, event, helper,'Skip');//Swapna:For GTM
        component.set("v.spinner", true);
        var enrollmentId = component.get("v.programEnrollmentId");
        var processId = component.get("v.processId");
        var sectionId = component.get("v.sectionId");
        var action = component.get("c.grabNextURL");
        console.log('At grabNextURL action');
        
        action.setParams({
            enrollmentId : enrollmentId,
            processComponentId : processId,
            sectionComponentId : sectionId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS") {
                var peakResponse = response.getReturnValue();
                console.log(peakResponse);
                if(peakResponse.success) {
                    console.log('Success');
                    console.log('skipForNow: ' + peakResponse.messages[0]);
                    var event = $A.get("e.force:navigateToURL");
                    event.setParams({
                        "url": peakResponse.messages[0]
                    });
                    event.fire();
                } else {
                    console.log('Fail before go back');
                    component.set("v.spinner", false);
                    helper.goBack(component, event, helper);
                }
            } else {
                var error = response.getError();
                console.log("ERROR", error);
            }
        });
        
        $A.enqueueAction(action);
        
    } ,
     //Swapna:For GTM
    getformName: function(component, event, helper,skpRsbmt) {
        var action = component.get("c.getformName");
        
        action.setParams({
            sectionId: component.get('v.sectionId')
        });
        
        action.setCallback(this, function(response){
            
            component.set("v.formName", response.getReturnValue());
             helper.gtm(component, event, helper,skpRsbmt); 
        
        });
        
        $A.enqueueAction(action);
        
    },
    
    //Swapna:For GTM
    gtm: function(component, event, helper,skpRsbmt){
     
         var appEvent = $A.get("e.c:NES_GTMEvent"); 
         var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DDTHH:mm:ss");
         appEvent.setParams({"eventNm":"event"});
         appEvent.setParams({"eventValue":"pageview"});
         appEvent.setParams({"step":skpRsbmt});
         appEvent.setParams({"stepValue":skpRsbmt});
         appEvent.setParams({"pagePath":document.location.href});
	     appEvent.setParams({"StudentName":component.get("v.studentName")}); 
         appEvent.setParams({"FormName":component.get("v.formName")}); 
 	    // appEvent.setParams({"FormStatus":component.get("v.currentFormStatus")}); 
         appEvent.setParams({"SectionName":component.get("v.sectionName")}); 
       	 appEvent.setParams({"studentId":component.get("v.studentId")}); 
         appEvent.setParams({"careTakerId":component.get("v.caretakerId")}); 
         appEvent.setParams({"timeStamp":today}); 
         appEvent.fire();
    },
    //Added by Jagadeesh for the Task :341992
     getAhiAckUpdate: function(component, event, helper) {
        var action = component.get("c.updateAHIRec");
                action.setParams({
            programEnrollmentId : component.get('v.programEnrollmentId')
        });
              action.setCallback(this, function(response){
                  var state = response.getState();
                  if(state === "SUCCESS") {
                      var peakResponse = response.getReturnValue();
                      console.log('getAhiAckUpdate: '+peakResponse);  
                      $A.get('e.force:refreshView').fire();
                      if(peakResponse == null)
                       //   window.open("https://obl.tfaforms.net/8?prgenrollid="+ component.get('v.programEnrollmentId')+'&sectionId='+component.get('v.sectionId'), "_blank");
                          window.open("https://obl.tfaforms.net/14?prgenrollid="+ component.get('v.programEnrollmentId')+'&sectionId='+component.get('v.sectionId'), "_blank");

                  } else {
                      var error = response.getError();
                      console.log("ERROR", error);
                  }
              });
              
              $A.enqueueAction(action);
        
    },
    //ended by jagdaeesh
})