/**
 * Created by melindagrad on 1/2/19.
 */
({

    doInit: function (component,event,helper) {
        component.set('v.isLoading', true);
        component.set('v.isInit',true);
    },
    iframeLoaded: function(component,event,helper){
        component.set("v.iframeLoaded",true);
        setTimeout(function(){
            helper.initFileDownload(component, event, helper);
        }, 3000);

    },
})