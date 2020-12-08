/**
 * Created by karolbrennan on 12/1/18.
 * Updated 10/1/2019 #US110685 (Andrew Sim)
*/
({ 
    initiateStudent: function(component, event, helper)
    {
        var vars = {};
        window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(m,key,value) {
            var newValue = decodeURIComponent(value);
            vars[key] = newValue.replace(/[+]/gm, ' ');
        });

        console.log(vars);

        if(vars.hasOwnProperty('studentId')) {
            component.set("v.studentId", vars['studentId']);
        }
        if(vars.hasOwnProperty('caretakerId')) {
            component.set("v.caretakerId", vars['caretakerId']);
        }
        if(vars.hasOwnProperty('studentGrade')) {
            component.set("v.studentGrade", vars['studentGrade']);
        }

        if(vars.hasOwnProperty('processId')) {
            component.set("v.processId", vars['processId']);
        }
        if(vars.hasOwnProperty('programEnrollmentId')) {
            component.set("v.programEnrollmentId", vars['programEnrollmentId']);
        }

        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var caretakerId = component.get("v.caretakerId");
        if(caretakerId) {
            if(userId === caretakerId) {
                helper.grabStudentName(component, event, helper);
            } else {
                component.set("v.spinner", false);
                component.set("v.invalidUser", true);
            }
        } else {
            component.set("v.spinner", false);
        }

    },

    grabStudentName: function(component, event, helper) {

        var studentId = component.get("v.studentId");
        var programEnrollmentId = component.get("v.programEnrollmentId");
        var action = component.get("c.grabNameOfStudent");
        action.setParams({
            studentId: studentId,
            programEnrollmentId: programEnrollmentId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                if(response.getReturnValue() === 'InvalidUser') {
                    component.set("v.invalidUser", true);
                    component.set("v.spinner", false);
                } else {
                    component.set("v.studentName", response.getReturnValue());

					//Make sure the enrollment components are built.
					helper.confirmComplete(component, event, helper);


                }
            } else {
                var error = response.getError();
                console.log("ERROR", error);
            }
        });

        $A.enqueueAction(action);
    },

	confirmComplete: function(component, event, helper) {
        console.log('fire logo');
        var programEnrollmentId = component.get("v.programEnrollmentId");
        var action = component.get("c.getIsEnrollmentReady");
        action.setParams({
            enrollmentId: programEnrollmentId

        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var returnedResponse = response.getReturnValue();
                if(returnedResponse == true) {
                    helper.grabSchool(component, event, helper);
                    helper.getProcessInfo(component, event, helper);
                    helper.getProcessStages(component, event, helper);
                } else {
                    helper.confirmComplete(component, event, helper);
				}
            } else {
                var error = response.getError();
                console.log("ERROR", error);
            }
        });

        $A.enqueueAction(action);

    },
    grabSchool: function(component, event, helper) {
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

    handleTab: function(component, event, helper) {
        var activeTabId = 'tab' + component.get("v.activeTab");
        var activeTabIndex = component.get("v.activeTab");
        var clickedTabId = event.currentTarget.id;
        var clickedTabIndex = clickedTabId.substr(3, clickedTabId.length);
        var activeTabElement = document.getElementById('tablink' + activeTabIndex);
        var clickedTabElement = document.getElementById('tablink' + clickedTabIndex);

        if(clickedTabId != activeTabId) {
            component.set("v.spinner", true);
            var activeDiv = activeTabElement.getAttribute('aria-controls');
            var clickedDiv = clickedTabElement.getAttribute('aria-controls');

            document.getElementById(activeTabId).classList.toggle('slds-is-active');
            document.getElementById(clickedTabId).classList.toggle('slds-is-active');

            activeTabElement.setAttribute('aria-selected', 'false');
            activeTabElement.setAttribute('tabindex', '-1');
            clickedTabElement.setAttribute('aria-selected', 'true');
            clickedTabElement.setAttribute('tabindex', '0');

            $A.util.toggleClass(document.getElementById(activeDiv), 'slds-show');
            $A.util.toggleClass(document.getElementById(activeDiv), 'slds-hide');
            $A.util.toggleClass(document.getElementById(clickedDiv), 'slds-show');
            $A.util.toggleClass(document.getElementById(clickedDiv), 'slds-hide');

            component.set("v.activeTab", clickedTabIndex);
            var forms = component.get("v.forms");
            var currentFormId = forms[clickedTabIndex].formId;
            //Swapna:For GTM
            var activeFormName = forms[clickedTabIndex].name; 
            var activeFormStatus = forms[clickedTabIndex].ecaStatus;
            component.set("v.currentFormName",activeFormName);
            component.set("v.currentFormStatus",activeFormStatus);
            component.set("v.currentFormId", currentFormId);
            helper.getSections(component,event,helper);
            // #US110685 (Andrew Sim)
            window.scrollTo(0, 0);
        }
      
    },

    getProcessInfo: function(component, event, helper) {
        var processId = component.get("v.processId");
        var programEnrollmentId = component.get("v.programEnrollmentId");
        var action = component.get("c.getProcessInformation");
        action.setParams({
            processComponentId : processId,
            programEnrollmentId: programEnrollmentId
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS") {
                var returnedResponse = response.getReturnValue();
                console.log("Process:", returnedResponse);
                component.set("v.processInformation", returnedResponse);
            } else {
                var error = response.getError();
                console.log("ERROR", error);
            }
        });

        $A.enqueueAction(action);

    },
    getEnrollmentForms: function(component, event, helper)
    {
        var stageId = component.get("v.currentStageId");
        var programEnrollmentId = component.get("v.programEnrollmentId");
        var action = component.get("c.getRelatedForms");
        action.setParams({
            stageComponentId : stageId,
            enrollmentId : programEnrollmentId
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS") {
                var returnedResponse = response.getReturnValue();

                var inProgressFound = false;
                var activeFormId = "";
                //Swapna:For GTM
                var activeFormName = ""; //Swapna:For Gtm
            	var activeFormStatus = "";
                returnedResponse.sort(function(a, b){return a.orderNumber - b.orderNumber});
                returnedResponse.forEach(function(form, index){
                    if((form.ecaStatus == 'In Progress' || form.ecaStatus == 'Not Started') && !inProgressFound) {
                        component.set('v.activeTab', index);
                        activeFormId = form.formId;
                        //Swapna:For GTM
                        activeFormName = form.name;
                        activeFormStatus = form.ecaStatus;
                        inProgressFound = true;
                    }
                });
                component.set("v.forms", returnedResponse);
                console.log("forms", returnedResponse);
                if(returnedResponse) {
                    if(inProgressFound) {
                        component.set("v.currentFormId", activeFormId);
                        //Swapna:For GTM
                        component.set("v.currentFormName",activeFormName);
            			component.set("v.currentFormStatus",activeFormStatus);
                    } else {
                        component.set("v.currentFormId", returnedResponse[0].formId);
                    }

                }
                helper.getSections(component,event,helper);
            } else {
                var error = response.getError();
                console.log("ERROR", error);
            }
        });

        $A.enqueueAction(action);

    },
    getSections: function(component, event, helper) {
        var formId = component.get("v.currentFormId");
        var programEnrollmentId = component.get("v.programEnrollmentId");
        var action = component.get("c.getRelatedFormContent");
        action.setParams({
            formComponentId : formId,
            enrollmentId : programEnrollmentId
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS") {
                var returnedResponse = response.getReturnValue();
                console.log(returnedResponse);
                returnedResponse.sort(function(a, b){return a.order - b.order});
				//Added by Mark Membrino 2/6/2020 to deal with an aura error.
				try{
					component.set("v.sections", returnedResponse);
				} catch(e){}

                var sections = [];
                returnedResponse.forEach(function(section){
                    console.log('section loop');
                    console.log(section);
                    if(section.ecaStatus == 'Not Started'){
                        sections.push(section);
                        console.log('section match');
                    }
                });

                console.log(sections);

                component.set("v.incompleteSections", sections);

                console.log("These are the incompleteSections");
                console.log(sections);
                console.log(component.get("v.incompleteSections"));

                console.log("sections", returnedResponse);
                if(returnedResponse) {
                    component.set("v.currentSectionId", returnedResponse[0].Id);
                }
                helper.getMessages(component,event,helper);
            } else {
                var error = response.getError();
                console.log("ERROR", error);
            }
        });

        $A.enqueueAction(action);

    },
    getMessages: function(component, event, helper) {
        var formId = component.get("v.currentFormId");
        var programEnrollment = component.get("v.programEnrollmentId");
        var action = component.get("c.getRelatedMessages"); 
        action.setParams({
            enrollmentComponentId : formId,
            programEnrollmentId : programEnrollment
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS") {
                var returnedResponse = response.getReturnValue();
                component.set("v.messages", returnedResponse);
            } else {
                var error = response.getError();
                console.log("ERROR", error);
            }
            component.set("v.spinner", false);
        });

        $A.enqueueAction(action);

        //We also need to check for stage messages

        var stageMessagesAction = component.get("c.getRelatedMessages");
        stageMessagesAction.setParams({
            enrollmentComponentId : component.get("v.currentStageId"),
            programEnrollmentId : programEnrollment
        });

        console.log(component.get("v.currentStageId"));

        stageMessagesAction.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS") {
                var returnedResponse = response.getReturnValue();
                console.log(returnedResponse);
                console.log('That was the stages messages');
                component.set("v.stageMessages", returnedResponse);
            } else {
                var error = response.getError();
                console.log("ERROR", error);
            }
            component.set("v.spinner", false);
        });

        $A.enqueueAction(stageMessagesAction);

    },
    getProcessStages:  function(component, event, helper)
    {
        var programEnrollmentId = component.get("v.programEnrollmentId");
        var action = component.get("c.getRelatedStages");
        action.setParams({
            programEnrollmentId : programEnrollmentId
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS") {
                var returnedResponse = response.getReturnValue();
                var stages = [];
                var completedStages = [];
                var noOrderStages = [];
                if(returnedResponse){
                    var completeTally = 0;

                    returnedResponse.sort(function(a, b){
                        return a.Order__c - b.Order__c
                    });

                    for(var i=0;i<returnedResponse.length; i++) {
                        if(returnedResponse[i].Order__c != null) {
                            stages[i] = returnedResponse[i];
                        } else {
                            noOrderStages.push(returnedResponse[i])
                        }
                        if(returnedResponse[i].Status__c == 'In Progress') {
                            var indexVar = i;
                            component.set("v.currentStep", indexVar);
                            component.set("v.currentStageId",returnedResponse[i].Enrollment_Component__c);
                        } else if(returnedResponse[i].Status__c == 'Complete') {
                            completeTally++;
                        }
                    }
                    console.log("### Current Stage Id :::"+component.get("v.currentStageId"));
                
                    if(completeTally === returnedResponse.length){
                        console.log('All complete!');
                        component.set("v.allStepsComplete", true);
                        helper.goToDashboard();
                    }
                }

                if(noOrderStages.length > 0) {
                    noOrderStages.forEach(stage => {
                        stages.push(stage);
                    })
                }

                component.set("v.completedStages", completeTally);
                component.set("v.stages", stages);
                console.log("Stage length: " + stages.length);
                helper.getEnrollmentForms(component, event, helper);
            } else {
                var error = response.getError();
                console.log("ERROR", error);
            }
        });

        $A.enqueueAction(action);
    },
    goToDashboard: function(component, event, helper)
    {
        var event = $A.get("e.force:navigateToURL");
        event.setParams({
            "url": "/dashboard"
        });
        event.fire();
    },
    navigate: function(component, event, helper){
        var sectionType = component.get("v.currentSectionType");
        if(sectionType === 'Document'){
            helper.navigateToDocs(component, event, helper);
        } else{
            helper.navigateToQuestions(component, event, helper);
        }
    },

    navigateToDocs: function(component, event, helper) {
        this.gtm(component, event);//Swapna:For GTM
        var url = '/document-uploader';
        var redirect = $A.get("e.force:navigateToURL");
        var affiliationId = component.get("v.currentECAId");
        var studentId = component.get("v.studentId");
        var caretakerId = component.get("v.caretakerId");
        var studentGrade = component.get("v.studentGrade");
        var processId = component.get("v.processId");
        var programEnrollmentId = component.get("v.programEnrollmentId");
		var formName = component.get("v.currentFormName");
        url = url + '?enrollmentComponentAffiliationId=' + encodeURIComponent(affiliationId)
            + '&studentId=' + encodeURIComponent(studentId)
            + '&caretakerId=' + caretakerId
            + '&programEnrollmentId=' + encodeURIComponent(programEnrollmentId)
            + '&processId=' + encodeURIComponent(processId)
            + '&studentGrade=' + encodeURIComponent(studentGrade)
        	+ '&formName=' + encodeURIComponent(formName);
        console.log(url);
        redirect.setParams({
            "url" : url
        });
        redirect.fire();
        console.log('Attempted to navigate to docs');
    },
    navigateToQuestions: function(component, event, helper)
    {
        this.gtm(component, event); //Swapna:For GTM
        var url = '/questions';
        var redirect = $A.get("e.force:navigateToURL");
        var studentId = component.get("v.studentId");
        var sectionId = component.get("v.currentSectionId");
        var processId = component.get("v.processId");
        var programEnrollmentId = component.get("v.programEnrollmentId");
        var caretakerId = component.get("v.caretakerId");
        var studentGrade = component.get("v.studentGrade");
        var formName = component.get("v.currentFormName");
        url = url + '?studentId=' + encodeURIComponent(studentId) + '&sectionId=' + encodeURIComponent(sectionId)
            + '&processId=' + encodeURIComponent(processId) + '&programEnrollmentId=' + encodeURIComponent(programEnrollmentId)
            + '&caretakerId=' + caretakerId + '&studentGrade=' + encodeURIComponent(studentGrade) + '&formName=' + encodeURIComponent(formName);
        redirect.setParams({
            "url" : url
        });
        redirect.fire();

    },
    toggleMobileSide: function(component, event, helper) {
        var showTabs = component.get("v.showTabs");
        var showContent = component.get("v.showContent");
        component.set("v.showTabs",!showTabs);
        component.set("v.showContent",!showContent);
    },
    stepHover: function(component, event, helper)
    {
        var classes = event.currentTarget.getAttribute('class');
        var hoveringOverCurrentInProgress = classes.indexOf('slds-is-active') >= 0;
        var notAllCompleted =  document.getElementsByClassName('slds-is-active').length > 0;
        var completedItems = document.getElementsByClassName('slds-is-completed');
        var hoveringOverLastCompleted = event.currentTarget == completedItems[completedItems.length - 1];

        if((!hoveringOverCurrentInProgress && notAllCompleted) || (!notAllCompleted && !hoveringOverLastCompleted)) {
            $A.util.toggleClass(event.currentTarget, 'showItem');
            if(notAllCompleted) {
                $A.util.toggleClass(document.getElementsByClassName('slds-is-active')[0], 'hideItem');
            } else {
                $A.util.toggleClass(completedItems[completedItems.length - 1], 'hideItem');
            }
        }

    },
    //Swapna:For GTM
    gtm: function(component, event){
         var appEvent = $A.get("e.c:NES_GTMEvent"); 
         var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DDTHH:mm:ss");
         appEvent.setParams({"eventNm":"event"});
         appEvent.setParams({"eventValue":"pageview"});
         appEvent.setParams({"step":"Start"});
         appEvent.setParams({"stepValue":"Start"});
         appEvent.setParams({"pagePath":document.location.href});
	     appEvent.setParams({"StudentName":component.get("v.studentName")}); 
         appEvent.setParams({"FormName":component.get("v.currentFormName")}); 
 	     appEvent.setParams({"FormStatus":component.get("v.currentFormStatus")}); 
         appEvent.setParams({"SectionName":component.get("v.currentSectionName")}); 
       	 appEvent.setParams({"studentId":component.get("v.studentId")}); 
         appEvent.setParams({"careTakerId":component.get("v.caretakerId")}); 
         appEvent.setParams({"timeStamp":today}); 
         appEvent.fire();
    }

})