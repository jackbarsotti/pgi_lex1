@isTest
global class CaseTabViewerMockHTTP implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        
        system.debug('Request -----> '+req);
        
        String requestString = String.ValueOf(req);
        
        HttpResponse res = new HttpResponse();
        
        if(requestString.contains('ervices/data/v40.0/sobjects/Case/describe/layouts/')){
            
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"editLayoutSections":[{"columns":2,"heading":"Case Information","layoutRows":[{"layoutItems":[{"editable":false,"label":"Case Owner","layoutComponents":[{"details":{"autoNumber":false,"byteLength":18,"calculated":false,"calculatedFormula":null,"cascadeDelete":false,"caseSensitive":false,"controllerName":null,"createable":true,"custom":false,"defaultValue":null,"defaultValueFormula":null,"defaultedOnCreate":true,"dependentPicklist":false,"deprecatedAndHidden":false,"digits":0,"displayLocationInDecimal":false,"externalId":false,"filterable":true,"groupable":true,"htmlFormatted":false,"idLookup":false,"inlineHelpText":null,"label":"Owner ID","length":18,"name":"OwnerId","nameField":false,"namePointing":true,"nillable":false,"permissionable":false,"picklistValues":[],"precision":0,"referenceTo":["Group","User"],"relationshipName":"Owner","relationshipOrder":null,"restrictedDelete":false,"restrictedPicklist":false,"scale":0,"soapType":"tns:ID","sortable":true,"type":"reference","unique":false,"updateable":true,"writeRequiresMasterRead":false},"displayLines":1,"tabOrder":11,"type":"Field","value":"OwnerId"}],"placeholder":false,"required":false},{"editable":true,"label":"Status","layoutComponents":[{"details":{"autoNumber":false,"byteLength":120,"calculated":false,"calculatedFormula":null,"cascadeDelete":false,"caseSensitive":false,"controllerName":null,"createable":true,"custom":false,"defaultValue":null,"defaultValueFormula":null,"defaultedOnCreate":true,"dependentPicklist":false,"deprecatedAndHidden":false,"digits":0,"displayLocationInDecimal":false,"externalId":false,"filterable":true,"groupable":true,"htmlFormatted":false,"idLookup":false,"inlineHelpText":null,"label":"Status","length":40,"name":"Status","nameField":false,"namePointing":false,"nillable":true,"permissionable":false,"picklistValues":[{"active":true,"defaultValue":true,"label":"New","validFor":null,"value":"New"},{"active":true,"defaultValue":false,"label":"Working","validFor":null,"value":"Working"},{"active":true,"defaultValue":false,"label":"Escalated","validFor":null,"value":"Escalated"},{"active":true,"defaultValue":false,"label":"Closed","validFor":null,"value":"Closed"}],"precision":0,"referenceTo":[],"relationshipName":null,"relationshipOrder":null,"restrictedDelete":false,"restrictedPicklist":false,"scale":0,"soapType":"xsd:string","sortable":true,"type":"picklist","unique":false,"updateable":true,"writeRequiresMasterRead":false},"displayLines":1,"tabOrder":17,"type":"Field","value":"Status"}],"placeholder":false,"required":true}],"numItems":2}],"rows":6,"useCollapsibleSection":false,"useHeading":true}],"id":"00h7F000003YgTdQAK"}');
            res.setStatusCode(200);
            
            return res;
        }else{
        	return null;
        }
    }
}