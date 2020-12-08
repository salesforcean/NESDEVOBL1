/**
 * Created by karolbrennan on 10/9/18.
 */
({
    doInit : function(component){
        var action = component.get('c.getYear');
        action.setCallback(this,function(response) {
            var state = response.getState();
            if(state === 'SUCCESS') {
                var year = JSON.parse(response.getReturnValue());
                component.set('v.year', year);
            }
        });
        $A.enqueueAction(action);
    }
})