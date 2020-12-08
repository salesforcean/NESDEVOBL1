({
	handleInit : function(component) {
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var params = {
            'caretakerId' : userId
        };
        var fetchDocumentsList = this.doCallout(component, 'c.getDocumentsList', params);
        fetchDocumentsList.then(result =>
        {
            console.log("Documents List", JSON.parse(result));
            component.set("v.isLoaded",true);
            if(result) {
                var document = JSON.parse(result);
            console.log('The document values are:',document);
                component.set("v.centralDocument",document);
                var documentNeedsAttention = [];
                var documentAccepted = [];
                var documentUnderReview = [];
            	var documentDeferred = [];/***** Modified 5/15/2020 by Vani User Story #171693*****/
                // Start add by Maddileti for User Story #102169 (Maddileti Boya) on 2019-09-09
                var documentNotSubmitted=[];
                var doc = document.mapOfEnrollmentDocuments;
               // var docEca = document.ecaListStatus;
            var docEca = document.ecaListStatusNotStarted; //Swapna:For US:181069
               documentNotSubmitted = docEca;
                  // End add by Maddileti for User Story #102169 (Maddileti Boya) on 2019-09-09
               for(var key in doc){
                    if(key==='Needs Attention'){
                        for(var item in doc[key]){
                            doc[key][item]["Status__c"] = "Needs Attention";
                        }
                        documentNeedsAttention=doc[key];
                    } 
                    if(key==='Under Review'){
                        for(var item in doc[key]){
                            doc[key][item]["Status__c"] = "Under Review";
                        }
                        documentUnderReview=doc[key];
                    }
                    if(key==='Accepted'){
                        for(var item in doc[key]){
                            doc[key][item]["Status__c"] = "Accepted";
                        }
                        documentAccepted=doc[key];
                    }
            /***** Modified 5/15/2020 by Vani User Story #171693*****/
                    if(key==='Deferred'){
                        for(var item in doc[key]){
                            doc[key][item]["Status__c"] = "Deferred";
                        }
                        documentDeferred=doc[key];
                    }
                }
                
                console.log('documentNeedsAttention', documentNeedsAttention);
                component.set("v.documentNeedsAttention",documentNeedsAttention);
                component.set("v.documentAccepted",documentAccepted);
                component.set("v.documentUnderReview",documentUnderReview);
            /***** Modified 5/15/2020 by Vani User Story #171693*****/
            	component.set("v.documentDeferred",documentDeferred);
                // Start add by Maddileti for User Story #102169 (Maddileti Boya) on 2019-09-09
                component.set("v.documentNotSubmitted",documentNotSubmitted);
              // End add by Maddileti for User Story #102169 (Maddileti Boya) on 2019-09-09
            }
        }, reason => {
            console.log(reason);
        });
    },
})