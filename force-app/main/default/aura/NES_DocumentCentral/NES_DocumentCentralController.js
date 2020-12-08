/**
 * Created by Ashish on 03-12-2018.
 */
({
    handleInit : function(component,event,helper){
        helper.handleInit(component);
    },
    handleShowModal: function(component) {
        $A.createComponent("c:NES_DocumentCentralDetail", {
                heading: component.get("v.heading"),
                detailbody: component.get("v.detailbody")
            },
            function(content, status) {
                if (status === "SUCCESS") {
                    var modalBody = content;
                    component.find('overlayLib').showCustomModal({
                       body: modalBody,
                       showCloseButton: false,
                       cssClass: "slds-modal_medium",
                       closeCallback: function() {
                           
                       }
                    }).then(function(overlay) {
                    });
                }
            });
    }
})