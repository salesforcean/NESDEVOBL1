/*
 * Copyright (c) 2018. 7Summits Inc.
 * Created by 7Summits - Joe Callin on 3/21/18.
*/
({
    // saveFiles: function(component, event, helper, parentId, curList,enrollmentComponentAffiliationId, enrollmentDocumentId,isOnRecordPage, index, files) {
    //     var self = this;
    //     var base64 = 'base64,';
    //     if(index === undefined){
    //         index = 0;
    //     }
    //     if(files === undefined){
    //         files = [];
    //     }
    //     if (component.get('v.useClientUpload')) {
    //         helper.clientSend(component, event, helper, curList, enrollmentComponentAffiliationId, enrollmentDocumentId,isOnRecordPage);
    //     } else {
    //         if (curList.length > 0 && index < curList.length) {
    //             getBase64(curList[index], index, files);
    //         } else if (index === curList.length) {
    //
    //             var uploadMessage = component.get('v.uploadMessage');
    //             if ($A.util.isUndefinedOrNull(uploadMessage) && $A.util.isEmpty(uploadMessage)) {
    //                 helper.showMessage('success', (curList.length > 1 ? 'Files uploaded successfully' : 'File uploaded successfully'));
    //             } else {
    //                 helper.showMessage('success', uploadMessage);
    //             }
    //
    //             component.set('v.isLoading', false);
    //             component.set('v.showList', true);
    //         }
    //     }
    //     function getBase64(file, index, files) {
    //         var reader = new FileReader();
    //         reader.readAsDataURL(file);
    //         reader.onload = $A.getCallback(function () {
    //             var fileContents = reader.result;
    //             var dataStart = fileContents.indexOf(base64) + base64.length;
    //             var chunkSize = component.get('v.chunkSize');
    //             fileContents = fileContents.substring(dataStart);
    //             // set a default size or startpostiton as 0
    //             var startPosition = 0;
    //             // calculate the end size or endPostion using Math.min() function which is return the min. value
    //
    //             var endPosition = Math.min(fileContents.length, startPosition + chunkSize);
    //             self.uploadInChunk(component, event, helper, parentId, file, fileContents, startPosition, endPosition, files, curList, index, '');
    //
    //         });
    //         reader.onerror = function (error) {
    //             helper.showMessage('error', error);
    //             console.log('Error: ', error);
    //         };
    //     }
    // },
    // uploadInChunk: function(component, event, helper, parentId, file, fileContents, startPosition, endPosition, files, curList, index, attachId) {
    //     var self = this;
    //     // This information could be used to create a file upload progress tracker
    //     // console.log('File Name ===== ' + file.name);
    //     // console.log('File Size ===== ' + fileContents.length);
    //     // console.log('File Progress Byte ===== ' + startPosition);
    //     // console.log('File Progress ===== ' + Math.round(startPosition/fileContents.length*100) + '%');
    //     var getchunk = fileContents.substring(startPosition, endPosition);
    //     var params = {
    //         parentId: parentId,
    //         fileName: file.name,
    //         base64Data: encodeURIComponent(getchunk),
    //         contentType: file.type,
    //         fileId: attachId
    //     };
    //     helper.doCallout(component,'c.saveChunk',params).then(function(response){
    //         if (response.success){
    //             attachId = response.peakResults[0].contentID;
    //             // update the start position with end position
    //             startPosition = endPosition;
    //             var chunkSize = component.get('v.chunkSize');
    //             endPosition = Math.min(fileContents.length, startPosition + chunkSize);
    //             // check if the start postion is still less then end postion
    //             // then call again 'uploadInChunk' method ,
    //             // else, display alert msg and hide the loading spinner
    //             if (startPosition < endPosition) {
    //                 self.uploadInChunk(component, event, helper, parentId, file, fileContents, startPosition, endPosition, files,  curList, index, attachId);
    //             } else {
    //                 // This information could be used to create a file upload progress tracker
    //                 // console.log('File Name ===== ' + file.name);
    //                 // console.log('File Size ===== ' + fileContents.length);
    //                 // console.log('File Progress Byte ===== ' + endPosition);
    //                 // console.log('File Progress ===== ' + '100%');
    //                 helper.sendAttachment(component, event, helper,attachId,parentId);
    //                 index++;
    //                 self.saveFiles(component, event, helper, parentId, curList, index, files);
    //             }
    //         } else {
    //             console.log('Error: ', response.messages[0]);
    //             helper.showMessage('error', response.messages[0]);
    //         }
    //     });
    // },
    //
    // sendAttachment: function(component, event, helper, name, parentId) {
    //
    //     var params = {
    //         fileName: name,
    //         parentId: parentId
    //     };
    //
    //     helper.doCallout(component,'c.sendAttachment',params).then(function(response){
    //         if (response.success){
    //             console.log('Success');
    //         } else {
    //             console.log('Error: ', response.messages[0]);
    //         }
    //     });
    // },
    //
    // clientSend: function(component, event, helper, curList, enrollmentComponentAffiliationId, enrollmentDocumentId,isOnRecordPage) {
    //     console.log('SSO Token');
    //     console.log(component.get('v.ssoToken'));
    //     // var xhr = new XMLHttpRequest();
    //     // var url = component.get('v.clientUploadEndpoint');
    //     // xhr.open("POST", url, true);
    //     // xhr.setRequestHeader("x-ctx-currentapplication","enrollment");
    //     // //xhr.setRequestHeader("x-ctx-authentication", "AQIC5wM2LY4Sfcz9_LpMfohPHpP_FAIxUULTVPXMSYh6uZ8.*AAJTSQACMDIAAlNLABQtMjMzODEyNDk5NTQyMzg3MjAzNQACUzEAAjA3*");
    //     // xhr.setRequestHeader("x-ctx-authentication", component.get("v.ssoToken"));
    //     // xhr.setRequestHeader("x-ctx-locationid", "123");
    //     // xhr.setRequestHeader("Cache-Control", "no-cache");
    //
    //     var fileIdList = [];
    //     var uploadCount = 0;
    //
    //     curList.forEach(function(file, index) {
    //
    //
    //         var xhr = new XMLHttpRequest();
    //         var url = component.get('v.clientUploadEndpoint');
    //         xhr.open("POST", url, true);
    //         xhr.setRequestHeader("x-ctx-currentapplication","enrollment");
    //         //xhr.setRequestHeader("x-ctx-authentication", "AQIC5wM2LY4Sfcz9_LpMfohPHpP_FAIxUULTVPXMSYh6uZ8.*AAJTSQACMDIAAlNLABQtMjMzODEyNDk5NTQyMzg3MjAzNQACUzEAAjA3*");
    //         xhr.setRequestHeader("x-ctx-authentication", component.get("v.ssoToken"));
    //         xhr.setRequestHeader("x-ctx-locationid", "123");
    //         xhr.setRequestHeader("Cache-Control", "no-cache");
    //
    //         var fdata = new FormData();
    //         fdata.append("documenttype", "enrollment");
    //
    //         if (file.type == "From Camera") {
    //             fdata.append("file", file.data, "cameraCapture.png");
    //             xhr.send(fdata);
    //         } else {
    //             fdata.append("file", file);
    //             xhr.send(fdata);
    //
    //         }
    //
    //         //Ready State function
    //         xhr.onreadystatechange = function () {
    //             if(xhr.readyState === 4){
    //                 var responseString = JSON.parse(xhr.responseText);
    //                 var fileId = responseString.file.fileId;
    //
    //                 component.set('v.fileId', fileId);
    //                 component.set('v.showList', true);
    //
    //                 //Check if we've uploaded all the files in the list -- if we have, callout to Apex to create Enrollment Doc
    //                 if (uploadCount === (curList.length - 1)) {
    //                     fileIdList.push(fileId);
    //                     helper.doCreateEnrollmentDocument(component, event, helper, fileIdList, enrollmentComponentAffiliationId, enrollmentDocumentId, isOnRecordPage);
    //
    //                 } else {
    //                     console.log(fileId);
    //                     uploadCount++;
    //                     fileIdList.push(fileId);
    //                 }
    //                 component.set('v.isLoading', false);
    //             }
    //         };
    //
    //     });
    // },
    //
    // doCreateEnrollmentDocument : function (component,event,helper, fileIdList, enrollmentComponentAffiliationId, enrollmentDocumentId, isOnRecordPage) {
    //
    //     var params = {
    //         enrollmentComponentAffiliationId: enrollmentComponentAffiliationId,
    //         enrollmentDocumentId: enrollmentDocumentId,
    //         documentLink: fileIdList
    //     };
    //
    //     helper.doCallout(component,'c.createEnrollmentDocuments',params).then(function(response){
    //         if (response.success){
    //             helper.showMessage('success', 'File Uploaded Successfully');
    //             if(isOnRecordPage){
    //                 // Close the action panel
    //                 var dismissActionPanel = $A.get("e.force:closeQuickAction");
    //                 dismissActionPanel.fire();
    //             }else{
    //                 window.history.back();
    //                 // @todo bug #69327 - need to implement the following behavior:
    //                 // If accessing the doc uploader tool from a form, user should be taken back to the view they came from.
    //                 // If this is the last item to complete on a form, take the user to the next available form.
    //                 // If accessing the doc uploader tool from Doc Central, user is taken back to the Dashboard view.
    //
    //                 // helper.goToUrl("/");
    //             }
    //         } else {
    //             console.log('Error: ', response.messages[0]);
    //         }
    //     });
    //
    // }

    // downloadDocument : function(component, event, helper,fileName){
    //     var fileDownload = component.get('v.fileLocation');
    //     var url = component.get('v.clientUploadEndpoint');
    //     var urlGet =  url + '/' + fileDownload ;
    //     var xhttp = new XMLHttpRequest();
    //     xhttp.onreadystatechange = function() {
    //         if (this.readyState == 4 && this.status == 200) {
    //             //console.log('downloadUrl',downloadUrl);
    //             var link=document.createElement('a');
    //
    //             url = window.URL.createObjectURL(window.Blob(xhttp.response));
    //             link.href=url;
    //             link.download=fileName;
    //             link.click();
    //         }
    //     };
    //     xhttp.open("GET", urlGet, true);
    //     xhttp.responseType = "blob";
    //     xhttp.setRequestHeader("x-ctx-authentication", "AQIC5wM2LY4SfczbnEPc6se4225nUPMij1y_CtLWMHusKsI.*AAJTSQACMDIAAlNLABQtNTU3NjgxMzgxNDU0MzgzNjYzOAACUzEAAjA5*");
    //     xhttp.setRequestHeader("x-ctx-currentapplication","enrollment");
    //     xhttp.send();
    //
    // },
});