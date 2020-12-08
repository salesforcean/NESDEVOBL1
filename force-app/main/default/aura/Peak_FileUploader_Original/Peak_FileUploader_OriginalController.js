/*
 * Created by 7Summits - Joe Callin on 3/17/18.
 * 2019-08-13 modified for #102160 User Story,Task 104354 (Maddileti Boya) 
 * 2019-10-04 added token cache #US109799/fixed #BUG112429  (Mark Membrino)
 * 2019-11-12 updated for #115213 User Story (Maddileti Boya)
*/


({
    doInit: function(component, event, helper) {
        console.log('In file uploader'); 
        component.set('v.isLoading', true);
        var vars = {};
        window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(m,key,value) {
            var newValue = decodeURIComponent(value);
            vars[key] = newValue.replace(/[+]/gm, ' ');
        });

        if(vars.hasOwnProperty('studentId')) {
            component.set("v.studentId", vars['studentId']);
        } else {
            component.set("v.backButtonLabel", "Back to Dashboard");
        }
        if(vars.hasOwnProperty('studentName')) {
            component.set("v.studentName", vars['studentName']);
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
        component.set("v.isInit",true);
    },
    iframeLoaded: function(component,event,helper){
		var self = this;
        component.set("v.iframeLoaded",true);
        var tokenExpiration = component.get("v.docTokenTimeout");
		var storedToken = JSON.parse(sessionStorage.getItem("documentTokenData"));
		if (!storedToken || !helper.isValidToken(storedToken, tokenExpiration)) {
            setTimeout(function(){
                    helper.initUploader(component, event, helper);
            },3000);
        } else {
                helper.initUploader(component, event, helper);
        }
    },
    handleFilesChange: function (component, event, helper) {
        helper.setFileList(component, event, helper);
    },
    deleteFile: function(component, event, helper) {
        component.set('v.isLoading', true);
        var name = event.currentTarget.dataset.name;
        var parentId = component.get('v.parentId');
        var valid = event.currentTarget.dataset.valid;
        //helper.deleteAttachment(component, event, helper, name, parentId, true);
        helper.removeFromList(component, event, name, valid);

        var currentList = component.get('v.curList');
        component.set('v.isLoading', false);
    },
    removeFile: function(component, event, helper) {
        var valid = event.currentTarget.dataset.valid;
        helper.removeFromList(component, event, null, valid);
    },
     skipForNow: function(component, event, helper) {
        console.log('skipForNow');
        helper.goToNextSectionOrOverview(component, event, helper);
    },
    accessCamera: function(component, event, helper)
    {
        const supported = 'mediaDevices' in navigator;
        if(supported){
            component.set('v.isSupported', true);
            helper.openCamera(component, event, helper);
        } else {
            component.set('v.cameraAccessError',"Sorry, this feature is not currently available in this browser.");
        }
    },
    drawImage: function(component, event, helper) {
        helper.drawImage(component, event, helper);
    },
    cancelImage: function(component, event, helper) {
        helper.cancelImage(component, event, helper);
    },
    addCameraShotToList: function(component, event, helper) {
        helper.addCameraShotToList(component, event, helper);
    },
    retakePhoto: function(component, event, helper) {
        helper.retakePhoto(component, event, helper);
    },
    directBack: function(component,event,helper) {
        helper.goBack(component, event, helper);
    },
    dismissModal: function(component, event, helper) {
        component.set("v.showWarningDialog", false);
    },
    goToOverview: function (component, event, helper) {

        var fileList = component.get('v.curList');
        if(fileList && fileList.length > 0) {
            //We need to warn them
            component.set("v.showWarningDialog", true);
        } else {
            helper.goBack(component, event, helper);
        }
    },
    handleSubmit: function(component, event, helper)
    {
		var self = this;
        component.set('v.isLoading', true);
        var curList = component.get("v.curList");
        var parentId = component.get("v.parentId");
        var enrollmentComponentAffiliationId = component.get('v.enrollmentComponentAffiliationId');
        var enrollmentDocumentId = component.get('v.enrollmentDocumentId');
        var isOnRecordPage = component.get('v.isOnRecordPage');

        if(curList.length > 0){
            console.log(curList);
            helper.saveFiles(component, event, helper, parentId, curList,enrollmentComponentAffiliationId,enrollmentDocumentId,isOnRecordPage, null, null );
        }else{
            component.set('v.isLoading', false);
            component.set('v.showList', true);
        }
    },
      // added by maddileti for #115213 User Story on 2019-11-12
    openModel: function(component, event, helper) {
      // Set isModalOpen attribute to true
      component.set("v.isModalOpen", true);
   },
      closeModel: function(component, event, helper) {
      // Set isModalOpen attribute to false  
      component.set("v.isModalOpen", false);
   },
  
   submitDetails: function(component, event, helper) {
      // Set isModalOpen attribute to false
     component.set("v.isModalOpen", false);
   } 
    //  end by maddileti for #115213 User Story on 2019-11-12
})