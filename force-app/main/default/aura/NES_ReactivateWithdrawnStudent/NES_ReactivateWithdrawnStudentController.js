/**
* Created by Krishna Peddanagammol on 2019/11/27 for US#119618.
**/
({
    recordLoaded: function(component, event, helper) {
        component.set("v.programEnrollmentId",component.get("v.recordId"));
        component.set("v.studentName",component.get("v.peRecord.hed__Contact__r.Name"));
        component.set("v.hasError",false);
        component.set("v.success",false);
        component.set("v.message",null);
		
        var programEnrollmentId = component.get("v.programEnrollmentId");
        var stundentName = component.get("v.studentName");
        var context = component.get("v.context");
        //console.log('pdid=', programEnrollmentId);
        //console.log('context=', context);
        //console.log(context);
        var action = component.get("c.reactivateStudent");
        //alert(context);
        action.setParams({
            studPEID: programEnrollmentId,
            reactivationType: context
        });
        action.setCallback(this, function(response){
            var peakResponse = response.getReturnValue();
            if(peakResponse.success){
                component.set("v.success", true);                
                var resultsToast = $A.get("e.force:showToast"); 
                resultsToast.setParams({ 
                    //title : 'Success',
                    message: stundentName + ' has been successfully reactivated.',
                    //duration:'3000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'dismissible'                    
                }); 
                resultsToast.fire();
                $A.get("e.force:closeQuickAction").fire();
				$A.get('e.force:refreshView').fire(); 	
            } else {
                component.set("v.hasError",true);
                component.set("v.message", peakResponse.messages[0]);          
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    //title : 'Error',
                    message: peakResponse.messages[0],
                    //duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'dismissible'
                });
                toastEvent.fire();   
                $A.get("e.force:closeQuickAction").fire();
				$A.get('e.force:refreshView').fire(); 
            }            	
        });
        $A.enqueueAction(action);
    }
})