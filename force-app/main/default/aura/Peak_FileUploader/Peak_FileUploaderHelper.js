/*
 * Created by 7Summits - Joe Callin on 3/17/18.
 * 2019-10-04 added token cache #US109799/fixed #BUG112429  (Mark Membrino)
*/
({
    initUploader: function(component, event, helper) {

        console.log('INSIDE INIT');

        window.addEventListener("beforeunload", function(e){
            var fileList = component.get('v.curList');
            if(fileList && fileList.length > 0) {
                e.returnValue = '';
                e.preventDefault();
            }
        });

		//Mark Membrino 9/30/2019  Save time when document loading by caching the token and keeping it for x minutes
		//that is defined by the custom label NES_DocTokenTimeoutMinutes
		var tokenExpiration = component.get("v.docTokenTimeout");
		var storedToken = JSON.parse(sessionStorage.getItem("documentTokenData"));
		if (!storedToken || !helper.isValidToken(storedToken, tokenExpiration)) {
			console.log('new token');
			var now = new Date();
			var postMessagePartner = $A.get("$Label.c.NES_DocumentURL");
			
			component.find('pearsonauth').getElement().contentWindow.postMessage({ messageType: 'sendCookie' }, postMessagePartner);

			window.addEventListener("message", function(event) {
				if ((event.origin === postMessagePartner) && (event.data.messageType === 'sendCookie' )) {
					console.log("User is authenticated.");
					var token = event.data.token;
					component.set("v.ssoToken", token);
					if (token) {  
						//Don't save it to cache if it is not returned.      
						var data = { token: token, date: now.toString() };
						sessionStorage.setItem("documentTokenData", JSON.stringify(data));
					}
				}
			}, false);
		} else
		{
			console.log("User is authenticated with existing token.", storedToken.token);
			component.set("v.ssoToken", storedToken.token); 
		}

        helper.getEnrollmentComponentAffiliation(component,event,helper);

        helper.setLabels(component, component.get('v.attributesToConvert'));

        var fileInfo = {};
        var maxBytes = 104857600;
        fileInfo.maxSize = maxBytes;
        var count = -1;
        do {
            maxBytes = maxBytes / 1024;
            count += 1;
        }
        while (maxBytes > 1024);
        fileInfo.maxFileSize = Math.round(10*maxBytes)/10 + ' ' + component.get('v.sizeAbbr')[count];

        console.log('MAX FILE SIZE ====== ' + fileInfo.maxFileSize);

        fileInfo.prettyExtensions = component.get('v.allTypesText');
        fileInfo.extensions = [];
        fileInfo.fullExtensionList = [];

        component.set('v.fileInfo', fileInfo);
        component.set('v.isLoading', false);
        component.set('v.uploaderInit', true);
    },

    stageFiles: function(component, files)
    {
      component.set("v.stagedFiles", files);
    },
    //Setting the file list aka finding out which ones will be uploaded and which ones will be rejected due to an error
    setFileList: function(component, event, helper) {
        component.set('v.isLoading', true);
        var fileInput = event.getSource().get('v.files');
        var validList = component.get('v.validList') ? component.get('v.validList') : [];
        var invalidList = component.get('v.invalidList');
        var fileInfo = component.get('v.fileInfo');
        var inForm = component.get('v.inForm');
        var uploadList = component.get('v.uploadList');

        var curList = component.get("v.curList") ? component.get("v.curList") : [];
        //Walking through the files that were uploaded from the file uploader

        for (var i = 0; i < fileInput.length; i++) {
            var curFile = fileInput[i];
            var filename = curFile.name;
            curFile.ext = filename.substr((~-filename.lastIndexOf('.') >>> 0) + 2);

            var curSize = curFile.size;

            console.log('CURR FILE SIZE ======' + curSize);

            var count = -1;
            //Getting the current uploaded file size and converting so a 2MB doesn't display as 2097152 bytes on the component
            do {
                curSize = curSize / 1024;
                count += 1;
            }
            while (curSize > 1024);
            curFile.formattedSize = Math.round(10*curSize)/10 + ' ' + component.get('v.sizeAbbr')[count];

            console.log('CUR FILE FORMATTED SIZE =====' + curFile.formattedSize);

            var allowedExtensions = component.get('v.ecAllowedFileFormats');
            //Checking if the current file is an accepted file type. If not we are setting an error and adding it to the rejected file list
            if(allowedExtensions.indexOf(curFile.ext.toLowerCase()) === -1 && !$A.util.isEmpty(allowedExtensions)){
                curFile.errorMessage = ' ' + allowedExtensions;
                curFile.errorType = 'extension';
                curFile.valid = false;
                invalidList.push(curFile);
                //Checking if the current file size less then the allowed max file size. If not we are setting an error and adding it to the rejected file list
            }else if(curFile.size > fileInfo.maxSize){
                curFile.errorMessage = ' ' + fileInfo.maxFileSize;
                curFile.errorType = 'size';
                curFile.valid = false;
                invalidList.push(curFile);
            }else{
                //If no error add the to the accepted file list and clearn out the invalidList so they don't continue to see a message about a bad upload
                curFile.errorType = null;
                curFile.valid = true;
                validList.push(curFile);
                invalidList = [];
                //File uploader in a form add the file to the upload list to be uploaded later, else will add it to the file list to be uploaded right away
                if(inForm){
                    uploadList.push(curFile);
                }else{
                    curList.push(curFile);
                }
            }
        }


        if(uploadList.length > 0){
            this.fireSetFileListEvent(component, uploadList);
        }
        console.log('validList: ' + validList);
        component.set('v.validList', validList);
        component.set('v.invalidList', invalidList);
        component.set('v.curList', curList);
        component.set('v.isLoading', false);
        component.set('v.showList', true);

    },
    //This will remove the file from the file list that is displayed on the component
    removeFromList: function(component, event, name, valid) {


        console.log('INSIDE REMOVE');

        var inForm = component.get('v.inForm');
        var listName = valid === 'true' ? 'valid' : 'invalid';
        var list = component.get('v.' + listName + 'List');
        if($A.util.isUndefinedOrNull(name)){
            name = event.currentTarget.dataset.name;
        }
        for(var i = 0; i < list.length; i++){
            if(list[i].name === name){
                list.splice(i, 1);
            }
        }

        if(inForm){
            var uploadList = component.get('v.uploadList');
            for(var u = 0; u < uploadList.length; u++){
                if(uploadList[u].name === name){
                    uploadList.splice(u, 1);
                }
            }
            this.fireSetFileListEvent(component, uploadList);
        }

        var listCopy = [];

        list.forEach(function(item){
            listCopy.push(item);
        });

        component.set('v.' + listName + 'List', listCopy);

        console.log(listCopy);

        if(listName === 'valid') {
            component.set("v.curList", listCopy.length == 0 ? null : list);
        }
    },
    fireSetFileListEvent : function(component, fileList) {
        var setFileList = component.getEvent('setFileList');
        setFileList.setParams({
            fileList : fileList
        });
        setFileList.fire();
    },
    openCamera: function(component, event, helper){
        component.set('v.cameraActive',true);
        var video = component.find("video").getElement();
        // Get access to the camera!
        if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
            component.set('v.cameraOpen',true);
            component.set('v.cameraBlocked', false);
            navigator.mediaDevices.getUserMedia({video: { width: {exact: 640}, height: {exact: 480} }}).then($A.getCallback(function (stream) {
                video.srcObject = stream;
                video.play();
                component.set('v.stream', stream);
                    var video2 = component.find("video").getElement();
                    window.setTimeout($A.getCallback(function(){
                        component.set('v.canvasWidth', video2.videoWidth);
                        component.set('v.canvasHeight', video2.videoHeight);
                    }), 1000);
            })).catch(function(err){
                console.error('Canceled stream request');
                component.set('v.cameraOpen',false);
                component.set('v.cameraBlocked', true);
            });
        }
    },
    cancelImage:function(component, event, helper) {
        component.get('v.stream').getTracks()[0].stop();
        component.set('v.cameraOpen',false);
    },
    drawImage:function(component, event, helper){
        // Elements for taking the snapshot

        component.find("video").getElement().pause();
        component.set("v.imageCaptured", true);
        component.set("v.cameraActive", false);
        var video = component.find("video").getElement();
        var canvas = document.getElementById('canvas');
        var context = canvas.getContext('2d');
        context.drawImage(video, 0, 0, video.width, video.height);

    },
    addCameraShotToList: function(component, event, helper) {
        component.set("v.cameraActive",false);
        component.set("v.cameraOpen",false);
        component.set("v.imageCaptured",false);
        component.find("video").getElement().srcObject = null;

        helper.cancelImage(component,event,helper);

        var canvas = document.getElementById('canvas');
        var url =canvas.toDataURL();

        canvas.toBlob($A.getCallback(function(blob){
            var validList = component.get('v.validList');
            var curList = component.get("v.curList") ? component.get("v.curList") : [];

            var image = {name: "Snapped Photo", data: blob, type:"From Camera", valid: true};

            curList.push(image);
            validList.push(image);

            component.set('v.validList', validList);
            component.set('v.curList', curList);
            component.set('v.showList', true);
        }));

    },
    retakePhoto: function(component, event, helper) {
        component.set("v.imageCaptured",false);
        component.set("v.cameraActive",true);
        component.find("video").getElement().play();
    },
    goBack: function(component, event, helper) {
        var processId = component.get("v.processId");
        var programEnrollmentId = component.get("v.programEnrollmentId");
        var caretakerId = component.get("v.caretakerId");
        var studentGrade = component.get("v.studentGrade");
        var studentId = component.get("v.studentId");

        var url = '';

        if(!$A.util.isEmpty(studentId)) {
            url =$A.get("$Label.c.NES_Community_Stem_Url")+'/enrollment?studentId=' + encodeURIComponent(studentId) + '&caretakerId=' + encodeURIComponent(caretakerId) + '&processId=' + encodeURIComponent(processId) + '&programEnrollmentId=' + encodeURIComponent(programEnrollmentId) + '&studentGrade=' + encodeURIComponent(studentGrade);
        } else {
            url = '/dashboard';
        }
        var event = $A.get("e.force:navigateToURL");
        event.setParams({
            "url": url
        });
        event.fire();
    },
    goToNextSectionOrOverview: function (component, event, helper) {
        var eca = component.get("v.enrollmentComponentAffiliationId");
        var processId = component.get("v.processId");
        var programEnrollmentId = component.get("v.programEnrollmentId");
        var studentName = component.get("v.studentName");
        var studentGrade = component.get("v.studentGrade");
        var studentId = component.get("v.studentId");

        var url = "";

        if(studentId == null || studentId === ""){
            console.log('Null student id');
            url = $A.get("$Label.c.NES_Community_Stem_Url");
            helper.goBack(component, event, helper);
            return;
        } else {
            console.log('setting params');
            var params = {
                programEnrollmentId: programEnrollmentId,
                ecaId: eca,
                processId: processId
            };
            console.log('Preparing callout');
            helper.doCallout(component, 'c.grabURLredirect', params).then(function (response) {
                console.log('in callout of graburlredirect');
                if (response.success) { 
                    console.log(response);
                    console.log('redirect successful');
                    url = response.messages[0];
                    var event = $A.get("e.force:navigateToURL");
                    console.log(event);
                    console.log(url);
                    event.setParams({
                        "url": url
                    });
                    event.fire();
                } else {
                    console.log(JSON.parse(JSON.stringify(response)))
                    console.log(response.message);
                    url = $A.get("$Label.c.NES_Community_Stem_Url")+'/enrollment?studentId=' + encodeURIComponent(studentId) + '&studentName=' + encodeURIComponent(studentName) + '&processId=' + encodeURIComponent(processId) + '&programEnrollmentId=' + encodeURIComponent(programEnrollmentId) + '&studentGrade=' + encodeURIComponent(studentGrade);
                    var event = $A.get("e.force:navigateToURL");
                    event.setParams({
                        "url": url
                    });
                    event.fire();
                }
            });
        }
    },

    getEnrollmentComponentAffiliation: function (component, event, helper) {

        var params = {
            enrollmentComponentAffiliationId : component.get('v.enrollmentComponentAffiliationId'),
            enrollmentDocumentId : component.get('v.enrollmentDocumentId')
        };

        //Get the ECA to get the allowed File Types
        helper.doCallout(component, 'c.getECA', params).then(function(response){
            if(response.success) {
                if(!$A.util.isUndefinedOrNull(response.results[0])) {

                    if(!$A.util.isUndefinedOrNull(response.results[0].Program_Enrollment__r.hed__Contact__r) && !$A.util.isUndefinedOrNull(response.results[0].Program_Enrollment__r.hed__Contact__r.AccountId)) {
                        component.set('v.householdId', response.results[0].Program_Enrollment__r.hed__Contact__r.AccountId);
                    }

                    var extensionList = response.results[0].Enrollment_Component__r.Document_File_Formats__c;

                    if (!$A.util.isUndefinedOrNull(extensionList)) {
                        var extensions = extensionList.replace(/;/g, ', ');
                        component.set('v.ecAllowedFileFormats', extensions);
                        if(extensions.includes('.png')) {
                            component.set('v.allowsPhotos', true);
                            component.set('v.mobileUploadTitle', 'Upload Files or Take a Picture');
                        }
                    } else {
                        //.doc,.docx,.gif,.jpeg,.jpg,.pdf,.png,.tif,.txt
                        component.set('v.allowsPhotos',true);
                        component.set('v.mobileUploadTitle', 'Upload Files or Take a Picture');
                    }
                }

            }else{
                console.log('Error: ', response.messages[0]);
                //helper.showMessage('error', response.messages[0]);
            }
        });
    },




    saveFiles: function(component, event, helper, parentId, curList,enrollmentComponentAffiliationId, enrollmentDocumentId,isOnRecordPage, index, files) {
		var self = this;
        var base64 = 'base64,';
        if(index === undefined){
            index = 0;
        }
        if(files === undefined){
            files = [];
        }
        if (component.get('v.useClientUpload')) {
            self.clientSend(component, event, helper, curList, enrollmentComponentAffiliationId, enrollmentDocumentId,isOnRecordPage);
        } else {
            if (curList.length > 0 && index < curList.length) {
                getBase64(curList[index], index, files);
            } else if (index === curList.length) {

                var uploadMessage = component.get('v.uploadMessage');
                if ($A.util.isUndefinedOrNull(uploadMessage) && $A.util.isEmpty(uploadMessage)) {
                    self.showMessage('success', (curList.length > 1 ? 'Files uploaded successfully' : 'File uploaded successfully'));
                } else {
                    self.showMessage('success', uploadMessage);
                }

                component.set('v.isLoading', false);
                component.set('v.showList', true);
            }
        }
        function getBase64(file, index, files) {
            var reader = new FileReader();
            reader.readAsDataURL(file);
            reader.onload = $A.getCallback(function () {
                var fileContents = reader.result;
                var dataStart = fileContents.indexOf(base64) + base64.length;
                var chunkSize = component.get('v.chunkSize');
                fileContents = fileContents.substring(dataStart);
                // set a default size or startpostiton as 0
                var startPosition = 0;
                // calculate the end size or endPostion using Math.min() function which is return the min. value

                var endPosition = Math.min(fileContents.length, startPosition + chunkSize);
                self.uploadInChunk(component, event, helper, parentId, file, fileContents, startPosition, endPosition, files, curList, index, '');

            });
            reader.onerror = function (error) {
                helper.showMessage('error', error);
                console.log('Error: ', error);
            };
        }
    },
    uploadInChunk: function(component, event, helper, parentId, file, fileContents, startPosition, endPosition, files, curList, index, attachId) {
        var self = this;
        // This information could be used to create a file upload progress tracker
        // console.log('File Name ===== ' + file.name);
        // console.log('File Size ===== ' + fileContents.length);
        // console.log('File Progress Byte ===== ' + startPosition);
        // console.log('File Progress ===== ' + Math.round(startPosition/fileContents.length*100) + '%');
        var getchunk = fileContents.substring(startPosition, endPosition);
        var params = {
            parentId: parentId,
            fileName: file.name,
            base64Data: encodeURIComponent(getchunk),
            contentType: file.type,
            fileId: attachId
        };
        helper.doCallout(component,'c.saveChunk',params).then(function(response){
            if (response.success){
                attachId = response.peakResults[0].contentID;
                // update the start position with end position
                startPosition = endPosition;
                var chunkSize = component.get('v.chunkSize');
                endPosition = Math.min(fileContents.length, startPosition + chunkSize);
                // check if the start postion is still less then end postion
                // then call again 'uploadInChunk' method ,
                // else, display alert msg and hide the loading spinner
                if (startPosition < endPosition) {
                    self.uploadInChunk(component, event, helper, parentId, file, fileContents, startPosition, endPosition, files,  curList, index, attachId);
                } else {
                    // This information could be used to create a file upload progress tracker
                    // console.log('File Name ===== ' + file.name);
                    // console.log('File Size ===== ' + fileContents.length);
                    // console.log('File Progress Byte ===== ' + endPosition);
                    // console.log('File Progress ===== ' + '100%');
                    helper.sendAttachment(component, event, helper,attachId,parentId);
                    index++;
                    self.saveFiles(component, event, helper, parentId, curList, index, files);
                }
            } else {
                console.log('Error: ', response.messages[0]);
                helper.showMessage('error', response.messages[0]);
            }
        });
    },

    sendAttachment: function(component, event, helper, name, parentId) {

        var params = {
            fileName: name,
            parentId: parentId
        };

        helper.doCallout(component,'c.sendAttachment',params).then(function(response){
            if (response.success){
                console.log('Success');
            } else {
                console.log('Error: ', response.messages[0]);
            }
        });
    },

    clientSend: function(component, event, helper, curList, enrollmentComponentAffiliationId, enrollmentDocumentId,isOnRecordPage) {
        console.log('SSO Token');
        console.log(component.get('v.ssoToken'));

        var fileIdList = [];
        var uploadCount = 0;

        curList.forEach(function(file, index) {


            var xhr = new XMLHttpRequest();
            var url = $A.get("$Label.c.NES_FileUploadEndpoint");
            xhr.open("POST", url, true);
            xhr.setRequestHeader("x-ctx-currentapplication","enrollment");
            xhr.setRequestHeader("x-ctx-authentication", component.get("v.ssoToken"));
			var houseHold = component.get("v.householdId");	
			if (houseHold)  //Make sure it is defined.
				xhr.setRequestHeader("x-ctx-locationid", houseHold.toString() );
            xhr.setRequestHeader("Cache-Control", "no-cache");

            var fdata = new FormData();
            fdata.append("documenttype", "enrollment");

            if(!component.get('v.isOnRecordPage')) {
                fdata.append('uploadByUserId', component.get('v.currentUser.FederationIdentifier'));
            }


            if (file.type == "From Camera") {
                fdata.append("file", file.data, "cameraCapture.png");
                xhr.send(fdata);
            } else {
                fdata.append("file", file);
                xhr.send(fdata);

            }

            //Ready State function
            xhr.onreadystatechange = function () {

                console.log('xhr status');
                console.log(xhr.status);
                       xhr.status  = '201';//added by anitha
                console.log('staus'+xhr.status );
                if(xhr.readyState ===4) {

                    if (xhr.status === 201) {

                        var responseString = JSON.parse(xhr.responseText);
                        var fileId = responseString.file.fileId;

                        //component.set('v.fileId', fileId);
                        component.set('v.showList', true);

                        //Check if we've uploaded all the files in the list -- if we have, callout to Apex to create Enrollment Doc
                        if (uploadCount === (curList.length - 1)) {
                            fileIdList.push(fileId);
                            helper.doCreateEnrollmentDocument(component, event, helper, fileIdList, enrollmentComponentAffiliationId, enrollmentDocumentId, isOnRecordPage);

                        } else {
                            console.log(fileId);
                            uploadCount++;
                            fileIdList.push(fileId);
                        }
                    }else{
                        console.log('ERROR' + xhr.response);
                        //helper.showMessage('Error', 'Failed to upload document');
                        //Mohammad : Added Code for Error Message, If filename contains special characters, this message will populate,
                        // "Error File name contains invalid characters"
                        var responseString = xhr.response;
                        responseString = responseString.toLowerCase();
                        if(responseString.indexOf("illegal") > -1){
                        	helper.showMessage('Error', 'File name contains Invalid Characters');
                        }else{
                        	helper.showMessage('Error', 'Failed to upload document');
                        }
                        component.set('v.isLoading', false);
                    }

                }
            };
        });
    },

    doCreateEnrollmentDocument : function (component,event,helper, fileIdList, enrollmentComponentAffiliationId, enrollmentDocumentId, isOnRecordPage) {

        var params = {
            enrollmentComponentAffiliationId: enrollmentComponentAffiliationId,
            enrollmentDocumentId: enrollmentDocumentId,
            documentLink: fileIdList
        };
        

        helper.doCallout(component, 'c.createEnrollmentDocuments', params).then(function(response){
            if (response.success){
                helper.showMessage('success', 'File Uploaded Successfully');
                if(isOnRecordPage){
                    component.set("v.curList",null);
                    // Close the action panel
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                }else{
                    component.set("v.curList",null);
                    helper.goToNextSectionOrOverview(component,event,helper);
                }

            } else {
                helper.showMessage('error',response.messages[0]);
                console.log('Error: ', response.messages[0]);
            }
        }).catch(function (response) {
            console.log(response.message);
        }).finally(function(){
            component.set('v.isLoading', false);

        });
    },
	isValidToken: function(data, tokenExpiration) {
		var today = new Date();
		var dif = today - new Date(data.date);
		dif = ((dif % 86400000) % 3600000) / 60000;
		console.log(dif);
		return dif < tokenExpiration;
	},
   
   //Swapna:For GTM
    getformName: function(component, event, helper,skpRsbmt) {
            var action = component.get("c.getformName");
            action.setParams({
            enrollmentComponentAffiliationId: component.get('v.enrollmentComponentAffiliationId')
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
         appEvent.setParams({"SectionName":component.get("v.documentInfo.documentName")}); 
       	 appEvent.setParams({"studentId":component.get("v.studentId")}); 
         appEvent.setParams({"careTakerId":component.get("v.caretakerId")}); 
         appEvent.setParams({"timeStamp":today}); 
         appEvent.fire();
    }
})