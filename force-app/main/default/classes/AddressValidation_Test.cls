@isTest
global class AddressValidation_Test {

	@isTest static void sizes() {
		// simply there to ensure that anyone who changes
		// the class is very aware of what they're doing

		System.assertEquals(250, ISO3166_Countries.countryCodes.size(), 'Country Count');
        System.assertEquals(250, ISO3166_Countries.countryCodesToAlpha3.size(), 'Country Count Alpha3');
        System.assertEquals(250, ISO3166_Countries.countryCodesToNumeric.size(), 'Country Count Numeric');
		System.assertEquals(3078, ISO3166_Subdivisions.subdivisionCodes.size(), 'Subdivision Count');
		System.assertEquals(200, ISO3166_Subdivisions.countrySubdivisions.size(), 'Country with Subdivision Count');

		for (String countryCode : ISO3166_Countries.countryCodes.keySet())
			if (countryCode != '') {
				System.assertEquals(2, countryCode.length(), 'Country Code is two-digits: ' + countryCode);
                System.assert(ISO3166_Countries.countryCodesToAlpha3.containsKey(countryCode), 'Country Code has three-digit variant: ' + countryCode);
                System.assert(ISO3166_Countries.countryCodesToNumeric.containsKey(countryCode), 'Country Code has numeric variant: ' + countryCode);
            }

        for (String countryCode : ISO3166_Countries.countryCodesToAlpha3.values())
            if (countryCode != '')
                System.assertEquals(3, countryCode.length(), 'Country Code is three-digits: ' + countryCode);

        for (String countryCode : ISO3166_Countries.countryCodesToNumeric.values())
            if (countryCode != '')
                System.assertEquals(3, countryCode.length(), 'Country Code is two-digits: ' + countryCode);

		for (String subCode : ISO3166_Subdivisions.subdivisionCodes.keySet())
			if (subCode != '')
				System.assertEquals(true, subCode.contains('-'), 'Subdivision Code starts with Country Code: ' + subCode);
	}

	@isTest static void names_countries() {
		System.assertEquals('United States of America', AddressValidation.getCountryName('US'), 'USA');
		System.assertEquals('INVALID CODE: XZ', AddressValidation.getCountryName('XZ'), 'XZ');

		System.assertEquals('US', AddressValidation.getCountryCode('United States of America'), 'USA Reverse');
		System.assertEquals('ABCD', AddressValidation.getCountryCode('ABCD'), 'ABCD Reverse');
	}

	@isTest static void names_subdivisions() {
		System.assertEquals('Georgia', AddressValidation.getSubdivisionName('US-GA'), 'GA');
		System.assertEquals('INVALID CODE: XZ', AddressValidation.getSubdivisionName('XZ'), 'XZ');

		System.assertEquals('GA', AddressValidation.getSubdivisionCode('US', 'Georgia'), 'GA Reverse');
		System.assertEquals('ABCD', AddressValidation.getSubdivisionCode('US', 'ABCD'), 'ABCD Reverse 1');
		System.assertEquals('ABCD', AddressValidation.getSubdivisionCode('ABCD', 'ABCD'), 'ABCD Reverse 2');
	}

	@isTest static void country_subdivisions() {
		Map<String, String> results;

		results = AddressValidation.getCountrySubdivisions('US');
		System.assertEquals(51, results.size(), 'US Count');
		System.assertEquals('Georgia', results.get('GA'), 'US GA');

		results = AddressValidation.getCountrySubdivisions('AI');
		System.assertEquals(1, results.size(), 'AI Count');
		System.assertEquals('N/A', results.get(''), 'AI N/A');

		results = AddressValidation.getCountrySubdivisions('XZ');
		System.assertEquals(1, results.size(), 'XZ Count');
		System.assertEquals('INVALID CODE: XZ', results.get(''), 'XZ Invalid');
	}

/*	@isTest static void address_class() {
		Address__c addr_O = new Address__c();
        addr_O.Recipient_Name__c = 'Recipient_Name__c';
        addr_O.Street_Address_1__c = 'Street 1';
        addr_O.City__c = 'City';
        addr_O.State__c = 'GA';
        addr_O.Country__c = 'US';

        AddressValidation.Address addr_V = new AddressValidation.Address(addr_O.Street_Address_1__c, null, addr_O.City__c, addr_O.State__c, null, addr_O.Country__c);
        System.assertEquals(addr_O.Street_Address_1__c, addr_V.Street1, 'V Street1');
        System.assertEquals(addr_O.City__c, addr_V.City, 'V City');
        System.assertEquals(addr_O.State__c, addr_V.StateProvince, 'V StateProvince');
        System.assertEquals(addr_O.Country__c, addr_V.CountryCode, 'V CountryCode');

        addr_V = new AddressValidation.Address(addr_O);
        System.assertEquals(addr_O.Street_Address_1__c, addr_V.Street1, 'O>V Street_Address_1__c');
        System.assertEquals(addr_O.City__c, addr_V.City, 'O>V City__c');
        System.assertEquals(addr_O.State__c, addr_V.StateProvince, 'O>V State__c');
        System.assertEquals(addr_O.Country__c, addr_V.CountryCode, 'O>V Country__c');

        addr_O = addr_V.toObject();
        System.assertEquals(addr_V.Street1, addr_O.Street_Address_1__c, 'V>O Street_Address_1__c');
        System.assertEquals(addr_V.City, addr_O.City__c, 'V>O City__c');
        System.assertEquals(addr_V.StateProvince, addr_O.State__c, 'V>O State__c');
        System.assertEquals(addr_V.CountryCode, addr_O.Country__c, 'V>O Country__c');

        String json = addr_V.toJSON();
        System.assertEquals('{"Street2":null,"Street1":"Street 1","StateProvince":"GA","PostalCode":null,"CountryCode":"US","City":"City"}', json, 'V>JSON');
	} */

/*	@isTest static void address_checkcountry() {
		AddressValidation.Address addr = new AddressValidation.Address('', '', '', '', '', 'US');

		System.assertEquals(true, addr.checkCountry(), 'US');

		addr.CountryCode = 'XX';
		System.assertEquals(false, addr.checkCountry(), 'XX');

		Boolean error = false;
		try { addr = new AddressValidation.Address('', '', '', '', '', 'XX'); }
		catch (Exception e) { error = true; } 
		System.assertEquals(true, error, 'Error for XX'); 
	} */

    global class HttpMock implements HttpCalloutMock {
        Integer code = 200;
        String expected = '';

        global void setExpected(Integer code, String expected) {
            this.code = code;
            this.expected = expected;
        }

        global HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(this.code);
            response.setBody(this.expected);
            return response;
        }
    }

/*	@isTest static void validateAddress_ScanSource_invalid() {
        HttpMock mock = new HttpMock();
        Test.setMock(HttpCalloutMock.class, mock);
        mock.setExpected(400, '{"Message":"The request is invalid.","ModelState":{"addressModel.CountryCode":["The field CountryCode must be a string or array type with a maximum length of \'2\'."]}}');

		AddressValidation.Address addr = new AddressValidation.Address('Street1', 'Street2', 'City', 'State', 'Zip', 'US');
		addr.CountryCode = 'XXXX';

		Boolean error = false;
		AddressValidation.AddressValidationResult result;
		try { result = AddressValidation.validateAddress_ScanSource(addr); }
		catch (Exception e) {
			error = true;
			System.debug(AddressValidation.formatException(e));
			System.assertEquals(mock.code + ': ' + mock.expected, e.getMessage(), 'Exception message');
		}
		System.assertEquals(true, error, 'Exception for 400');  
	}  

	@isTest static void validateAddress_ScanSource_unknown() {
        HttpMock mock = new HttpMock();
        Test.setMock(HttpCalloutMock.class, mock);
        mock.setExpected(200, '{"State":"NORMALIZED","Classification":"UNKNOWN","Attributes":[{"Name":"CountrySupported","Value":"true"},{"Name":"ZIP11Match","Value":"false"},{"Name":"SuiteRequiredButMissing","Value":"false"},{"Name":"InvalidSuiteNumber","Value":"false"},{"Name":"MultipleMatches","Value":"false"},{"Name":"PostalValidated","Value":"false"},{"Name":"GeneralDelivery","Value":"false"},{"Name":"StreetRangeValidated","Value":"false"},{"Name":"StreetValidated","Value":"false"},{"Name":"MissingOrAmbiguousDirectional","Value":"false"},{"Name":"CityStateValidated","Value":"false"},{"Name":"Resolved","Value":"false"},{"Name":"ZIP4Match","Value":"false"},{"Name":"DPV","Value":"false"}],"EffectiveAddress":{"Street1":"STREET1","Street2":null,"City":"CITY","StateProvince":"STATE","PostalCode":"ZIP","CountryCode":"US"}}');

		AddressValidation.Address addr = new AddressValidation.Address('Street1', 'Street2', 'City', 'State', 'Zip', 'US');

		Boolean error = false;
		AddressValidation.AddressValidationResult result;
		try { result = AddressValidation.validateAddress_ScanSource(addr); }
		catch (Exception e) { error = true; }
		System.assertEquals(false, error, 'Exception for 200');

		System.assertEquals(false, result.isValid(), 'Validity');

		addr = result.getAddress();
		System.assertEquals('STREET1', addr.Street1, 'Street1');
		System.assertEquals(null, addr.Street2, 'Street2');
		System.assertEquals('CITY', addr.City, 'City');
		System.assertEquals('', addr.StateProvince, 'StateProvince');
		System.assertEquals('ZIP', addr.PostalCode, 'PostalCode');
		System.assertEquals('US', addr.CountryCode, 'CountryCode'); 
	}

	@isTest static void validateAddress_ScanSource_missingsuite() {
        HttpMock mock = new HttpMock();
        Test.setMock(HttpCalloutMock.class, mock);
        mock.setExpected(200, '{"State":"STANDARDIZED","Classification":"MIXED","Attributes":[{"Name":"CountrySupported","Value":"true"},{"Name":"ZIP11Match","Value":"true"},{"Name":"SuiteRequiredButMissing","Value":"true"},{"Name":"InvalidSuiteNumber","Value":"false"},{"Name":"MultipleMatches","Value":"false"},{"Name":"Resolved","Value":"true"},{"Name":"ZIP4Match","Value":"true"},{"Name":"DPV","Value":"false"},{"Name":"ValidMultiUnit","Value":"false"},{"Name":"POBox","Value":"false"},{"Name":"MultiUnitBase","Value":"true"},{"Name":"StreetAddress","Value":"false"},{"Name":"POBoxOnlyZIP","Value":"false"},{"Name":"UniqueZIP","Value":"false"},{"Name":"SplitZIP","Value":"false"},{"Name":"RRConversion","Value":"false"}],"EffectiveAddress":{"Street1":"STREET1","Street2":null,"City":"CITY","StateProvince":"CO","PostalCode":"80004-1394","CountryCode":"US"}}');

	/*	AddressValidation.Address addr = new AddressValidation.Address('Street1', 'Street2', 'City', 'State', 'Zip', 'US');

		Boolean error = false;
		AddressValidation.AddressValidationResult result;
		try { result = AddressValidation.validateAddress_ScanSource(addr); }
		catch (Exception e) { error = true; }
		System.assertEquals(false, error, 'Exception for 200');

		System.assertEquals(false, result.isValid(), 'Validity');

		addr = result.getAddress();
		System.assertEquals('STREET1', addr.Street1, 'Street1');
		System.assertEquals(null, addr.Street2, 'Street2');
		System.assertEquals('CITY', addr.City, 'City');
		System.assertEquals('CO', addr.StateProvince, 'StateProvince');
		System.assertEquals('80004-1394', addr.PostalCode, 'PostalCode');
		System.assertEquals('US', addr.CountryCode, 'CountryCode');  
	}

	@isTest static void validateAddress_ScanSource_standardized() {
        HttpMock mock = new HttpMock();
        Test.setMock(HttpCalloutMock.class, mock);
        mock.setExpected(200, '{"State":"STANDARDIZED","Classification":"RESIDENTIAL","Attributes":[{"Name":"CountrySupported","Value":"true"},{"Name":"ZIP11Match","Value":"true"},{"Name":"SuiteRequiredButMissing","Value":"false"},{"Name":"InvalidSuiteNumber","Value":"false"},{"Name":"MultipleMatches","Value":"false"},{"Name":"Resolved","Value":"true"},{"Name":"ZIP4Match","Value":"true"},{"Name":"DPV","Value":"true"},{"Name":"ValidMultiUnit","Value":"true"},{"Name":"POBox","Value":"false"},{"Name":"MultiUnitBase","Value":"false"},{"Name":"StreetAddress","Value":"true"},{"Name":"POBoxOnlyZIP","Value":"false"},{"Name":"UniqueZIP","Value":"false"},{"Name":"SplitZIP","Value":"false"},{"Name":"RRConversion","Value":"false"}],"EffectiveAddress":{"Street1":"STREET1","Street2":"UNIT1","City":"CITY","StateProvince":"CO","PostalCode":"80004-1394","CountryCode":"US"}}');

	/*	AddressValidation.Address addr = new AddressValidation.Address('Street1', 'Street2', 'City', 'State', 'Zip', 'US');

		Boolean error = false;
		AddressValidation.AddressValidationResult result;
		try { result = AddressValidation.validateAddress_ScanSource(addr); }
		catch (Exception e) { error = true; }
		System.assertEquals(false, error, 'Exception for 200');

		System.assertEquals(true, result.isValid(), 'Validity');

		addr = result.getAddress();
		System.assertEquals('STREET1', addr.Street1, 'Street1');
		System.assertEquals('UNIT1', addr.Street2, 'Street2');
		System.assertEquals('CITY', addr.City, 'City');
		System.assertEquals('CO', addr.StateProvince, 'StateProvince');
		System.assertEquals('80004-1394', addr.PostalCode, 'PostalCode');
		System.assertEquals('US', addr.CountryCode, 'CountryCode');   
	}

	@isTest static void validateAddress_ScanSource_raw() {
        HttpMock mock = new HttpMock();
        Test.setMock(HttpCalloutMock.class, mock);
        mock.setExpected(200, '{"State":"RAW","Classification":"UNKNOWN","Attributes":[{"Name":"CountrySupported","Value":"false"}],"EffectiveAddress":{"Street1":"STREET1","Street2":"STREET2","City":"CITY","StateProvince":"AG","PostalCode":"ZIP","CountryCode":"AM"}}');

		AddressValidation.Address addr = new AddressValidation.Address('Street1', 'Street2', 'City', 'State', 'Zip', 'US');

		Boolean error = false;
		AddressValidation.AddressValidationResult result;
		try { result = AddressValidation.validateAddress_ScanSource(addr); }
		catch (Exception e) { error = true; }
		System.assertEquals(false, error, 'Exception for 200');

		System.assertEquals(true, result.isValid(), 'Validity');

		addr = result.getAddress();
		System.assertEquals('STREET1', addr.Street1, 'Street1');
		System.assertEquals('STREET2', addr.Street2, 'Street2');
		System.assertEquals('CITY', addr.City, 'City');
		System.assertEquals('AG', addr.StateProvince, 'StateProvince');
		System.assertEquals('ZIP', addr.PostalCode, 'PostalCode');
		System.assertEquals('AM', addr.CountryCode, 'CountryCode'); 
	} */

}