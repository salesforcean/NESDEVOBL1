/***
 * Created by lukestevens on 2019-01-24.
 */
({
    init: function(component, event, helper) {
        console.log('In init function');
        console.log('MDR controller');

        console.log(component.get('v.questionGroupId'), 'That is my questionGroupId');
        console.log(component.get('v.programEnrollmentId'), 'That is my programEnrollmentId');

        var action = component.get('c.getStates');
        action.setCallback(this, function(response){
            console.log('NCES_MDRController::c.getStates callback');
            console.log(response);
            console.log(JSON.parse(JSON.stringify(response)));
            console.log(response.getReturnValue());
            console.log('AFter all that');
            component.set("v.states", response.getReturnValue());
        });
        $A.enqueueAction(action);

        var action = component.get('c.getSchoolSearchSettings');
        action.setCallback(this, function(response){
            console.log('NCES_MDRController::c.getSchoolSearchSettings callback');
            console.log(response.getReturnValue());

            /*IsDeleted: false
            Keystroke_Delay_Seconds__c: 4
            Minimum_Characters__c: 6
            Name: "a100R000000FLSS"
            SetupOwnerId: "0050R000001WXaFQAW"*/

            //component.set("v.states", response.getReturnValue());
        });
        $A.enqueueAction(action);


        var getQuestionsAction = component.get('c.getQuestions');
        getQuestionsAction.setParams({
            'groupId': component.get('v.questionGroupId'),
            'enrollmentId': component.get('v.programEnrollmentId')
        });

        getQuestionsAction.setCallback(this, function(response){
            console.log('NCES_MDRController::c.getQuestions callback');
            console.log(response);
            console.log(JSON.stringify(response.getError()));
            console.log(response.getReturnValue());
        });

        $A.enqueueAction(getQuestionsAction);


        var getRelatedQuestionsAction = component.get('c.getRelatedQuestions');

        getRelatedQuestionsAction.setParams({
            "sectionComponentId": component.get('v.questionGroupId'),
            "enrollmentId": component.get('v.programEnrollmentId')
        });

        console.log('making callback');

        getRelatedQuestionsAction.setCallback(this,function(response){
            console.log('NCES_MDRController::c.getRelatedQuestions callback');
            console.log(response.getReturnValue());
            console.log(response.getError());

            var firstMDRFieldFound = false;

            var questions = response.getReturnValue();
            questions.forEach(function(question){
                //question.parentId = component.get('v.questionGroupId');
                question.mdrField = !$A.util.isEmpty(question.apiMapping);
                
                if(question.mdrField && !firstMDRFieldFound){
                    question.firstMDRField = true;
                    firstMDRFieldFound = true;
                }
            });

            console.log(questions);

            helper.runAssignment(component,event,helper, JSON.stringify(response.getReturnValue()), true);

            //component.set("v.questions", questions);

            helper.connectAnswerTargetsToEntry(component,event,helper);

            component.set("v.spinner", false);

        });

        console.log('before enqueue');

        //$A.enqueueAction(getRelatedQuestionsAction);
        helper.runAssignment(component,event,helper, null, true);

        console.log('action enqueued');
    },

    searchForSchool: function(component, event, helper) {
        //NES_MDRIntegration.searchSchool('Hebron High School', 'Hebron', 'IN')

        var alreadyInSearch = component.get('v.alreadyInSearch');
        component.set('v.selectedSchool', null);

        if(!alreadyInSearch) {
            component.set('v.alreadyInSearch', true);
            window.setTimeout($A.getCallback(function(){
                var action = component.get('c.searchSchool');
                console.log('Searching for: ' + component.get('v.schoolName').toLowerCase());

                console.log(component.get('v.schoolName') + component.get('v.schoolCity') + component.get('v.schoolState'));

                action.setParams({
                    'previousSchoolName': component.get('v.schoolName'),
                    'previousSchoolCity': component.get('v.schoolCity'),
                    'previousSchoolState': component.get('v.schoolState').toLowerCase(),
                });
                
                action.setCallback(this, function(response){
                    console.log('Search for school');
                    var schools = JSON.parse(response.getReturnValue());
                    console.log(schools);
                    //Let's only show the first 4 results
                    component.set("v.schools", schools.slice(0,4));
                    component.set("v.alreadyInSearch", false);
                    component.set("v.completedSearch", true);
                });
                $A.enqueueAction(action);
            }), 2000);
        }

    },

    selectSchool: function(component, event, helper) {
        console.log('Selected school');
        var indexOfSelectedSchool = event.currentTarget.getAttribute("data-schoolIndex");
        console.log(indexOfSelectedSchool);
        console.log(component.get('v.schools')[indexOfSelectedSchool]);
        console.log(JSON.stringify(component.get('v.schools')[indexOfSelectedSchool]));
        component.set("v.selectedSchool", parseInt(indexOfSelectedSchool));
        $A.util.removeClass(component.find("manualAddressLeadText"), "slds-text-color_error");
        $A.util.removeClass(component.find("schoolListText"), "slds-text-color_error");
        $A.util.removeClass(component.find("introText"), "slds-text-color_error");

        helper.connectSchoolEntryToFields(component, event, helper, component.get('v.schools')[indexOfSelectedSchool]);
    },

    triggerManualAddress: function(component, event, helper) {
        component.set("v.isManualAddress", true);
        component.set("v.selectedSchool", null);
        helper.verifyQuestion(component, event, helper);
    },

    handleSubmit: function(component, event, helper) {

        console.log('In submit');

        var action = component.get('c.updateEnrollmentAnswerTarget');

        var isManualAddress = component.get("v.isManualAddress");

        var manualSchoolAddress = {};

        helper.connectSchoolEntryToFields(component, event, helper);

        if(isManualAddress) {
            manualSchoolAddress = {
                "streetAddress":component.get('v.schoolAddress'),
                "stateAbbr":component.get('v.schoolState'),
                "schoolName":component.get('v.schoolName'),
                "postalCode":component.get('v.schoolZip'),
                "districtName":component.get('v.schoolDistrict'),
                "countryAbbr":component.get('v.schoolCountry'),
                "city":component.get('v.schoolCity')};
        }

        if(isManualAddress || component.get('v.selectedSchool') != null) {
            console.log('Saving answers');
            action.setParams({
                'schoolAddress': isManualAddress ? JSON.stringify(manualSchoolAddress) : component.get('v.rebuiltSchool') != null ?
                    JSON.stringify(component.get('v.rebuiltSchool') != null) : JSON.stringify(component.get('v.schools')[component.get('v.selectedSchool')]),
                'questionGroupId': component.get('v.questionGroupId'),
                'programEnrollmentId': component.get('v.programEnrollmentId'),
                'apiValidated': isManualAddress ? false : true,
            });

            action.setCallback(this, function(response){
                console.log('In callback');
                console.log(response);
                console.log(JSON.parse(JSON.stringify(response)));
                console.log(response.getReturnValue());
                console.log('After all that');

                component.set("v.spinner", false);
            });
            $A.enqueueAction(action);
        }

        var evaluateAction = component.get('c.evaluateQuestions');

        evaluateAction.setParams({
            'enrollmentId': component.get('v.programEnrollmentId'),
            'questions':JSON.stringify(component.get('v.questions')),
            'sectionComponentId':component.get('v.questionGroupId')
        });

        evaluateAction.setCallback(this, function(response){
            component.set("v.spinner", false);
        });

        component.set("v.spinner", true);

        $A.enqueueAction(evaluateAction);
    },

    validateFields: function(component, event, helper) {
        console.log('into validation');
        var validatedForm = helper.verifyQuestion(component, event, helper);
        return validatedForm;
    },

    runAssignment: function(component, event, helper) {

        //Fire event to let the parent know to run assignment
        if($A.util.hasClass(event.getSource(), "hasCriteria")) {
            helper.connectSchoolEntryToFields(component, event, helper);
            //Have a look here Added by Jagadeesh
          helper.runAssignment(component, event, helper, JSON.stringify(component.get('v.questions'))), false;
        }

    }
})