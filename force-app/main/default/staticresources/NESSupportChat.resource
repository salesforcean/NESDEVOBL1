window._snapinsSnippetSettingsFile = (function() {

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