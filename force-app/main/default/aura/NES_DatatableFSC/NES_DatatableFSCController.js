({
    init: function (cmp, event, helper) {
        
        // var actions = [
        //     { label: 'View/Edit', name: 'view' },
        //     // { label: 'Edit', name: 'edit' }
        // ]


        // Maximum Row Selection
        if(cmp.get('v.singleSelection') == '1') {
            cmp.set('v.maxRowSelection','1')
        }

        // hide the recordForm box on init.
        cmp.set('v.recForm_show', false);

        // reset the errors on refresh
        cmp.set('v.errors', []);
        
        // we won't be using this so settin to false
        cmp.set('v.hideCheckboxColumn', true);

        // Column Settings
        var cols = new Array();
        var queryFields = [];
        for (var i=101; i < 107; i++) {
            var varIcon = '';           
            if(cmp.get('v.column'+i.toString().substring(1)+'_fieldName')) {
                // queryFields.push('v.column'+i.toString().substring(1)+'_fieldName');
                queryFields.push(cmp.get('v.column'+i.toString().substring(1)+'_fieldName'));
                
                
                if (i.toString().substring(1) === '01') {
                    varIcon = cmp.get('v.column'+i.toString().substring(1)+'_icon')
                }
				console.log(i);  
				var cellClass =  
					cmp.get('v.column'+i.toString().substring(1)+'_type').toLowerCase() == 'number' ||
					cmp.get('v.column'+i.toString().substring(1)+'_type').toLowerCase() == 'currency'
					? 
                	{
                		fieldName : cmp.get('v.column'+i.toString().substring(1)+'_fieldName') + 'class'
                	}
            		:
            		{};
            	                             
                cols.push({
                    iconName: varIcon,
                    label: cmp.get('v.column'+i.toString().substring(1)+'_label'), 
                    fieldName: cmp.get('v.column'+i.toString().substring(1)+'_fieldName'), 
                    type: cmp.get('v.column'+i.toString().substring(1)+'_type'), 
                    sortable: cmp.get('v.column'+i.toString().substring(1)+'_sortable'), 
                    editable: cmp.get('v.column'+i.toString().substring(1)+'_editable'),
                    required: cmp.get('v.column'+i.toString().substring(1)+'_required')
                });                                   
            }
        }
        
        // cols.push({ label:'Actions', type: 'action', fixedWidth: 100, typeAttributes: { rowActions: actions } });
        cols.push({label: 'Action', type: 'button', initialWidth: 135, typeAttributes:
        { label: 'View/Edit', name: 'view', title: 'Click to View or Edit Details'}});
        // console.log(cols);
        // console.log(queryFields);
        console.log(JSON.stringify(cols));
        cmp.set('v.mycolumns', cols);
        cmp.set('v.queryFields', queryFields);
        helper.loadData(cmp, event, helper);
        
    },

     // Client-side controller called by the onsort event handler
     updateColumnSorting: function (cmp, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        // assign the latest attribute with the sorted column fieldName and sorted direction
        cmp.set("v.sortedBy", fieldName);
        cmp.set("v.sortedDirection", sortDirection);
        helper.sortData(cmp, fieldName, sortDirection);
    },

    // handle cellChange for lookup / picklist values.
    handleCellChange: function (cmp, event, helper) {
        var draftValues = event.getParam('draftValues');
        // console.log(':::inside handleCellChange:::');
        // console.log(draftValues);
    },

    // InLineEdit onSave..
    handleSaveEdition: function (cmp, event, helper) {
        var draftValues = event.getParam('draftValues');
        // console.log(draftValues);
        var action = cmp.get("c.updateRecords");
        action.setParams({"recList" : draftValues});
        action.setCallback(this, function(response) {
            var state = response.getState();
            // console.log(state);
            if (state === "SUCCESS") {
                $A.get('e.force:refreshView').fire();
            } 
            else if (state== "ERROR") {
                var errors = response.getError();
                // console.error(errors);
                var draftVals = event.getParam('draftValues');
                // console.log('draft values::', draftVals);
                
                var errorLines = {};
                errorLines.rows = {};
                errorLines.table = { title : 'Your edits were not saved.'};
                for (var key in errors) {
                    
                    var recID = draftVals[key].Id;
                    var errMsgs = [];
                    for (var er in errors[key].pageErrors) {
                        errMsgs.push(errors[key].pageErrors[er].message);
                    }
                    errorLines.rows[recID] = { 
                            title : 'We found ' + errMsgs.length + ' error(s).',
                            messages : errMsgs
                    };
                    // console.log('::errorRows.rows::', JSON.stringify(errorLines));
                }
                // console.log('::errorRows.rows::', JSON.stringify(errorLines));
                if (!(Object.entries(errorLines).length === 0 && obj.constructor === Object)) {
                    // console.log('::errorLines::', JSON.stringify(errorLines));
                    cmp.set('v.errors', errorLines);
                }
                // helper.showMyToast(cmp, event, helper);
            }
        });    
        $A.enqueueAction(action);
    },

    handleRowAction: function (cmp, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        // console.log('row::' + JSON.stringify(row));
        // console.log(action.name);
        switch (action.name) {
            case 'view':
                cmp.set("v.recForm_recordId", row.Id);
                break;
            default:
                cmp.set("v.recForm_recordId", row.Id);
                break;
            // case 'edit':
            //     helper.editRecord(cmp, row, helper);
            //     break;                
            // case 'Delete':
            //     helper.deleteRecord(cmp, row);
            //     break;

        }
        if(cmp.get("v.recForm_recordId")) {
            cmp.set("v.recForm_show", true);
        }
    },
    recForm_handleSubmit : function(cmp, event, helper) {
        // stop the form from submitting
        event.preventDefault(); 
        const fields = event.getParam('fields');
        let mode = cmp.get("v.recForm_mode");
        if (mode==='edit') {
            // console.log('inside edit mode');
            var peID = cmp.get("v.whereClauseIDFieldValue");
            fields.Program_Enrollment__c =  peID;
        }
        cmp.find('viewEditRecordForm').submit(fields);
        helper.showSpinner( cmp );
    },

    recForm_handleClose : function(cmp, event, helper) {
        helper.recForm_handleClose(cmp, event, helper);
    },

    recForm_handleSuccess : function(cmp, event, helper) {
        // console.log('handleSuccess triggered');
        helper.hideSpinner( cmp );
        helper.recForm_handleClose(cmp, event, helper);
    },
    // calling server to insert a new dummy reccord.
    // createRecord : function(cmp, row, helper) {
    //     var createRecordEvent = $A.get("e.force:createRecord");
    //     createRecordEvent.setParams({
    //     "entityApiName": "Account",  // sObject API Name [Required Parameter]
    //     // "recordTypeId": "1234455566" // Optionally Specify Record Type Id
    //     });
    //     createRecordEvent.fire();
    // },
    createRecord : function(cmp, event, helper) {
        var action = event.getParam('action');
        helper.createRecord(cmp, event, helper);
    },
})