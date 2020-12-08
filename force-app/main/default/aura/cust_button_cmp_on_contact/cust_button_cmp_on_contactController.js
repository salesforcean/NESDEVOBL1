({
    doInit: function(component, event, helper) {
        helper.getStudents(component,event, helper);
    }, 
    
    Enrollment: function(component, event, helper) {  
        
     helper.getEnrollment(component,event, helper);
        
       /* console.log('indirectlink1'+url);
        var url = 'https://pearsonobl--nesspoc1.lightning.force.com/lightning/cmp/c__NES_enrollment';
        console.log('indirectlink2'+url);
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        console.log('indirectlink3'+url);
        console.log('indirectlinkuserId'+userId);
        
        userId = '00521000002fgs1AAA';
        console.log(component.get("v.studentId"));
        console.log(component.get("v.programEnrollmentId"));
        console.log(component.get("v.processId"));
        console.log(component.get("v.tudentGrade"));
        
        url = url + '?c__studentId=' +  component.get("v.studentId")
        + '&c__caretakerId=' + userId
        + '&c__programEnrollmentId=' +   component.get("v.programEnrollmentId")
        + '&c__processId=' + component.get("v.processId")
        + '&c__studentGrade=' + component.get("v.tudentGrade")
        
        console.log('indirectlink22'+url);
        var urlEvent = $A.get("e.force:navigateToURL");
        if(typeof(urlEvent)!= 'undefined'){
            urlEvent.setParams({
                "url": url
            });
            urlEvent. fire();
        }else{
            window.open(url);
        }
    } */
    }
       
    
});