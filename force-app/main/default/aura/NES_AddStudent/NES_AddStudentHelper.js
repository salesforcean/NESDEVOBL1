/**
 * Created by karolbrennan on 10/26/18.
 *Ravi09/23/2021
 */ 
({
    /* Gets data relevant to the New Student form */
    getNewStudent: function(component, event, helper, shouldShowActiveStudents)
    {
        component.set("v.newStudentData", null);
        component.set("v.showRelationshipError",false);
        var action = component.get("c.getNewStudentData");
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var returnedResponse = response.getReturnValue();
                returnedResponse.schoolYears = null;
                returnedResponse.SelectedSchoolYear = '';
                returnedResponse.relationshipType = '';
                helper.clearRelationships(component,event,helper);

                if(returnedResponse.schoolYears) {
                    returnedResponse.schoolYears.sort(function(a,b){
                        if(a.Name < b.Name){
                            return -1;
                        } else if(a.Name > b.Name){
                            return 1;
                        }
                        return 0;
                    });
                }
                

                component.set("v.newStudentData", returnedResponse);
                if(returnedResponse.defaultAccount.Id != null && component.get("v.numberOfStudents") == 0) {
                    var schoolSelect = component.find('schoolSelect');
                    schoolSelect.set('v.value', returnedResponse.defaultAccount.Id);
                    var a = component.get('c.handleSchoolSelect');
                    $A.enqueueAction(a);
                }

                if(shouldShowActiveStudents) {
                    component.set("v.addStudentActive", true);
                }
             //   console.log(returnedResponse);

            } else {
                var error = response.getError();
                console.log("Error: ", error);
            }
        });

        $A.enqueueAction(action);
        //Start- added logic for suffix US116612
        
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
        
        //End- added logic for suffix US116612
        
        
    },
    clearRelationships: function(component,event,helper)
    {
        component.find("relationship1").getElement().checked = false;
        component.find("relationship2").getElement().checked = false;
        component.find("relationship3").getElement().checked = false;
        component.find("relationship4").getElement().checked = false;
    },
    cancel: function(component,event,helper)
    {
        component.set("v.confirmOpen", false);
        component.set("v.newStudentData", null);
        helper.getNewStudent(component,event,helper);
        component.set("v.addStudentActive", false);
        component.set("v.fsupplementalQuestionsLoaded",false);
        component.set("v.supplementalQuestions",null);
        component.set("v.message", '');
    },
    /* Handle select drop downs */
    handleSchoolYearSelect: function(component, event, helper)
    {
        var schoolYear = event.getSource().get('v.value');
        var newStudentData = component.get("v.newStudentData");
        newStudentData.SelectedSchoolYear = schoolYear;
        component.set("v.newStudentData", newStudentData);
        console.log('schoolYear', schoolYear);
        console.log('StudentData:::'+newStudentData);
       
        if(schoolYear) {
            helper.getSupplementalQuestions(component, event, helper);
        }
    },

    handleSchoolSelect: function(component, event, helper)
    {
        // Reset the supplemental questions if they were previously set
        if(component.get("v.supplementalQuestionsLoaded")){
            component.set("v.supplementalQuestions", []);
            component.set("v.supplementalQuestionsLoaded", false);
        }
        component.set("v.disableCreate", true);
        var yearSelect = component.find('yearSelect');
        yearSelect.set("v.value", '');
        var studentData = component.get("v.newStudentData");
        var schoolId = component.find('schoolSelect').get('v.value');
        var action = component.get("c.getSchoolYears");
        action.setParams({
            schoolId: schoolId
        });
        action.setCallback(this, function(response){
            var peakResponse = response.getReturnValue();
            if(peakResponse.success){
                studentData.schoolYears = peakResponse.results;
                // Error msg Added by RAVI US #433409 
                if(studentData.schoolYears == '' || studentData.schoolYears ==  null ||studentData.schoolYears == undefined)
                {
                    component.set("v.schoolYearsNotAvail", true);
                   // component.set("v.SchoolYearErrormsg", 'The school you have selected does not have any school years available');
               }
                //End Here
                studentData.SelectedSchoolId = schoolId;
                studentData.schoolYears.sort(function(a,b){
                    if(a.Name < b.Name){
                        return -1;
                    } else if(a.Name > b.Name){
                        return 1;
                    }
                    return 0;
                });

                component.set("v.newStudentData", studentData);
            } else {
                component.set("v.message", peakResponse.messages[0]);
                console.log("Error State: " + peakResponse.messages[0]);
            }
        });
        $A.enqueueAction(action);
        component.set("v.loading", false);
    },

    /* Get questions associated to the academic program */
    getSupplementalQuestions: function(component, event, helper)
    {
        component.set("v.supplementalQuestions", []);
        var studentData = component.get("v.newStudentData");
        var schoolId = studentData.SelectedSchoolId;
        var yearId = studentData.SelectedSchoolYear;
        var action = component.get("c.getComponentsByAcademicProgram");
        action.setParams({
            schoolId: schoolId,
            schoolYearId : yearId

        });
        console.log('getSupplementalQuestions(' + schoolId + ', ' + yearId );
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                component.set("v.disableCreate", false);
                var returnedResponse = response.getReturnValue();
              console.log('Response$$$-'+returnedResponse);
               
                var questions = [];
                if(returnedResponse) {
                    for(var i=0;i<returnedResponse.length;i++) {
                        var question = returnedResponse[i];
                        var missingGrades = '';
                        // Added by RAVI #US 433409
                        if(question.questionType === 'Picklist'&& question.questionPrompt.includes("What grade will you be requesting for this student?")) {
                          
                            var incloptions = question.picklistValues;
                            var excloptions = question.exclPicklistValues;
							if(incloptions.length == 0 ){
                                missingGrades = 'There are no grades available for this school';
                                component.set('v.GradesNotAvailMsg', missingGrades);
                                }
                             
                           else if(excloptions){
                                console.log(excloptions);
                                for(var j=0;j<excloptions.length;j++) {
                                    var exoption = excloptions[j];
                                    if(missingGrades == ''){
                                    	missingGrades =  excloptions[j].value;
                                    }
                                    else{
                                    	missingGrades = missingGrades + ',' + excloptions[j].value;
                                    }
                                }
                                if(missingGrades.length>0 && missingGrades!=null){
                                    missingGrades = 'Grade(s) '  + missingGrades  +' not available for this school at the moment';
                                    component.set("v.GradesNotAvailMsg", missingGrades);
                                }else{
                                    component.set("v.GradesNotAvailMsg", '');
                                }
                            }
                        }
                        
                        
                        //Endded here
                        questions.push(question);
                    }
                    questions.sort(function(a, b){return a.order - b.order});
                    console.log('questions'+JSON.stringify(questions));
                    component.set("v.supplementalQuestions", questions);
                    component.set("v.supplementalQuestionsLoaded", true);
                }
            } else {
                var error = response.getError();
                console.log("Error: ", error);
                
            }
        });

        $A.enqueueAction(action);
    },

    /* Creates student / caretaker relationship */
    submitStudentData: function(component, event, helper)
    {
        var studentData = component.get("v.newStudentData");
        var questionData = component.get("v.supplementalQuestions");

     //   console.log(studentData);
     //   console.log(questionData);
        
       this.gtm(component,questionData); //Swapna:Added for GTM
        
        var validForm = false;
        validForm = helper.validateForm(component, event, helper);
        console.log(validForm);
        if(!validForm) {
            component.set("v.loading", false);
            return;
        }

        if(questionData){
            for(var i=0;i<questionData.length;i++) {
                questionData[i].picklistValues = [];
            }
        } else {
            questionData = [];
        }
        if(studentData) {
            studentData.activeSchools = [];
            studentData.gradeLevels = [];
            studentData.schoolYears = [];
        }

        var action = component.get("c.createStudent");
        action.setParams({
            studentJSON: JSON.stringify(studentData),
            questionJSON: JSON.stringify(questionData)
        });

        action.setCallback(this, function(response){
            var peakResponse = response.getReturnValue();
            if(peakResponse != null && peakResponse.success){
                var appEvent = $A.get("e.c:NES_AddStudentAppEvent");
                appEvent.setParams({
                   message: peakResponse.messages[0]
                });
                appEvent.fire();
                component.set("v.addStudentActive", false);
                component.set("v.loading", false);
                component.set("v.supplementalQuestions", null);
               // var isValid = response.getReturnValue();
                // setTimeout(function(){ $A.get('e.force:refreshView').fire(); }, 9000);
                
            } else {
                component.set("v.message", "Sorry, we were unable to add your student. Please try again. If the problem persists please contact us.");
                if(peakResponse != null) {
                    console.log("Error State: " + peakResponse.messages[0]);
                }
                component.set("v.loading", false);
            }
        });
        $A.enqueueAction(action);
    },
    validateForm: function (component, event, helper) {
        console.log('in validate');
        var formItems = component.find('fieldId');
        console.log(formItems);
        var allValid = true;

        var relationshipType = component.get('v.newStudentData').relationshipType;
        console.log('relationshipType', relationshipType);
        if(relationshipType === '') {
            component.set("v.showRelationshipError",true);
            allValid = false;
        } else {
            component.set("v.showRelationshipError",false);
        }

        var newValid = component.find('fieldId').reduce(
            function (validSoFar, inputCmp) {
                console.log(inputCmp.get('v.value'));
                    //This is needed to deal with a Salesforce bug where old iteration elements are being
                    //returned from component.find

                if(inputCmp.isRendered()){
                    inputCmp.showHelpMessageIfInvalid();
                } else {
                    return true;
                }

                return validSoFar && inputCmp.get('v.validity').valid && !inputCmp.get('v.validity').valueMissing;
                }, true);

        var schoolSelect = component.find('schoolSelect');
        var schoolValue = schoolSelect.get("v.value");
        if(!schoolValue) {
            schoolSelect.showHelpMessageIfInvalid();
            allValid = false;
        }
        var yearSelect = component.find('yearSelect');
        if(yearSelect) {
            var yearValue = yearSelect.get("v.value");
            console.log('yearSelect', yearValue);
            if(!yearValue) {
                yearSelect.showHelpMessageIfInvalid();
                allValid = false;
            }
        }


        var dateItems = [];
        var dateFields = component.find('dateField');
        if(dateFields) {
            if(dateFields.constructor === Array){
                console.log(dateFields.length);
                var prunedDateFields = [];
                dateFields.forEach(function(dateField){
                    if(dateField.isRendered()){
                        prunedDateFields.push(dateField);
                    }
                });
                dateItems = prunedDateFields;
            } else {
                console.log('3');
                dateItems.push(dateFields);
            }
            console.log('dates',dateItems);
            if(dateItems) {
                allValid = dateItems.reduce(
                    function (validSoFar, inputCmp) {
                        var dateValue = inputCmp.get("v.value");
                        //Have to set Regex for yyyy-mm-dd because when retrieving the value it auto changes mm/dd/yyyy to that
                        var dateFormatRegex = /^\d{4}\-(0?[1-9]|1[012])\-(0?[1-9]|[12][0-9]|3[01])$/;
                        if(typeof dateValue === "undefined") {
                            if(inputCmp.get('v.required')) {
                                inputCmp.set("v.errors", [{message:"Complete this field"}]);
                            }
                            return validSoFar && !inputCmp.get('v.required');
                        } else {
                            if (dateValue.match(dateFormatRegex)) {
                                return validSoFar;
                            } else {
                                inputCmp.set("v.errors", [{message:"Incorrect format. Please use the format MM/DD/YYYY"}]);
                                return false;
                            }
                        }
                    }, allValid);
            }
        }

        console.log('through fields');
        return allValid && newValid;
    },

    validateDate: function(component, event, helper){
        var inputCmp = event == null ? component : event.getSource();
        console.log(inputCmp);
        var dateValue = inputCmp.get("v.value");
        //Have to set Regex for yyyy-mm-dd because when retrieving the value it auto changes mm/dd/yyyy to that
        console.log(dateValue);
        console.log(new Date(dateValue));
        var dateFormatRegex = /^\d{4}\-(0?[1-9]|1[012])\-(0?[1-9]|[12][0-9]|3[01])$/;
        var additionalFormatRegex = /([1-9]|0[1-9]|1[012])[- \/.]([1-9]|0[1-9]|[12][0-9]|3[01])[- \/.](19|20)\d\d/
        if(typeof dateValue === "undefined") {
            if(inputCmp.get('v.required')) {
                inputCmp.set("v.errors", [{message:"Complete this field"}]);
                return false;
            }
        } else {
            if (dateValue.match(dateFormatRegex) || dateValue.match(additionalFormatRegex)) {
                inputCmp.set("v.errors", null);
                return true;
            } else {
                inputCmp.set("v.errors", [{message: "Incorrect format. Please use the format MM/DD/YYYY"}]);
                return false;
            }
        }
    },
    //Swapna:For GTM
    gtm: function(component,questionData){
       // alert(JSON.stringify(studentData));
      
     
         var appEvent = $A.get("e.c:NES_GTMEvent"); 
           var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DDTHH:mm:ss");
        appEvent.setParams({"eventNm":"event"});
        appEvent.setParams({"eventValue":"createStudent"});
         appEvent.setParams({"step":"createStudent"});
         appEvent.setParams({"stepValue":"createStudent"});
         appEvent.setParams({"pagePath":document.location.href});
		appEvent.setParams({"newStudentData":questionData}); 
   //    appEvent.setParams({"studentId":today}); 
        appEvent.setParams({"relationship":component.get("v.newStudentData.relationshipType")}); 
        appEvent.setParams({"schoolName":component.get("v.newStudentData.SelectedSchoolId")}); 
     //   appEvent.setParams({"gradeLevel":JSON.stringify(studentData).gradeLevels.Name}); 
        appEvent.setParams({"schoolYear":component.find('yearSelect').get('v.value')}); 
        appEvent.setParams({"timeStamp":today}); 
        
		appEvent.fire();
    }

})