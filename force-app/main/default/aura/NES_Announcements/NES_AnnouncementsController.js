/**
 * Created by Ashish on 03-12-2018.
 */
({
    handleInit : function(component,event,helper){
        helper.getAnnouncements(component,event,helper);
    },
    handleDismiss : function(component,event,helper){
        var contactAnnouncementId = event.currentTarget.dataset.id;
        helper.dismissAnnouncement(component,event, helper, contactAnnouncementId);
    },
    handleKeyPress: function(component, event, helper) {
        if(event.which === 13 || event.which === 32){
            var contactAnnouncementId = event.currentTarget.dataset.id;
            helper.dismissAnnouncement(component,event, helper, contactAnnouncementId);
        }
    },
    changeContentNow: function(component, event, helper){

      document.getElementsByClassName('slds-carousel__indicator-action slds-is-active')[0].classList.remove('slds-is-active');
      event.currentTarget.classList.add('slds-is-active');

      var curSelectedItem = document.getElementsByClassName('slds-carousel__panel slds-show')[0];
      curSelectedItem.classList.remove('slds-show');
      curSelectedItem.classList.add('slds-hide');

      var theItem = document.getElementById('content-'+event.currentTarget.id);
      theItem.classList.remove('slds-hide');
      theItem.classList.add('slds-show');

    }
})