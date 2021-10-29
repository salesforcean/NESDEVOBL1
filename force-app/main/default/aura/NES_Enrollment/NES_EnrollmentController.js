/**
 * Created by karolbrennan on 11/16/18.
 */
({
    doInit: function(component, event, helper)
    {
        
        helper.initiateStudent(component, event, helper);
    },
    doNothing: function(component, event, helper)
    {
        // do nothing
    },
    handleTabClick: function(component, event, helper)
    {
        helper.handleTab(component, event, helper);
        helper.toggleMobileSide(component, event, helper);
    },
    handleStart: function(component, event, helper) {
        var sectionId = event.getSource().get("v.name");
        var sections = component.get("v.sections");

        component.set("v.currentSectionId", sectionId);
        for(var i=0; i<sections.length;i++) {
            if(sections[i].Id === sectionId) {
                component.set("v.currentECAId",sections[i].ecaid);
                component.set("v.currentSectionType",sections[i].sectionType);
                component.set("v.currentSectionName",sections[i].name); //Swapna:for GTM
            }
        }
        helper.navigate(component, event, helper);
    },
    goToDashboard: function(component, event, helper)
    {
        helper.goToDashboard();
    },
    handleWithdraw: function(component,event,helper){
        component.set("v.withdrawModalOpen",true);
    },
    toggleMobileSide: function(component, event, helper)
    {
        helper.toggleMobileSide(component, event, helper);
    },
    stepHover: function(component, event, helper)
    {
        helper.stepHover(component,event,helper);
    }
})