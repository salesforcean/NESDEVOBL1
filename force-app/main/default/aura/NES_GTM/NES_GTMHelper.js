({
	handleGTM : function(component, event, helper,houseHld) {
       var dataLayer = window.dataLayer = window.dataLayer || [];
       var eventNm =event.getParam("eventNm");
       var eventValue =event.getParam("eventValue");
       var step =event.getParam("step");
       var stepValue =event.getParam("stepValue");
       var pagePath =event.getParam("pagePath");
       var timeStamp =event.getParam("timeStamp");
       var status =event.getParam("status");
       var houseHold =event.getParam("houseHold");
  	   var studentId =event.getParam("studentId");
       var relationship =event.getParam("relationship");
       var schoolName =event.getParam("schoolName");
       var schoolYear =event.getParam("schoolYear");
       var stateOfResidence =event.getParam("stateOfResidence");
       var age =event.getParam("age");
       var gradeLevel =event.getParam("gradeLevel");
       var newStudentData = event.getParam("newStudentData");
       var StudentName = event.getParam("StudentName");
       var SectionName = event.getParam("SectionName");
       var FormName = event.getParam("FormName");
       var FormStatus = event.getParam("FormStatus");
       var careTakerId = event.getParam("careTakerId");
       var tz = new Date().toString().match(/([-\+][0-9]+)\s/)[1];
        if(step == 'registrationStep'){
          if(stepValue == 2)
          {
           dataLayer.push({
            'event' : eventValue,
            'pagePath': pagePath,
            'sectionName':'Create Login',
            'registrationStep': 'Get Started - Create Login',
            'timeStamp': timeStamp+tz
            });
          }
          else if(stepValue == 3)
          {
            dataLayer.push({
            'event' : eventValue,
            'pagePath': pagePath,
            'sectionName':'Registration Complete',
            'registrationStep': 'complete',
            'timeStamp': timeStamp+tz
           
            });
          }
       }
        
      if(step == 'contactUS'){
         
        //      var dataLayer = window.dataLayer = window.dataLayer || [];
        dataLayer.push({
            'event' : eventValue,
            'pagePath': pagePath,
            'sectionName': 'Contact Us',
           // 'status': status,
            'householdId': houseHld,
            'timeStamp': timeStamp+tz
            });
        }
        
     if(step == 'createStudent') {
        
         dataLayer.push({
	 	 'event': eventValue,
	     'pagePath': pagePath,
		 'householdId': houseHld, 
	//     'studentId/contactID': newStudentData,   
		 'relationship': relationship,
		 'schoolName': schoolName,
		 'schoolYear': schoolYear,
	//	 'stateOfResidence': stateOfResidence,
	//	 'age': age,
	//	 'gradeLevel': gradeLevel,
	  //   'studentStatus': status,   
	     'timeStamp': timeStamp+tz

		});
    }
       if(step == 'lookingForHelp')
        {
            
         dataLayer.push({
	 	 'event': eventValue,
	     'pagePath': pagePath,
         'sectionName': 'looking For Help',
         'lookingForHelp' : stepValue,
		 'householdId': houseHld, 
         'accountID': '',
	     'timeStamp': timeStamp+tz 

});
            
        }
        if(step == 'Start'){
            dataLayer.push({
            'event' : eventValue,
            'pagePath': pagePath,
            'sectionName': FormName,
            'formStatus': FormStatus,
            'formClick':SectionName,
            'householdId':houseHld,
            'studentId':studentId,
          	'contactID':careTakerId,
            'timeStamp': timeStamp+tz
            }); 
        }
        if(step == 'Submit'){
           dataLayer.push({
            'event' : eventValue,
            'pagePath': pagePath,
            'sectionName': FormName,
            'formSubmit':SectionName,
            'householdId':houseHld,
            'studentId':studentId,
          	'contactID':careTakerId,
            'timeStamp': timeStamp+tz
            }); 
        }
		if(step == 'Skip'){
           dataLayer.push({
            'event' : eventValue,
            'pagePath': pagePath,
            'sectionName': FormName,
            'formSkip':SectionName,
            'householdId':houseHld,
            'studentId':studentId,
          	'contactID':careTakerId,
            'timeStamp': timeStamp+tz
            }); 
        }
	},
    
    urlChange:function(component, event, helper,houseHld) {
       var dataLayer = window.dataLayer = window.dataLayer || [];
        var url = document.location.href;
        var seg = url.split("/").pop();
        var Tpc = 'Topic: '+ seg.charAt(0).toUpperCase() + seg.slice(1); 
        var tz = new Date().toString().match(/([-\+][0-9]+)\s/)[1];
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DDTHH:mm:ss");
        dataLayer.push({
	 	 'event': 'pageview',
	     'pagePath': document.location.href,
         'sectionName': 'Help Topics',
         'lookingForHelp' :Tpc,
		 'householdId':houseHld, 
         'accountID': '',
	     'timeStamp': today+tz
             

});
    },
    
    tel:function(component, event, helper,houseHld) {
       var dataLayer = window.dataLayer = window.dataLayer || [];
       var tz = new Date().toString().match(/([-\+][0-9]+)\s/)[1];
      var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DDTHH:mm:ss");
          dataLayer.push({
	 	 'event': 'pageview',
	     'pagePath': document.location.href,
         'sectionName': 'looking For Help',
         'lookingForHelp' :'Toll Free Number',
		 'householdId':houseHld, 
         'accountID': '',
	     'timeStamp': today+tz

});
    }
})