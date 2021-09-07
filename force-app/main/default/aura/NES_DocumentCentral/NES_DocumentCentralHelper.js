/**
 * Created by Ashish on 03-12-2018.
 */
({
    handleInit : function(component) {
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        //alert(userId);
        var params = {
            'caretakerId' : userId
        };
        var fetchDocumentsList = this.doCallout(component, 'c.getDocumentsList', params);
        fetchDocumentsList.then(result =>
        {
            if(result) { 
            //console.log('documentdata'+ result);
                var document = JSON.parse(result);
            //added by anitha P
                var numberOfNeedsReviewDocs,numberOfAcceptedDocs,numberOfUnderReviewDocs,numberOfNotSubmittedDocs;
                numberOfNeedsReviewDocs=document.numberOfNeedsReviewDocs;
                numberOfAcceptedDocs=document.numberOfAcceptedDocs;
                numberOfUnderReviewDocs=document.numberOfUnderReviewDocs;
            //added by anitha P
                numberOfNotSubmittedDocs= document.numberOfNotSubmittedDocs;
           //added by anitha P
               var numberOfDocs = document.numberOfAcceptedDocs + document.numberOfNeedsReviewDocs + document.numberOfUnderReviewDocs + document.numberOfNotSubmittedDocs;
               if(numberOfDocs > 0) {
                    component.set("v.isLoaded", true);
                } else {
                    component.set("v.isLoaded", false);
                }
                component.set("v.centralDocument",document);
                component.set("v.",numberOfNeedsReviewDocs+numberOfAcceptedDocs+numberOfUnderReviewDocs+numberOfNotSubmittedDocs);
				//alert(JSON.stringify(component.get("v.centralDocument"))); 
    			//alert(component.get("v.totalDocuments"));  
}
        }, reason => {
            console.log(reason);
        });
    },
})