/**
 * Created by Ritvik on 28-09-2018.
 */
({
    receiveMessage: function (component, event, helper) {
        component.set('v.loading',true);
        window.sessionStorage.setItem('pearsonCookie',event.data);
    }
});