/**
 * Change Log:
 * 2019-01-02 Created by melindagrad
 * 2019-08-14 Updated download logic to retrieve Account Id from PE US #101928 (Andrew Sim) 
 */
({
    initFileDownload : function (component, event, helper) {
        
        //Mark Membrino 9/30/2019  Save time when document loading by caching the token and keeping it for x minutes
        //that is defined by the custom label NES_DocTokenTimeoutMinutes
        var tokenExpiration = component.get("v.docTokenTimeout");
        var storedToken = JSON.parse(sessionStorage.getItem("documentTokenData"));
        
        if (!storedToken || !helper.isValidToken(storedToken, tokenExpiration)) {
            var postMessagePartner = component.get("v.postmessage");
            component.find('pearsonauth').getElement().contentWindow.postMessage({ messageType: 'sendCookie' }, postMessagePartner);
            
            var eventFunction = function(messageEvent) {
                if ((messageEvent.origin === postMessagePartner) && (messageEvent.data.messageType === 'sendCookie')) {
                    var token = messageEvent.data.token;
                    component.set("v.ssoToken", token);
                    window.removeEventListener("message", eventFunction);
                    if (token) {  
                        //Don't save it to cache if it is not returned.      
                        data = { token: token, date: now.toString() };
                        sessionStorage.setItem("documentTokenData", JSON.stringify(data));
                    }
                    
                    helper.downloadDocument(component, event, helper);
                }
            };
            
            window.addEventListener("message", eventFunction);
        } else
        {
            console.log("Found existing token", storedToken.token);
            component.set("v.ssoToken", storedToken.token); 
            helper.downloadDocument(component, event, helper);
        }
        
        component.set('v.downloaderInit', true);
    },
    
    isValidToken: function(data, tokenExpiration) {
        var today = new Date();
        var dif = today - new Date(data.date);
        dif = ((dif % 86400000) % 3600000) / 60000;
        console.log(dif);
        return dif < tokenExpiration;
    },
    
    downloadDocument : function(component, event, helper){
        
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
        
        component.set('v.isLoading', false);
        
        //console.log('The householdID is: ' + component.get('v.simpleRecord.Enrollment_Document__r.Uploader__r.Contact.Household_Id__c'));
        //console.log('The AccountID is: ' + component.get('v.simpleRecord.Enrollment_Document__r.Program_Enrollment_AccountId__c'));
        var householdID = component.get('v.simpleRecord.Enrollment_Document__r.Uploader__r.Contact.Household_Id__c');
        // updated line for US #
        var accountID = component.get('v.simpleRecord.Enrollment_Document__r.Program_Enrollment_AccountId__c');
        
        var url = $A.get("$Label.c.NES_FileUploadEndpoint");
        var urlGet =  url + "/" + component.get('v.simpleRecord.File_Path__c');
        
        var fileName;
        
        if(urlGet){
            fileName = urlGet.substring(urlGet.lastIndexOf('/') + 1, urlGet.length);
        }
        
        var xhttp = new XMLHttpRequest();
        
        xhttp.open("GET", urlGet, true);
        xhttp.responseType = 'blob';
        xhttp.setRequestHeader("x-ctx-currentapplication","enrollment");
        xhttp.setRequestHeader("x-ctx-authentication", component.get('v.ssoToken'));
        xhttp.setRequestHeader("x-ctx-locationid", accountID);
        
        console.log('SENDING REQUEST ====');
        
        xhttp.send();
        
        xhttp.onreadystatechange = function() {
            
            if(xhttp.response != null){  //Added :Begin for the BUG213843 by Jagadeesh.
                
                if (xhttp.status === 200 && xhttp.readyState === 4) {
                    
                    try{ 
                        var link=document.createElement('a');
                        //Added :Begin for the BUG213843 by Jagadeesh.
                        //Description::Due to locker service window.Blob(xhttp.response) Is not accepting as parameter
                        //so built a blob,added to file variable & passed to URL.
                        var file = new Blob([xhttp.response]);
                        link.href = window.URL.createObjectURL(file);
                        //Added :End for the BUG213843 by Jagadeesh.
                        link.download = fileName;
                        link.click();
                        component.destroy();
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
})