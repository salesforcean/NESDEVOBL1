({
    
    // getDependentPicklistValues(String sObjectAPIName, String picklistField, String ctrlField, String ctrlFieldPicklistValue
    init: function(component, event, helper) {
        helper.component = component
        const options = component.get('v.options');
        const object = component.get('v.object');
        const field = component.get('v.field');
        const controllingField = component.get('v.controllingField');
        const controllingFieldValue = component.get('v.controllingFieldValue');
        const value = component.get('v.value');
        
        if (options.length === 0) {
            helper
            .fireApex('c.getDependentPicklistValues', { picklistField: field, sObjectAPIName: object,  ctrlField: controllingField, ctrlFieldPicklistValue: controllingFieldValue})
            .then(newOptions => {
                if (value) {
                newOptions.forEach(o => {
                o.selected = o.value.toLowerCase() === value.toLowerCase()
            })
        } else {
            newOptions[0].selected = true
        }
        const selectedOption = newOptions.find(o => o.selected) || {}
        component.set('v.value', selectedOption.value || '')
        component.set('v.options', newOptions)
    })
}
 
 //handle the full set of possible choices. Make sure the user isn't passing in two different inputs, which might not match
 //convert the inputs into the form expected for the full list of possible items in the base dualListBox
 
      var fullItemsCSV = component.get('v.FullItemSetCSV');
      var fullItemsStringList = component.get('v.FullItemSetStringList');
      var selectedValuesArray = component.get('v.value1');
      var selectedStringList = component.get('v.SelectedItemsStringList');

   //handle the full items 
   helper.setFullStringAttribute(fullItemsCSV, fullItemsStringList, 'v.FullItemSetStringList', component);
  //Set selected array items 
     if ($A.util.isUndefined(selectedValuesArray)) {
       console.log('No selection on the record');
       }else{
      helper.setCSVString(selectedValuesArray, 'v.SelectedItemsCSV', component);
       }   
   //handle the selected items 
     var selectedItemsCSV = component.get('v.SelectedItemsCSV');
     helper.setSelectedStringAttribute(selectedItemsCSV, selectedStringList, 'v.SelectedItemsStringList', component);
   //TODO: support default values
     helper.setOptionsArray(component.get('v.FullItemSetStringList'), "v.options", component);
    //handle requiredness
     helper.setValidation(component);

  },
    
    handleChange : function(component, event, helper){     
        
        var selectedValuesArray = event.getParam("value");
        
        //Convert the values returned from the dualListBox base component to CSV format and store in the attribute
        helper.setCSVString(selectedValuesArray, 'v.SelectedItemsCSV', component);
        //also update this component's representation of the base component's selection
        component.set('v.SelectedItemsStringList', selectedValuesArray);
        
    }
})