({
    
    checkSTforCT : function(component, event, helper) { 
        component.set("v.modalOpen", false);
        var myAction = component.get("c.STExistsforPCT");
        myAction.setCallback(this, function(response) { 
        if(response.getState() === "SUCCESS") { 
        	console.log('in Success ->'+ response.getReturnValue());
            component.set("v.STExistsForHH", true);
            component.set("v.modalOpen", true);
        }
        else{
            	component.set("v.STExistsForHH", true);
            	component.set("v.modalOpen", true);
                console.log('in Failure ->'+ response.getState());
            }
        }); 
        $A.enqueueAction(myAction); 
        
    },
    
    callflow  : function(component, event, helper) { 
        
        var myAction = component.get("c.isCaretackerExist"); 
        
        myAction.setCallback(this, function(response) { 
            if(response.getState() === "SUCCESS") { 
                console.log('in Success ->'+ response.getReturnValue());
                if(response.getReturnValue()==true){
                    
                    var flow = component.find("flowId");
                    var inputVariables = [{ name : "CareTaker", type : "String", value:  component.get("v.LoginUserId") }];
                    flow.startFlow("Check_for_ST_Contacts_for_login_CT2");
                }
                else{
                   // for Display Model,set the "isOpen" attribute to "true"
      	component.set("v.isOpen", true);
                }
            }
            else{
                console.log('in Failure ->'+ response.getState());
            }
        }); 
        $A.enqueueAction(myAction); 
        
        
    } ,
    closeModel: function(component, event, helper) {
      // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
      component.set("v.modalOpen", false);
   }
}
)