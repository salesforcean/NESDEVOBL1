({
    handleInit : function(component,event,helper){
        helper.handleInit(component);

    },
    handleClose : function(component, event, helper) {
        component.find("overlayLib").notifyClose();
    },
    redirectToDoc: function(component, event, helper){
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var url = '/document-uploader?enrollmentComponentAffiliationId=' + event.currentTarget.dataset.id +
            '&enrollmentDocumentId='+event.currentTarget.dataset.docid +
            '&caretakerId='+userId;
        var redirect = $A.get("e.force:navigateToURL");
        redirect.setParams({
            "url" : url
        });
        redirect.fire();
        component.find("overlayLib").notifyClose();
    },
   // Start add by Maddileti for User Story #102169 (Maddileti Boya) on 2019-09-09 
    redirectToDocument: function(component, event, helper){
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var url = '/document-uploader?enrollmentComponentAffiliationId=' + event.currentTarget.dataset.id +
            '&caretakerId='+userId;
        console.log('the values are:'+event.currentTarget.dataset.id);
        var redirect = $A.get("e.force:navigateToURL");
        redirect.setParams({
            "url" : url
        });
        redirect.fire();
		component.find("overlayLib").notifyClose();
    } 
    // End add by Maddileti for User Story #102169 (Maddileti Boya) on 2019-09-09
})