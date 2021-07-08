({
    doInit : function(component, event, helper) {
        alert('First Name::' + component.get("v.formData.fname"));
    },
  
	NavigatetoNext : function(component, event, helper) {
		
		var navigateEvent = $A.get('e.force:navigateToComponent');
        debugger;
        navigateEvent.setParams({
            componentDef: "c:Nes_ExisContactinfos"
            
        });
        navigateEvent.fire();
	},
  
	NavigatetoPrev : function(component, event, helper) {
		
		var navigateEvent = $A.get('e.force:navigateToComponent');
        debugger;
        navigateEvent.setParams({
            componentDef: "c:NES_AddHHMemDetails"
            
        });
        navigateEvent.fire();
	}
})