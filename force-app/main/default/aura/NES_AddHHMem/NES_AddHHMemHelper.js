({
    studentexists : function(component, event, helper) {
        var modalBody;
        //alert('IN studentexists');
        $A.createComponent("c:NES_AddHHMemDetails", {},
                           function(content, status) {
                               //alert('STATUS:::' + status);
                               if (status === "SUCCESS") {
                                   modalBody = content;
                                   //alert('Body:::' + modalBody);
                                   component.find('overlayLib').showCustomModal({
                                       //header: "Example for Lightning Modal Component",
                                       body: modalBody, 
                                       showCloseButton: true,
                                       closeCallback: function(ovl) {
                                           console.log('Overlay is closing');
                                       }
                                   })   
                               } else {
                    				throw new Error(error);
                				}
                           }); 
	},
	nostudentexists : function(component, event, helper) {
        var modalBody;
        //alert('IN No studentexists');
        $A.createComponent("c:NES_AddHHMemNoStudent", {},
                           function(content, status) {
                               //alert('STATUS:::' + status);
                               if (status === "SUCCESS") {
                                   modalBody = content;
                                   //alert('Body:::' + modalBody);
                                   component.find('overlayLib').showCustomModal({
                                       //header: "Example for Lightning Modal Component",
                                       body: modalBody, 
                                       showCloseButton: true,
                                       closeCallback: function(ovl) {
                                           console.log('Overlay is closing');
                                       }
                                   })   
                               } else {
                    				throw new Error(error);
                				}
                           }); 
	},
})