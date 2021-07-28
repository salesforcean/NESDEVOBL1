({ handleShowModal: function(component, event, helper) {
    
    var myAction = component.get("c.STExistsforCT");
    myAction.setCallback(this, function(response) { 
        if(response.getState() === "SUCCESS") { 
            console.log('In Success ->'+ response.getReturnValue());
            //alert('response.getReturnValue()>>' + response.getReturnValue());
            if(response.getReturnValue() == false){
                helper.nostudentexists(component, event, helper);
            }
            else{
                helper.studentexists(component, event, helper);
            }      
        }
        else{
            console.log('In Failure ->'+ response.getState());
        }
    }); 
    $A.enqueueAction(myAction);
},
  
 }
)