/**
 * Created by karolbrennan on 11/26/18.
 */
({
    doInit: function(component, event, helper)
    {
        helper.grabCaretaker(component,event,helper);
    },
    openModal: function(component, event, helper)
    {
        component.set("v.modalActive", true);
    },
    closeModal: function(component, event, helper)
    {
        component.set("v.modalActive", false);
    }
})