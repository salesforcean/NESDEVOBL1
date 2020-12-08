/**
 * Created by karolbrennan on 1/15/19.
 */
({
    doInit: function(component,event,helper)
    {
        var sAgent = window.navigator.userAgent;
        var Idx = sAgent.indexOf("MSIE");

        if (!!navigator.userAgent.match(/Trident\/7\./)){
            component.set("v.isOpen",true);
        }
    },
    closeModal: function (component,event,helper)
    {
        component.set('v.isOpen',false);
    },
})