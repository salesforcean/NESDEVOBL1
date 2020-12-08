/*
 * 2019-10-04 added token cache #US109799/fixed #BUG112429  (Mark Membrino)
 */
({
    getUtilitySettings: function(component, event) {
        console.log('getUtilitySettings');
        var action = component.get("c.getUtilitySettings");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.utilitySettings", result);
                component.set("v.downloadDocument", result.Document_Download__c);
                console.log(result);
            }
        });
        
        $A.enqueueAction(action);        
    },
    
    getDocList: function(component, event) {
        console.log('getDocList');
        var recordId = component.get("v.recordId");
        var action = component.get('c.getDocList');
        action.setParams({
            'enrollmentDocumentId': recordId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.docList", result);
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
    
    handleIframeLoaded: function (component, event) {
        
        //Mark Membrino 9/30/2019  Save time when document loading by caching the token and keeping it for x minutes
        //that is defined by the custom label NES_DocTokenTimeoutMinutes
        var tokenExpiration = component.get("v.docTokenTimeout");
        var storedToken = JSON.parse(sessionStorage.getItem("documentTokenData"));
        var self = this;
        
        if (!storedToken || !self.isValidToken(storedToken, tokenExpiration)) {
            console.log('new token');
            var now = new Date();
            var authURL = component.get("v.authURL");
            component.find('authiframe').getElement().contentWindow.postMessage({ messageType: 'sendCookie' }, authURL);
            
            // obtain authorization token 
            window.addEventListener("message", function _listener(messageEvent) {
                //console.log('EVENT ======');
                //console.log(messageEvent);
                if ((messageEvent.origin===authURL) && (messageEvent.data.messageType==='sendCookie')) {
                    console.log("User is authenticated.");
                    var token = messageEvent.data.token;
                    component.set("v.authToken", token);
                    window.removeEventListener("message", _listener);
                    if (token) {  
                        //Don't save it to cache if it is not returned.      
                        var data = { token: token, date: now.toString() };
                        sessionStorage.setItem("documentTokenData", JSON.stringify(data));
                    }
                }
            });
        } else
        {
            console.log("Found existing token", storedToken.token);
            component.set("v.authToken", storedToken.token); 
        }
        // component.set('v.authReady', true);
        
    },
    
    isValidToken: function(data, tokenExpiration) {
        var today = new Date();
        var dif = today - new Date(data.date);
        dif = ((dif % 86400000) % 3600000) / 60000;
        console.log(dif);
        return dif < tokenExpiration;
    },
    
    handleViewClick: function (component, event) {
        var dfrId = event.getSource().get("v.name");
        //console.log('handleViewClick: ' + dfrId);
        if (dfrId) {
            // open vf page to view
            window.open("/apex/NES_DocumentFileRefViewer?c__dfrId=" + dfrId, '_2', 'menubar=no,toolbar=no,location=no,status=no,resizeable=no,scrollbars=no');
        }
    },
    
    handleDownloadClick: function(component, event) {
        var urlEndpoint = $A.get("$Label.c.NES_FileUploadEndpoint");
        var url =  urlEndpoint + "/" + event.getSource().get("v.name");
        console.log('handleDownloadClick: ' + url);
        if (url) {
            console.log('url: ' + url);
            var fileName = url.substring(url.lastIndexOf('/') + 1, url.length);
            var xhttp = new XMLHttpRequest();
            var accountId = component.get('v.enrollment_document.Program_Enrollment_AccountId__c');
            console.log('accountId: ' + accountId);
            
            // retrieve the document from docustore
            xhttp.open("GET", url, true);
            xhttp.responseType = 'blob';
            xhttp.setRequestHeader("x-ctx-currentapplication","enrollment");
            xhttp.setRequestHeader("x-ctx-authentication", component.get('v.authToken'));
            xhttp.setRequestHeader("x-ctx-locationid", accountId);
            xhttp.send();
            
            xhttp.onreadystatechange = function() {      
                // when http GET is finished download the file
                
                if(xhttp.response != null){ //Added :Begin for the BUG213843 by Jagadeesh.
                    
                    if (xhttp.status === 200 && xhttp.readyState === 4) { 
                        try{
                            
                            var link=document.createElement('a');
                            //Added :Begin for the BUG213843 by Jagadeesh.
                            //Description::Due to locker service window.Blob(xhttp.response) Is not accepting as parameter
                            //so built a blob,added to file variable & passed to URL.
                            var file = new Blob([xhttp.response]);
                            link.href = window.URL.createObjectURL(file);
                            //Added :End for the BUG213843 by Jagadeesh.
                            link.target = "_blank";
                            link.download = fileName;
                            link.click();
                        }
                        catch(err){
                            alert("Error occured while downloading...Please contact Administrator");
                        }
                    }  
                    //Added :Begin for the BUG213843 by Jagadeesh.
                    else {
                        alert ("Error occurred while downloading (Error code : "+ xhttp.status +").Please contact Administrator");
                        console.log("Error code : "+xhttp.status);
                    }
                    //Added :End for the BUG213843 by Jagadeesh.
                }
                
            };
            
        }   
    }
    
})