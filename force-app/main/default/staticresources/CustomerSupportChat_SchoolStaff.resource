window._snapinsSnippetSettingsFile = (function() {
//Swapna:For Customer Support Chat
embedded_svc.snippetSettingsFile.directToButtonRouting = function(prechatFormData) {


if(prechatFormData[3].value === "Technical Support") {

return "5730n0000008PUO";

}

}

embedded_svc.snippetSettingsFile.fallbackRouting = ['USERIDHERE', 'BUTTONIDHERE', 'USERID_BUTTONID'];

embedded_svc.snippetSettingsFile.extraPrechatInfo = [{
"entityName": "Contact",
"linkToEntityName": "Case",
"linkToEntityField": "ContactId",
"saveToTranscript": "ContactId",
"entityFieldMaps" : [{
"doCreate":false,
"doFind":true,
"fieldName":"FirstName",
"isExactMatch":true,
"label":"First Name"
}, {
"doCreate":false,
"doFind":true,
"fieldName":"LastName",
"isExactMatch":true,
"label":"Last Name"
}]
}]

})();