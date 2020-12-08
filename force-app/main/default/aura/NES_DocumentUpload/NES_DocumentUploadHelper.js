/**
 * Created by karolbrennan on 11/9/18.
 */
({
    grabSchool: function (component, event, helper) {
        console.log('grabbing school');
        var vars = {};
        var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(m,key,value) {
            var newValue = decodeURIComponent(value);
            vars[key] = newValue.replace('+', ' ');
        });
        //('before grabbing program enrollment');
        var programEnrollmentId = vars['programEnrollmentId'];
        component.set("v.programEnrollmentId", programEnrollmentId);
        var caretakerId = vars['caretakerId'];
        component.set("v.caretakerId", caretakerId);
        var studentId = vars['studentId'];
        console.log('studentId: ' + studentId);
        component.set("v.studentId", studentId);
        console.log('after grabbing program enrollment');
        var action = component.get("c.grabSchool");
        console.log('About to send school');
        action.setParams({
            enrollmentId: programEnrollmentId

        });
        action.setCallback(this, function(response) {
            console.log('In grab school response');
            var state = response.getState();
            if(state === "SUCCESS") {
                console.log('successful response');
                var returnedResponse = response.getReturnValue();
                if(returnedResponse) {
                    var schoolAppEvent = $A.get("e.c:NES_schoolId");
                    schoolAppEvent.setParams({
                        "schoolids" : returnedResponse });

                    schoolAppEvent.fire();
                    console.log('fired school event');
                }
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

    grabStudentName: function(component, event, helper) {

        var studentId = component.get("v.studentId");
        console.log('studentId: ' + studentId);
        var action = component.get("c.grabNameOfStudent");
        action.setParams({
            studentId: studentId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                console.log(response.getReturnValue());
                if(response.getReturnValue() === 'InvalidUser') {
                    component.set("v.invalidUser", true);
                    component.set("v.spinner", false);
                } else {
                    component.set("v.studentName", response.getReturnValue());
                    helper.initializeComponent(component, event, helper);
                }
            } else {
                var error = response.getError();
                console.log("ERROR", error);
            }
        });

        $A.enqueueAction(action);
    },
    initializeComponent: function (component, event, helper) {

        //Get ECA Id and ED Ids
        var enrollmentComponentAffiliationId;
        var enrollmentDocumentId;

        //When Document Uploader is used on ECA or ED record page
        var objectName = component.get('v.sObjectName');

        //Check if component is being used on record page, if not grab ECA and ED id's from URL params
        if(objectName === 'Enrollment_Component_Affiliation__c'){
            enrollmentComponentAffiliationId = component.get('v.recordId');
            component.set('v.isOnRecordPage', true);

        }else if(objectName === 'Enrollment_Document__c'){
            enrollmentDocumentId = component.get('v.recordId');
            component.set('v.isOnRecordPage', true);

        }else{
            console.log('Getting param');
            enrollmentComponentAffiliationId = helper.getUrlParameter('enrollmentComponentAffiliationId');
            enrollmentDocumentId = helper.getUrlParameter('enrollmentDocumentId');
            console.log('Received param. It was: ');
            console.log(enrollmentDocumentId);

        }

        component.set('v.enrollmentDocumentId', enrollmentDocumentId);
        console.log('before document info');

        if(enrollmentComponentAffiliationId !== "undefined" && enrollmentComponentAffiliationId != null) {

            component.set('v.enrollmentComponentAffiliationId', enrollmentComponentAffiliationId);
            var action = component.get("c.getUIContent");
            action.setParams({
                enrollmentComponentAffiliationId: enrollmentComponentAffiliationId,
                enrollmentDocumentId : enrollmentDocumentId
            });
            action.setCallback(this, function (response) {

                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log('In get uicontent response');
                    var returnedResponse = response.getReturnValue();

                    component.set("v.DocumentInfo", JSON.parse(returnedResponse));

                    console.log('DOCUMENT INFO ===');
                    console.log(JSON.parse(returnedResponse));

                } else {
                    component.set("v.hasError", true);
                    console.log("ERROR!", response.getError());
                }
            });
            $A.enqueueAction(action);

            console.log('is initialized');

            component.set("v.isInitialized", true);
        } else {
            component.set("v.isInitialized", true);
        }

    }
});