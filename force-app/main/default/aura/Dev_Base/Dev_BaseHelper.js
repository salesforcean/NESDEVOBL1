/**
 * Created by Ritvik on 28-09-2018.
 */
({
    showToast: function (type, message) {
        // types: error, warning, success, info
        var toastEvent = $A.get('e.force:showToast');
        if (toastEvent) {
            toastEvent.fire({
                type: type,
                message: message
            });
        }
    }
});