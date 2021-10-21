({
    /**
     * Create an HTML input element, set necessary attributes, add the element to the DOM
     *
     * @param fields - pre-chat fields object with attributes needed to render
     */
    renderFields: function (helper, fields) {
        //keep track of school code during the loop
        //because some school codes require additional fields
        var schoolCode;

        // Dynamically create input fields
        fields.forEach(function (field) {
            // this will render fields out in the same HTML structure as the out of the box form
            // to take advantage of default styling that lines up with the comps
            var componentName = (field.type === "inputSplitName") ? "inputText" : field.type;
            var li = document.createElement("li");
            li.className = field.type + " embeddedServiceSidebarFormField";
            li.setAttribute("data-aura-class", "embeddedServiceSidebarFormField");

            var div = document.createElement("div");
            div.className = "uiInput uiInputText uiInput--default uiInput--input";
            div.setAttribute("data-aura-class", "uiInput uiInputText uiInput--default uiInput--input");

            var label = document.createElement("label");
            label.name = "label_" + field.name;
            label.className = "uiLabel-left form-element__label uiLabel";
            label.setAttribute("for", field.name);
            label.setAttribute("data-aura-class", "uiLabel");

            var labelSpan = document.createElement("span");
            labelSpan.innerHTML = field.label;
            label.appendChild(labelSpan);

            div.appendChild(label);

            var input = document.createElement("input");

            // Set general attributes
            input.className = field.className;
            input.placeholder = field.label + (field.required ? " *" : "");

            // set value if not null
            if (field.value != null) {
                input.value = field.value;
                if (field.name === "School_ID_Location__c") {
                    schoolCode = field.value;
                }
            }

            input.type = helper.getInputType(field, schoolCode);

            // Set attributes required for starting a chat
            input.name = field.name;
            input.label = field.label;
            if (field.picklistOptions && input.type !== "hidden") {
                input.options = field.picklistOptions;
            }

            input.required = field.required;
            input.maxLength = field.maxLength;
            input.disabled = field.readOnly;

            input.setAttribute("aria-required", field.required);
            input.setAttribute("aria-describedby", "label_" + field.name);

            if (field.name === "Chat_Zip_Code__c") {// Customize Zip Code input if needed
                input.required = true;
                input.setAttribute("aria-required", true);
                input.placeholder = "Zip Code *";
                input.setAttribute("type", "text");
            } else if (field.name === "Global_Opt_Out__c") {// Manually set the Global Opt Out field to "NO"
                input.value = field.value = "NO";
                input.maxLength = field.maxLength = 2;
            }

            div.appendChild(input);

            var elementToAppend = div;

            // put first and last name side by side
            if (field.type === "inputSplitName") {
                var span = document.createElement("span");
                span.className = "split-field-container";
                span.appendChild(div);
                elementToAppend = span;
            }

            li.appendChild(elementToAppend);

            // Add field to the DOM
            document.querySelector(".fieldList").appendChild(li);
        });
    },
    /**
    * Validate required fields are filled out
    *
    * @param fields - pre-chat field info
    */
    validateRequiredFields: function (fields) {
        for (var i = 0; i < fields.length; i++) {
            var field = fields[i];
            if (field.required === true && (!field.value || 0 === field.value.length))
                return false;
        }

        return true;
    },
    /**
     * jQuery validation of field formatting.
     */
    enableFieldValidation: function () {
        if (window.$) {
            // custom validation methods
            jQuery.validator.addMethod("emailWithFullTLD", function (value, element) {
                const regex = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
                return this.optional(element) || regex.test(value);
            }, 'Please enter a valid email address.');

            jQuery.validator.addMethod("disallowOnlyWhitespace", function (value, element) {
                const regex = /^\s+$/i;
                return this.optional(element) || !regex.test(value);
            }, 'This field is required.');

            // enable validation for form
            window.chatValidation = $("#pcxPreChat").validate();

            // enable custom validation
            $("input[name=FirstName]").rules("add", { disallowOnlyWhitespace: true });
            $("input[name=LastName]").rules("add", { disallowOnlyWhitespace: true });
            $("input[name=Email]").rules("add", { emailWithFullTLD: true });
            $("input[name=Phone]").rules("add", { phoneUS: true });
            $("input[name='Chat_Zip_Code__c']").rules("add", { zipcodeUS: true });
        }
    },
    /**
    * Validate required fields are filled out
    *
    * @param helper - helper object
    * @param startChatMethod - js function that triggers chat start
    * @param preChatInfo - pre-chat field info
    */
    performZipCodeLookup: function (helper, startChatMethod, preChatInfo) {
        if (window.$) {
            const zipCodeValue = ($("input[name='Chat_Zip_Code__c']").val()
                && $("input[name='Chat_Zip_Code__c']").val().trim())
                ? $("input[name='Chat_Zip_Code__c']").val().substring(0, 5) : null;

            if (zipCodeValue) {
                const parameters = {
                    zipCode: zipCodeValue,
                    urlType: "Enrollment Redirect"
                };

                // disable start button to prevent double clicks while zip is being validated
                const $startButton = $("button.startButton");
                $startButton.attr("disabled", true);

                const iNaCaSchoolId = 143;

                $.getJSON("https://" + window.zipCodeLookupDomain + "/API/FindByZip/locations/getLocationByZipCode", parameters)
                    .done(function (data) {
                        const schoolJson = JSON.parse(data);
                        const $schoolIdHiddenField = $("input[name='School_ID_Location__c']");
                        if (schoolJson && schoolJson.idLocation) {
                            const idLocation = schoolJson.idLocation;
                            // replace school id with value returned from API unless it's iNaCA
                            idLocation === iNaCaSchoolId ? $schoolIdHiddenField.val("") : $schoolIdHiddenField.val(idLocation);
                            // form values have changed so regenerate prechatInfo object
                            preChatInfo = helper.createStartChatDataArray();
                        } else {
                            // invalid zip or error on API call
                            $schoolIdHiddenField.val("");
                            // form values have changed so regenerate prechatInfo object
                            preChatInfo = helper.createStartChatDataArray();
                        }
                    }).fail(function () {
                        console.log("Could not find a school for this ZIP code.");
                    }).always(function () {
                        $startButton.removeAttr("disabled");
                        startChatMethod(preChatInfo);
                    });
            }
        } else {
            // if jquery did not load properly
            startChatMethod(preChatInfo);
        }
    },
    /**
     * Gets HTML input type of field based on criteria
     *
     * @param {string} field Form field object
     * @param {number} schoolCode School code where chat was initiated
     */
    getInputType: function (field, schoolCode) {
        const hiddenFields = [
            "School ID Location", "Mktg_LeadSourceCode", "Chat Zip Code",
            "Company", "Channel Type", "Lead Source",
            "GA Click ID", "GA Client ID", "GA Device", "GA Exp ID", "GA Medium", "GA Source"
        ];

        if (field.type === "inputEmail") {
            return "email";// return email for email inputs
        } else if (field.type === "inputPhone") {
            return "tel";// return tel for phone number inputs
        }

        // Hide hidden fields and the Global Opt Out field
        if (hiddenFields.includes(field.label) || field.name === "Global_Opt_Out__c") {
            return "hidden";
        }

        return "text";
    },
    /**
     * Create an array of data to pass to the prechatAPI component's startChat function
     */
    createStartChatDataArray: function () {
        var inputs = document.querySelectorAll(".fieldList input");
        var infos = [];
        for (var i = 0; i < inputs.length; i++) {
            var info = {
                name: inputs[i].name,
                label: inputs[i].label,
                value: inputs[i].value,
                required: inputs[i].required
            };
            infos.push(info);
        }
        return infos;
    }
});