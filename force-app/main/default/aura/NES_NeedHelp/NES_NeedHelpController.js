/**
 * Created by karolbrennan on 10/15/18.
 */
({
    doInit : function(component)
    {
      
        
        var action = component.get('c.getResourceUrl');
      
        action.setCallback(this, function(response){
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                console.log("RESOURCE URL", result);
                component.set('v.resourceUrl', result);
            }
        });
        $A.enqueueAction(action);
    }
    
    
});