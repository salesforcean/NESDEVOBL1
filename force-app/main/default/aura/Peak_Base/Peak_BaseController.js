/**
 * Created by Ritvik on 28-09-2018.
 */
({
    initPeakBase: function(component, event, helper) {
        
        if(component.get('v.labelText') !== ''){
                helper.setLabel(component);
        }
    }
})