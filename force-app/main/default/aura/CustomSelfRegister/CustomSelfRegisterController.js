({
    init : function(cmp) {
        let email = cmp.get("v.email"), 
            fname = cmp.get("v.fname"), 
            lname = cmp.get("v.lname"), 
            pass = cmp.get("v.password"), 
            startUrl = cmp.get("v.starturl"), 
            hasOptedSolicit = cmp.get("v.hasOptedSolicit"),
            hasOptedTracking = cmp.get("v.hasOptedTracking");
       
        let action = cmp.get("c.createExternalUser");
        action.setParams(
            { 
                username: email, 
                password: pass, 
                startUrl: startUrl,
                fname: fname, 
                lname: lname,
                hasOptedTracking: hasOptedTracking,
                hasOptedSolicit: hasOptedSolicit
            });

        action.setCallback(this, function(res) {
            if (action.getState() === "SUCCESS") {
                cmp.set("v.op_url", res.getReturnValue());
            } 
        });
        $A.enqueueAction(action);
    }, 
    
    login: function(cmp){
        let url = cmp.get("v.op_url"); 
        window.location.href = url;  
    }
})