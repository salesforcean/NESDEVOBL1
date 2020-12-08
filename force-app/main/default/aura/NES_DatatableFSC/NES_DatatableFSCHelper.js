({
    sortData: function (cmp, fieldName, sortDirection) {
        var data = cmp.get("v.mydata");
        var reverse = sortDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        data.sort(this.sortBy(fieldName, reverse))
        cmp.set("v.mydata", data);
    },
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
            function(x) {return x[field]};
        //checks if the two rows should switch places
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },
    showToast : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode: 'sticky',
            message: 'This is a required message',
            messageTemplate: 'Record {0} created! See it {1}!',
            messageTemplateData: ['Salesforce', {
                url: 'http://www.salesforce.com/',
                label: 'here',
                }
            ]
        });
        toastEvent.fire();
    },
    hideSpinner : function( component ) {
        var eleSpinner = component.find( "spinner" );
        
        $A.util.addClass( eleSpinner, "slds-hide" );
    },
    showSpinner : function( component ) {
        var eleSpinner = component.find( "spinner" );
        
        $A.util.removeClass( eleSpinner, "slds-hide" );
    },
    loadData : function(cmp,event,helper) {
        helper.showSpinner( cmp );   
        var action = cmp.get("c.getData");
        var queryFields = cmp.get('v.queryFields');
        
        queryFields.push('Id');
        if (!queryFields.includes('Name')) {
            queryFields.push('Name');
        }

        var querysObjectAPIName = cmp.get("v.querysObjectAPIName");
        var whereClauseIDFieldAPIName = cmp.get("v.whereClauseIDFieldAPIName");
        var whereClauseIDFieldValue = cmp.get("v.whereClauseIDFieldValue");

        var queryParams  = [];
        queryFields = queryFields.join(',');
        // console.log('queryFields::', queryFields);
        queryParams.push(queryFields);
        queryParams.push(querysObjectAPIName);
        queryParams.push(whereClauseIDFieldAPIName);
        queryParams.push(whereClauseIDFieldValue);
        console.log('::queryParams::', JSON.stringify(queryParams));
		action.setParams({
            "queryFields" : queryFields,
            "queryParams" : queryParams

    	});
    	action.setCallback(this, function(response) {
            console.log('# loadData callback %f', (performance.now() - startTime));
            var state = response.getState();
            helper.hideSpinner( cmp );  
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                cmp.set('v.mydata',data);
                // console.log(cmp.get('v.mydata'));
                console.log(JSON.stringify(cmp.get('v.mydata')));
            }
            // error handling when state is "INCOMPLETE" or "ERROR"
    	});
        var startTime = performance.now();
    	$A.enqueueAction(action);
    },
    editRecord: function (cmp, row, helper) {
        var navService = cmp.find("navService");
    
        var pageReference = {
            type: 'standard__recordPage',
            attributes: {
                "recordId": row.Id,
                "objectApiName": cmp.get("v.querysObjectAPIName"),
                "actionName": "edit"
            }
        }
        navService.navigate(pageReference);
    },
    viewRecord : function(cmp, row, helper) {
        var navService = cmp.find("navService");
    	// console.log(row);
        var pageReference = {
            type: 'standard__recordPage',
            attributes: {
                "recordId": row.Id,
                "objectApiName": cmp.get("v.querysObjectAPIName"), //objectName"),
                "actionName": "view"
            }
        }
        // console.log(JSON.stringify(pageReference));
        // navService.navigate(pageReference);

        cmp.set("v.pageReference", pageReference);
        
        // Set the URL on the link or use the default if there's an error
        // var defaultUrl = "/lightning/r/#objApiName#/#rec_id#/view";
        // defaultUrl = defaultUrl.replace('#objApiName#', cmp.get("v.querysObjectAPIName"));
        // defaultUrl = defaultUrl.replace('#rec_id#', row.Id);
        var defaultUrl = "#";
        navService.generateUrl(pageReference)
            .then($A.getCallback(function(url) {
                // console.log(url);
                cmp.set("v.url", url ? url : defaultUrl);
                helper.invoke(cmp, helper);
            }), $A.getCallback(function(error) {
                cmp.set("v.url", defaultUrl);
            }));
        
        
    }, 
    invoke : function(component, helper) { // event, 
        return new Promise(function(resolve, reject) {        
            
            var url = component.get("v.url");
            var mode = component.get("v.mode");
            var target = '_blank';
            var features = '';
            
            switch (mode) {
                case 'replace':
                    target = '_self';
                    break;
                case 'newWindow':
                    features = features + 'height=100';
                    break;
                default:
                    break;
            }
    
            window.open( url, target, features );// target
            resolve();
               
        });
    },
    createRecord : function(cmp, event, helper) {

        helper.showSpinner( cmp );
        // var peID = cmp.get("v.whereClauseIDFieldValue");
        cmp.set("v.recForm_recordId", "");
        cmp.set("v.recForm_mode", "edit");
        cmp.set("v.recForm_show", true);
        helper.hideSpinner( cmp ); 
        // $A.get('e.force:refreshView').fire();

    },

    // createRecord : function(cmp, event, helper) {

    //     helper.showSpinner( cmp );
    //     var peID = cmp.get("v.whereClauseIDFieldValue");
    //     var action = cmp.get("c.createPriorSchoolRecord");
    //     action.setParams({ "programEnrollmentID" : peID });
    //     action.setCallback(this, function(response) {
    //         console.log('# loadData callback %f', (performance.now() - startTime));
    //         var state = response.getState();
    //         helper.hideSpinner( cmp );  
    //         if (state === "SUCCESS") {
    //             var data = response.getReturnValue();
    //             // console.log(JSON.stringify(data));
    //             $A.get('e.force:refreshView').fire();
    //         }
    //         // error handling when state is "INCOMPLETE" or "ERROR"
    //     });
    //     var startTime = performance.now();
    //     $A.enqueueAction(action);

    // },
    recForm_handleClose : function(cmp, event, helper) {
        helper.showSpinner( cmp );
        console.log('form handleClose.');
        cmp.set("v.recForm_show", false);
        helper.hideSpinner( cmp ); 
        $A.get('e.force:refreshView').fire();
    },
})