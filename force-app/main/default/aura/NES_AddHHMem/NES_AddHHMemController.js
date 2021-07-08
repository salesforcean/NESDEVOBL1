({
    doInit  : function(component, event, helper) { 
        var myAction = component.get("c.STExistsforCT");
        myAction.setCallback(this, function(response) { 
        if(response.getState() === "SUCCESS") { 
        	console.log('In Success ->'+ response.getReturnValue());
            component.set("v.STExists", response.getReturnValue());
        }
        else{
            	component.set("v.STExists", false);
                console.log('In Failure ->'+ response.getState());
            }
        }); 
        $A.enqueueAction(myAction);      
    },
	
    dummyCall  : function(component, event, helper) { 
        var myAction = component.get("c.STExistsforCT");
        myAction.setCallback(this, function(response) { 
        if(response.getState() === "SUCCESS") { 
        	console.log('In Success ->'+ response.getReturnValue());
            component.set("v.STExists", response.getReturnValue());
        }
        else{
            	component.set("v.STExists", false);
                console.log('In Failure ->'+ response.getState());
            }
        }); 
        $A.enqueueAction(myAction);      
    },
    
    handleShowModal: function(component, event, helper) {
        var stExists = component.get("v.STExists");
        //alert('Student Exists' + stExists);
        if(stExists == false){
        	helper.nostudentexists(component, event, helper);
        }
        else{
            helper.studentexists(component, event, helper);
        }      
    },
    
}
)