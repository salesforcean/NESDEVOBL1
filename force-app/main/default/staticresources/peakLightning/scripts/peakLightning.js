/**
 * peak_lightning - Generates the assets used for Peak Lightning
 * @version 1.0.0
 * @author 7Summits
 *
 * COMPILED FILE DO NOT DIRECTLY EDIT
 */
// ===================
// Aura helpers for things we do over and over
// ===================
var peakAuraHelpers = function () {

    // Public interface
    return {
        validateField: function validateField(component, parentComponent, fieldName) {
            var findIn = null;
            if (parentComponent != null) {
                // Get the element's actual parent component (for example, something in <c:NestedComponent aura:id="NestedThang" />
                findIn = component.find(parentComponent);
            } else {
                findIn = component;
            }

            // Get the field itself
            var inputField = findIn.find(fieldName);

            // Get aura validity
            var validity = inputField.get("v.validity");

            if (!validity.valid) {
                inputField.showHelpMessageIfInvalid();
                return false;
            } else {
                return true;
            }
        },
        // Validate a field without aura
        rawValidateField: function rawValidateField(fieldName) {
            // Because some dynamically created components aren't found by aura :/
            // Why name and not ID? Because aura doesn't let you put an id on lightning:input or lightning:select!
            var fields = document.getElementsByName(fieldName);
            if (fields.length > 0) {
                if (fields[0].value != null && fields[0].value != '') {
                    return true;
                } else {
                    // Hm, trying to trigger the native aura blur effect for form validation fields[0].blur();
                    return false;
                }
            }
        },
        // Validate a field against a certain value
        rawValidateFieldAgainst: function rawValidateFieldAgainst(fieldName, expectedValue, equals) {
            // Because some dynamically created components aren't found by aura :/
            var fields = document.getElementsByName(fieldName);
            if (fields.length > 0) {
                if (fields[0].value != null && fields[0].value != '') {
                    // Check for equals
                    if (equals) {
                        if (fields[0].value == expectedValue) {
                            return true;
                        }
                    } else {
                        // Check not equals
                        if (fields[0].value != expectedValue) {
                            return true;
                        }
                    }
                }
            }
            return false;
        },
        /*
         Validate an entire form.
         Pass in the component by reference
         parent component (if you are validating a nested component... so if you have Peak_Form which includes <c:Peak_FormPart>, you would call validateForm(component,Peak_FormPart...
         Array of fields - these will find inputs by their aura:id
         */
        validateForm: function validateForm(component, parentComponent, requiredFields) {
            var valid = true;
            for (var x = 0; x < requiredFields.length; x++) {
                if (!this.validateField(component, parentComponent, requiredFields[x])) {
                    valid = false;
                }
            }

            // Set peakResponse and error messages
            if (!valid) {
                component.set("v.peakResponse", peakResponse);
                component.set("v.hasErrors", true);
                return false;
            } else {
                component.set("v.hasErrors", false);
                return true;
                // Actually submit finally!
            }
        }
    };
}();
console.log("example");
console.log('hi');