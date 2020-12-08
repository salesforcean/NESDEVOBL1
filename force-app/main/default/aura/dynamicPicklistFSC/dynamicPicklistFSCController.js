({

	init: function(component, event, helper) {
		helper.component = component
		const options = component.get('v.options');
		const object = component.get('v.object');
		const field = component.get('v.field');
		const controllingField = component.get('v.controllingField');
		const controllingFieldValue = component.get('v.controllingFieldValue');
		const value = component.get('v.value');
		console.log('value=>', value.toLowerCase());
		
		if (options.length === 0) {
			helper
				.fireApex('c.getDependentPicklistValues', { picklistField: field, sObjectAPIName: object,  ctrlField: controllingField, ctrlFieldPicklistValue: controllingFieldValue})
				.then(newOptions => {
					if (value) {
						newOptions.forEach(o => {
							o.selected = o.value.toLowerCase() === value.toLowerCase()
						})
					} else {
						newOptions.unshift({value: "", label: "--None--"});
						newOptions[0].selected = true;
					}

					const selectedOption = newOptions.find(o => o.selected) || {}
					component.set('v.value', selectedOption.value || '')
					component.set('v.options', newOptions)
				});
		}
	},
	init_backup: function(component, event, helper) { 
		helper.component = component
		const options = component.get('v.options');
		const object = component.get('v.object');
		const field = component.get('v.field');
		const value = component.get('v.value');
		
		if (options.length === 0) {
			helper
				.fireApex('c.getPicklistValues', { fld: field, obj: object })
				.then(newOptions => {
					if (value) {
						newOptions.forEach(o => {
							o.selected = o.value.toLowerCase() === value.toLowerCase();
						})
					} else {
						newOptions[0].selected = true
					}

					const selectedOption = newOptions.find(o => o.selected) || {}
					component.set('v.value', selectedOption.value || '')
					component.set('v.options', newOptions)
				})
		}
	}
})