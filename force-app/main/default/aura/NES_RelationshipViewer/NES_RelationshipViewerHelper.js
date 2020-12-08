/**
 * Created by Ashish Pandey on 18-12-2018.
 */
({
    handleInit : function(component) {

        var params = {
            'ecId' : component.get("v.recordId")
        };
        let _this = this;
        var fetchRecordTypeName = this.doCallout(component, 'c.getECRecordType', params);
        fetchRecordTypeName.then(result =>
        {
            if(result=='Form') {
                component.set("v.isformRelatedEC", true);
                _this.fetchFormRelatedECs(component);
            }
            if(result=='Question') {
                _this.fetchQuestionRelatedECs(component);
            }
        }, reason => {
            console.log(reason)
        });
    },
    fetchFormRelatedECs : function(component){
        var params = {
            'formEcId' : component.get("v.recordId")
        };
        var fetchFormRelatedECsPromise = this.doCallout(component, 'c.getFormRelatedECs', params);
        fetchFormRelatedECsPromise.then(result =>
        {
            component.set("v.isLoaded",true);
            if(result) {
                var arrayMapKeys = [];
                for(var key in result.relationShipViewResults){
                    arrayMapKeys.push({key: key, value: result.relationShipViewResults[key]});
                }
                component.set("v.relatedEC", arrayMapKeys);
            }
        }, reason => {
            console.log(reason)
        });
    },
    fetchQuestionRelatedECs : function(component){
        var params = {
            'questionEcId' : component.get("v.recordId")
        };
        var fetchFormRelatedECsPromise = this.doCallout(component, 'c.getQuestionRelatedECs', params);
        fetchFormRelatedECsPromise.then(result =>
        {
            component.set("v.isLoaded",true);
            if(result) {
            	var arrayMapKeys = [];
                for(var key in result.relationShipViewResults){
                    arrayMapKeys.push({key: key, value: result.relationShipViewResults[key]});
                }
                component.set("v.relatedEC", arrayMapKeys);
            }
        }, reason => {
            console.log(reason)
        });
    },
    navigateToRecord : function (component, recordId) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          "recordId": recordId
        });
        navEvt.fire();
    }

})