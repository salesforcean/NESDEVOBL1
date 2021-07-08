({
  
NavigatetoC4 : function(component, event, helper) {
		
		var navigateEvent = $A.get('e.force:navigateToComponent');
        debugger;
        navigateEvent.setParams({
            componentDef: "c:Nes_AuthorizationDecision"
            
        });
        navigateEvent.fire();
	},
    NavigatetoC6 : function(component, event, helper) {
		
		var navigateEvent = $A.get('e.force:navigateToComponent');
        debugger;
        navigateEvent.setParams({
            componentDef: "c:AddHH"
            
        });
        navigateEvent.fire();
	}
    
})