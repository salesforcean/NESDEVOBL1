({
   
    
	handleGTMEvent : function(component, event, helper) {
       
        var isGuest = component.get('c.getHousehold');
        isGuest.setCallback(this, function(response){
        var houseHld = response.getReturnValue();
        helper.handleGTM(component, event, helper,houseHld);
        });

        $A.enqueueAction(isGuest);
  
	},
    handleRouteChange : function(component, event, helper) {
         if (document.location.href.indexOf("topic") > -1)
         {
            
            var isGuest = component.get('c.getHousehold');
            isGuest.setCallback(this, function(response){
            var houseHld = response.getReturnValue();
            helper.urlChange(component, event, helper,houseHld);
        });

        $A.enqueueAction(isGuest);
      
             
         }
        if (document.location.href.indexOf("tel:") > -1)
         {
              var isGuest1 = component.get('c.getHousehold');
            isGuest1.setCallback(this, function(response){
            var houseHld = response.getReturnValue();
            helper.tel(component, event, helper,houseHld);
        });

        $A.enqueueAction(isGuest1); 
         }
        
    
    
}
    
})