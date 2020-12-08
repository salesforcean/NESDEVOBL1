({
    doInit : function(component, event, helper) {

        console.log(document.cookie);

        helper.getIdentifyingData(component).then(function(data){

            component.set("v.hiddenAnnouncements",helper.getCookieValues(component));


            // get the announcements
            helper.getActiveAnnouncements(component).then(function(data){

                helper.slickCarousel(component);

            }, function(){
                console.log("failed")
            });
        });

    },

    navigate : function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": event.getSource().get("v.value"),
        });
        urlEvent.fire();
    },

    handleClick : function(component, event, helper) {
        if (event.target.className == 'close') {
            var userId = component.get("v.userId");
            var networkId = component.get("v.networkId");
            var announcementId = event.path[4].id;
            var expire = new Date();
            expire = new Date(expire.getTime() +1000*60*60*24*365);
            var cookieValues = helper.getCookieValues(component);
            if (cookieValues != null) {
                cookieValues += "," + announcementId;
            } else {
                cookieValues = announcementId;
            }
            console.log("build cookie");

            document.cookie = 'announcements' +userId+networkId+ '=' + cookieValues + ';expires=' + expire.toGMTString() + ';';
            window.location.reload();
        }
    }
})