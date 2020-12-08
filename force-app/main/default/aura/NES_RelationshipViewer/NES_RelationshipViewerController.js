/**
 * Created by Ashish Pandey on 18-12-2018.
 */
({
    handleInit : function(component,event,helper){
        helper.handleInit(component);
    },
    navigateToRecord : function(component,event,helper){
        var currentTarget = event.currentTarget;
        var recordId = currentTarget.dataset.id;
        helper.navigateToRecord(component,recordId);
    },
})