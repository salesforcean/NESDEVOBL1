/**
 * Created by Ashish Pandey on 19-12-2018.
 */
({
    
    handleInteration: function(component, event, helper){
        console.log('<<<<interation>>>');
    },
    handleInit: function(component, event, helper){
        component.set("v.streetError",false);
        helper.handleInit(component);
        helper.grabQuestionsList(component, event, helper);
    },
    startTimer:function(component, event, helper){
        component.set("v.timerStarted", true);
        var minimumCharacters = component.get("v.hierarchySettings.Minimum_Characters__c");
        /* Default to 2 second delay if not set */
        minimumCharacters = Number.isInteger(minimumCharacters) ? minimumCharacters : 3;
        // Convert the delay to milliseconds
        var delay = component.get("v.hierarchySettings.Keystroke_Delay__c");
        delay = Number.isInteger(delay) ? delay * 1000 : 2000;
        var userInput = component.get("v.searchKeyword").toLowerCase();
        console.log(userInput);
        var suggestionsContainer = document.getElementById("suggestionsModal");
        if(userInput.length < minimumCharacters) {
            suggestionsContainer.classList.add("hideEl");
        } else {
            var timeoutVar = setTimeout($A.getCallback(function () {
                /** Get AutoComplete data  **/
                helper.getDataForAutocomplete(component, event, helper);
                console.log('Removed hideEl class');
                suggestionsContainer.classList.remove("hideEl");
            }, delay));
        }
    },
    autoComplete : function(component, event, helper){
        
        var keyword = component.get('v.searchKeyword');
        var minKeywordLength = component.get("v.hierarchySettings.Minimum_Characters__c");
        var timerStarted = component.get("v.timerStarted");
        var searchCmp = component.find('searchField');
        
        //Added for #US 159016 - Begin
        var qregex = component.get('v.questions[0].validation');
        var POBFormatRegex = new RegExp(qregex, 'i');
        var eve1 = event.getSource().get("v.value");
        var eve2 = eve1.toString();
        // var qTarget = component.get('v.questions[0].questionTarget');
        var qmessage = component.get('v.questions[0].validationMessage');
        component.set("v.pobError", false);
        //Added  for #US 159016 - End
        
        
        
        if(keyword.length === 0 || !keyword || keyword === '') {
            $A.util.removeClass(searchCmp, 'slds-has-error');
            var suggestionsContainer = document.getElementById("suggestionsModal");
            suggestionsContainer.classList.add("hideEl");
            component.set("v.searchResults", null);
            component.set("v.isAddressLoaded", false);
            clearTimeout(timeoutVar);
        } else {
            //Added for #US 159016 - Begin
            
            /**"POBOX" validation for Auto complete **/
            
            var enable_search = true;
            //if(qTarget === "Account.ShippingStreet"){
            //alert('*** Before IF qregex ==> '+qregex);
            if(qregex != null){
                    // alert('*** After IF qregex ==> '+qregex);
					eve2 = eve2.toLowerCase();
               	    if(eve2.length >=3  && (eve2.includes("po ") || eve2.includes("post box") || eve2.includes("po box") 
                                     ||eve2.includes("p.o")||eve2.includes("pob")||eve2.includes("p o")||eve2.includes("p -")
                                     ||eve2.includes("p. ")||eve2.includes("po.")||eve2.includes("po-"))){
                    console.log("value matched");
                    component.set("v.isManualAddress", false);
                    var suggestionsContainer = document.getElementById("suggestionsModal");
                    suggestionsContainer.classList.remove("hideEl");
                    component.set("v.isAddressLoaded", true);
                    var searchResult = [];
                    component.set("v.suggestionsModal", searchResult);
                    enable_search = false;
                    component.set("v.pobError", true);
                    component.set("v.pobErrorMsg",qmessage);
                    $A.util.addClass(searchCmp, 'slds-has-error .slds-textarea'); 
                    return;
                }
            }
            
            //Added for #US 159016 - End
            
            if(keyword.length >= minKeywordLength && enable_search) {  
                if(!timerStarted) {
                    var startTimer = component.get('c.startTimer'); //fires JS method.
                    $A.enqueueAction(startTimer);
                    
                }
                
            } else {
                var suggestionsContainer = document.getElementById("suggestionsModal");
                suggestionsContainer.classList.add("hideEl");
                component.set("v.searchResults", null);
                
            }
        }
    },
    
    handleFocus : function(component, event, helper)
    {
        component.set("v.isValid",true);
    },
    handleManualAddress : function(component, event, helper){
        helper.setQuestionFields(component, event, helper);
    },
    
    searchAgain : function(component, event, helper){
        component.set("v.isManualAddress",false);
        component.set("v.timerStarted",false);
        component.set("v.isAddressLoaded", false);
        component.set("v.searchKeyword", null);
        component.set("v.suggestionsModal", null);
        component.find("searchField").focus();
    },
    
    handleSelection : function(component, event, helper){
        var currentTarget = event.currentTarget;
        var selectedAddressFormatURL = currentTarget.dataset.id;
        component.set("v.selectedAddressFormatURL", selectedAddressFormatURL);
        helper.fetchFormattedAddress(component,event, helper);
        var targetIndex = event.currentTarget.dataset.member;
        var selectedValue = component.get("v.suggestionsModal")[targetIndex];
        component.set("v.record",selectedValue);
        component.set("v.searchKeyword",selectedValue);
        var suggestionsContainer = document.getElementById("suggestionsModal");
        suggestionsContainer.classList.add("hideEl"); 
        console.log('handleSelection');
    },
    /* This will see if the user pressed the enter key then check validity */
    checkKey : function(component, event, helper) {
        if(event.which === 13) {
            helper.checkValidity(component,event);
        }
    },
    handleSubmit : function(component, event, helper) {
        helper.saveAddress(component, event, helper);
    },
    validateFields: function(component, event, helper) {
        console.log('into validation');
        var validatedForm = helper.validateForm(component, event, helper);
        return validatedForm;
    },
    
    //Added for #US 159016 - Begin
    /** POBOX-Validation for Street Address **/
    handlePOBOX: function(component, event, helper){
       
        var el = event.getSource();
        var inCmp = component.find('addressFieldId');
        var strVal = inCmp[0].get('v.value');
        var qTarget = component.get('v.questions[0].questionTarget');
        var qmessage = component.get('v.questions[0].validationMessage');
        var qregex = component.get('v.questions[0].validation');
        var POBFormatRegex = new RegExp(qregex, 'i');
        console.log(POBFormatRegex);
        
        
        // if(qTarget === "Account.ShippingStreet"){
        
        if(qregex != null ){
            
            if (strVal.match(POBFormatRegex)) {
                component.set("v.streetError",true);
                component.set("v.streetErrorMsg",qmessage);
                el.focus();
                $A.util.addClass(inCmp[0], 'errstyle');
                
                
            }
            else{
                component.set("v.streetError",false);
                $A.util.removeClass(inCmp[0], 'errstyle');
                component.set("v.streetErrorMsg","");
                
            }
        } else{
            component.set("v.streetError",false);
            $A.util.removeClass(inCmp[0], 'errstyle');
            component.set("v.streetErrorMsg","");
        }
        
    },
    //Added for #US 159016 - End
    
  handleDate: function(component, event, helper){
        
        var inputCmp = event == null ? component : event.getSource();
        var dateValue = inputCmp.get("v.value");
        var dateFormatRegex = /^(?:(?:(?:0[13578]|1[02])(\/)31)\1|(?:(?:0[1,3-9]|1[0-2])(\/)(?:29|30)\2))(?:(?:19|[2-9]\d)\d{2})$|^(?:02(\/)29\3(?:(?:(?:19|20)(?:[02468][048]|[13579][26]))))$|^(?:(?:0[1-9])|(?:1[0-2]))(\/)(?:0[1-9]|1\d|2[0-8])\4(?:(?:19|20)?\d{2})$/i;
        
        if (dateValue.match(dateFormatRegex)) {
            inputCmp.setCustomValidity("");
            inputCmp.reportValidity();
            return true;
        } else {
            inputCmp.setCustomValidity("Incorrect date/format. Please enter a valid date in the format MM/DD/YYYY");
            inputCmp.reportValidity();
            //inputCmp.set("v.value", "");
            //inputCmp.focus();                
            return false;
        }
        
    }
})