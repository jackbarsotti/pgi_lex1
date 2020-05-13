public class AddressValidation {

    /* Exception to throw when expectations are invalid */
    public class InvalidException extends Exception {}
    /* Exception to throw when endpoints fail */
    public class EndpointException extends Exception {}

    public static String formatException(Exception e) {
        return e.getTypeName() + ' (Line ' + e.getLineNumber() + ')' + ': ' + e.getMessage() + '\n' + e.getStackTraceString();
    }

	public class Address {
		public String Street1;
		public String Street2;
		public String City;
		public String StateProvince;
		public String PostalCode;
		public String CountryCode;

		public Address(String street1, String street2, String city, String stateProvince, String postalCode, String countryCode) {
			this.Street1 = street1;
			this.Street2 = street2;
			this.City = city;
			this.StateProvince = stateProvince;
			this.PostalCode = postalCode;
			this.CountryCode = countryCode;
			if (!checkCountry()) throw new InvalidException('Country Codes must be ISO-3166 2-digit values');
		}

	/*	public Address(Address__c addr) {
			this.Street1 = addr.Street_Address_1__c;
			this.Street2 = addr.Street_Address_2__c;
			this.City = addr.City__c;
			this.StateProvince = addr.State__c;
			this.PostalCode = addr.Postal_Code__c;
			this.CountryCode = addr.Country__c;
			if (!checkCountry()) throw new InvalidException('Country Codes must be ISO-3166 2-digit values');
		} */

		public Boolean checkCountry() {
			return CountryCode != null && CountryCode.length() == 2 && ISO3166_Countries.countryCodes.containsKey(CountryCode);
		}

	/*  	public Address__c toObject() {     
			Address__c addr = new();     
			addr.Street_Address_1__c = this.Street1;
			addr.Street_Address_2__c = this.Street2;
			addr.City__c = this.City;
			addr.State__c = this.StateProvince;
			addr.Postal_Code__c = this.PostalCode;
			addr.Country__c = this.CountryCode;
			return addr;
		}  */

		public String toJSON() {
			return JSON.serialize(this);
		}
	}  

	public abstract class AddressValidationResult {
		public abstract Boolean isValid();
		public abstract Address getAddress();
		public abstract Map<String, String> getInfo();
	}

	public class SSAddressValidationResponse extends AddressValidationResult {
		public String State;
		public Address EffectiveAddress;
		public List<Map<String, String>> Attributes;

		public SSAddressValidationResponse() {}

		public override Boolean isValid() {
			Map<String, String> results = this.getInfo();
			if (!getInfo(results, 'CountrySupported', true)) return true;

			if (!getInfo(results, 'Resolved', true)) return false;
			if (getInfo(results, 'SuiteRequiredButMissing', false)) return false;

			if (this.State == 'STANDARDIZED')
				return true;

			return false;
		}

		public override Address getAddress() {
			String theirSubdivisionCode = this.EffectiveAddress.StateProvince;
			String theirCountryCode = this.EffectiveAddress.CountryCode;

			
		/*		Sometimes, the endpoint will return localized names instead of subdivision codes
				If we cannot find the actual code based on the name or code,
				Then blank it out to prevent issues with later systems expected codes */
			
			if (!ISO3166_Subdivisions.subdivisionCodes.containsKey(theirSubdivisionCode) && !ISO3166_Subdivisions.subdivisionCodes.containsKey(theirCountryCode + '-' + theirSubdivisionCode)) {
				String subdivisionCode = getSubdivisionCode(theirCountryCode, theirSubdivisionCode);
				if (subdivisionCode != '' && subdivisionCode != theirSubdivisionCode)
					this.EffectiveAddress.StateProvince = subdivisionCode;
				else
					this.EffectiveAddress.StateProvince = '';
			}

			return this.EffectiveAddress;
		}  

		public override Map<String, String> getInfo() {
			Map<String, String> info = new Map<String, String>();
			info.put('Result', this.State);
			if (this.Attributes != null) {
				for (Map<String, String> attr : this.Attributes)
					if (attr.containsKey('Name') && attr.containsKey('Value'))
						info.put(attr.get('Name'), attr.get('Value'));
			}
			return info;
		}

		private Boolean getInfo(Map<String, String> info, String key, Boolean fallback) {
			Boolean result = fallback;
			if (info.containsKey(key))
				result = info.get(key) == 'true';
			return result;
		}
	}

	public AddressValidation() {}

	/* Simple lookup for name, or blank if none found */
	public static String getCountryName(String countryCode) {
		if (countryCode == null) countryCode = '';
		if (ISO3166_Countries.countryCodes.containsKey(countryCode))
			return ISO3166_Countries.countryCodes.get(countryCode);
		else
			return 'INVALID CODE: ' + countryCode;
	}

	/* Value-search for code, or input if none found */
	public static String getCountryCode(String countryName) {
		if (countryName == null) countryName = '';
		if (ISO3166_Countries.countryCodes.containsKey(countryName))
			return countryName;
		else {
			for (String countryCode : ISO3166_Countries.countryCodes.keySet()) {
				if (ISO3166_Countries.countryCodes.get(countryCode) == countryName)
					return countryCode;
			}
			return countryName;
		}
	}

	/* Simple lookup for the Alpha-3 code, or blank if none found */
	public static String getAlpha3(String countryCode) {
		if (countryCode == null) countryCode = '';
		if (ISO3166_Countries.countryCodesToAlpha3.containsKey(countryCode))
			return ISO3166_Countries.countryCodesToAlpha3.get(countryCode);
		else
			return 'INVALID CODE: ' + countryCode;
	}

	/* Simple lookup for the Numeric code, or blank if none found */
	public static String getNumeric(String countryCode) {
		if (countryCode == null) countryCode = '';
		if (ISO3166_Countries.countryCodesToNumeric.containsKey(countryCode))
			return ISO3166_Countries.countryCodesToNumeric.get(countryCode);
		else
			return 'INVALID CODE: ' + countryCode;
	}

	/* Simple lookup for name, or blank if none found */
	public static String getSubdivisionName(String subdivisionCode) {
		if (subdivisionCode == null) subdivisionCode = '';
		if (ISO3166_Subdivisions.subdivisionCodes.containsKey(subdivisionCode))
			return ISO3166_Subdivisions.subdivisionCodes.get(subdivisionCode);
		else
			return 'INVALID CODE: ' + subdivisionCode;
	}

	/* Value-search for code, or input if none found */
	public static String getSubdivisionCode(String countryCode, String subdivisionName) {
		if (countryCode == null || countryCode == '') return '';
		if (subdivisionName == null || subdivisionName == '') return '';
		if (ISO3166_Subdivisions.subdivisionCodes.containsKey(countryCode + '-' + subdivisionName))
			return subdivisionName;
		else {
			for (String subdivisionCode : ISO3166_Subdivisions.subdivisionCodes.keySet()) {
				if (subdivisionCode.startsWith(countryCode) && ISO3166_Subdivisions.subdivisionCodes.get(subdivisionCode) == subdivisionName) {
					String shortSubdivision = subdivisionCode;
					if (shortSubdivision != null && shortSubdivision.contains('-') && shortSubdivision.length() > 3)
						shortSubdivision = shortSubdivision.substring(3);
					return shortSubdivision;
				}
			}
			return subdivisionName;
		}
	}

	/*
		Simple lookup of Subdivisions by CountryCode
		INVALID CODE for non-existant CountryCode
		Single N/A result for no results
		Cleaning of CC- beginning of SubdivisionCodes
	 */
	public static Map<String, String> getCountrySubdivisions(String countryCode) {
		if (countryCode == null) countryCode = '';
		Map<String, String> results = new Map<String, String>();
		if (!ISO3166_Countries.countryCodes.containsKey(countryCode)) {
			results.put('', 'INVALID CODE: ' + countryCode);
		} else if (ISO3166_Subdivisions.countrySubdivisions.containsKey(countryCode)) {
			for (String subdivision : ISO3166_Subdivisions.countrySubdivisions.get(countryCode)) {
				String shortSubdivision = subdivision;
				if (shortSubdivision != null && shortSubdivision.contains('-') && shortSubdivision.length() > 3)
					shortSubdivision = shortSubdivision.substring(3);
				if (ISO3166_Subdivisions.subdivisionCodes.containsKey(subdivision)) {
					results.put(shortSubdivision, ISO3166_Subdivisions.subdivisionCodes.get(subdivision));
				} else {
					results.put(shortSubdivision, subdivision);
				}
			}
		} else {
			results.put('', 'N/A');
		}
		return results;
	}

    /*
    	Using a generic Address class, check ScanSource's API for validity
    	Returns an updated address (or the original if no updates) and a validity flag
     */
    public static AddressValidationResult validateAddress_ScanSource(Address addrToCheck) {
        if (addrToCheck == null)
            throw new InvalidException('Null Address');

        iContract_Custom_Settings__c settings = iContract_Custom_Settings__c.getInstance();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://services.scansource.com/api/address/validate');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Accept', 'application/json');
        if (!Test.isRunningTest()) request.setHeader('Ocp-Apim-Subscription-Key', settings.ScanSource_API_Key__c);
        request.setBody(addrToCheck.toJSON());

        HttpResponse response = new Http().send(request);
        if (response.getStatusCode() == 403)
            throw new EndpointException('The ScanSource API Key is not working, please update the "iContract Settings" Custom Setting with a valid ScanSource API Key.');
        if (response.getStatusCode() != 200)
            throw new EndpointException(response.getStatusCode() + ': ' + response.getBody());

        SSAddressValidationResponse addrResponse;
        try {
        	addrResponse = (SSAddressValidationResponse)JSON.deserialize(response.getBody(), SSAddressValidationResponse.class);
        } catch (Exception e) {
            throw new EndpointException('Unable to parse response:\n' + response.getBody() + '\n' + formatException(e));
        }
        return addrResponse;
    }
}