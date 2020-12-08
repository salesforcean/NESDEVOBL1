/**
 * Created by Ritivk on 28-09-2018.
 */
({
    afterRender: function (component, helper) {

        window.addEventListener('message',$A.getCallback(function (event) {
            var postMessageOrigin1 = component.get('v.postMessageOrigin1');
            var postMessageOrigin2 = component.get('v.postMessageOrigin2');
            var postMessageOrigin3 = component.get('v.postMessageOrigin3');
            var postMessageOrigin4 = component.get('v.postMessageOrigin4');

            if (event.origin !== '') {
                if (event.origin === postMessageOrigin1 || event.origin === postMessageOrigin2 ||
                    event.origin === postMessageOrigin3 || event.origin === postMessageOrigin4) {
                    helper.receiveMessage(component, event, helper);
                }
            }


        }));
    }

});