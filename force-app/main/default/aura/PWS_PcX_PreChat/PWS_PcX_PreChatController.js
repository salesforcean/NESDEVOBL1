({
    /**
    * After this component has initialized, configure environment variables
    *
    * @param component - This prechat UI component.
    * @param event - The Aura event.
    * @param helper - This component's helper.
    */
    onInit: function (component, event, helper) {
        // get domain name to build zip code lookup endpoint URL
    	window.zipCodeLookupDomain = window.parent.location.hostname;
    },
    /**
    * After this component has rendered, create an  input fields
    *
    * @param component - This prechat UI component.
    * @param event - The Aura event.
    * @param helper - This component's helper.
    */
    onRender: function (component, event, helper) {
        // Get array of pre-chat fields defined in Setup using the prechatAPI component
        var prechatFields = component.find("prechatAPI").getPrechatFields();
        // Append an input element to the prechatForm div.
        helper.renderFields(helper, prechatFields);

        if (window.chatValidation) {
            // chat has been closed and re-opened
            // re-wire validation
            helper.enableFieldValidation();
        }
    },
    /**
	 * Handler for when the start chat button is clicked
	 *
	 * @param component - This prechat UI component.
	 * @param event - The Aura event.
	 * @param helper - This component's helper.
	 */
    onStartButtonClick: function (component, event, helper) {
        var prechatInfo = helper.createStartChatDataArray();
        console.log('Pre Chat Data: ' + JSON.stringify(prechatInfo));        
        var prechatAPI = component.find("prechatAPI");
        var salesForceFieldValidation = prechatAPI.validateFields(prechatInfo);

        // validate with jQuery plugin
        var formFieldValidation = window.chatValidation.form();

        // validate all required fields are filled out
        var requiredFieldValidation = helper.validateRequiredFields(prechatInfo);

        if (salesForceFieldValidation.valid && formFieldValidation === true && requiredFieldValidation === true) {
            if (window.zipCodeLookupRequired === true) {
                // let the getJSON callback trigger chat after lookup
                helper.performZipCodeLookup(helper, prechatAPI.startChat, prechatInfo);
            }
            else {
                prechatAPI.startChat(prechatInfo);
            }

        } else {
            console.log('Form could not be validated!');
        }
    },
    /**
	 * Handler for when the external scripts are loaded
	 *
	 * @param component - This prechat UI component.
	 * @param event - The Aura event.
	 * @param helper - This component's helper.
	 */
    scriptsLoaded: function (component, event, helper) {
        if (window.chatValidation) {
            // chat was closed and re-opened
            // wait for fields to re-render to re-enable validation
            return;
        }

        helper.enableFieldValidation();
    }
});