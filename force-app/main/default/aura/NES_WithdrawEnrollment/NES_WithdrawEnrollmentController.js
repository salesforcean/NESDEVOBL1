/**
 * Created by karolbrennan on 1/11/19.
 */
({
    doInit: function(component,event,helper)
    {
        helper.handleInit(component,event,helper);
    },
    confirm: function(component,event,helper)
    {
        component.set("v.confirmationOpen",true);
    },
    closeModal: function (component,event,helper)
    {
        component.set('v.isOpen',false);
        component.set('v.withdrawalReason',"");
    },
    handleSubmit: function (component, event, helper)
    {
        helper.submitWithdrawal(component,event,helper);
    }
})