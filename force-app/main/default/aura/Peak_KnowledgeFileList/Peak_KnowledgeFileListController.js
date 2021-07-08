/**
 * LF_Nexus - Generates the assets used for LifeFitness custom theme
 * @version 1.0.0
 * @author 7Summits
 *
 * COMPILED FILE DO NOT DIRECTLY EDIT
 */
({

    doInit: function doInit(cmp, evt, helper) {
       
        helper.getFiles(cmp);
    },

    handleFileClick: function handleFileClick(cmp, event, helper) {
        
        helper.showPreview(event);
    },
    getHeight: function getHeight(component, event, helper) {
        helper.setHeight(component);
    }

});