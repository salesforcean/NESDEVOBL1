/**
 * Created by brianpoulsen on 3/20/17.
 * Edited by Joe Callin on 8/12/2017.
 */
({
    getLabel : function(component, event, helper) {
        var headingText = component.get('v.headingText');
        helper.setLabel(component, headingText, 'headingText');
    },
    buildHeading : function(component, event, helper) {
        var headingTag = component.get('v.headingTag').substring(0,2).toLowerCase();
        component.set('v.headingTag', headingTag);
        var sizeClass;
        if(headingTag === 'h1'){
            sizeClass = 'slds-text-heading_large';
        }else if(headingTag === 'h2' || headingTag === 'h3'){
            sizeClass = 'slds-text-heading_medium';
        }else{
            sizeClass = 'slds-text-heading_small';
        }
        var headingAlignment = component.get('v.headingAlignment');
        var headingClass = sizeClass +  ' slds-text-align_' + headingAlignment;
        component.set('v.headingClass', headingClass);
        component.set('v.isInit', true);
    }
})