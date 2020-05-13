public with sharing class RTAddressUtils {
	public static Integer MAX_ADDRESS_LENGTH = 30;
	public static String ADDRESS_PATTERN = '\\s(([Ss][Tt][Ee].*$)|([Ss][Uu][Ii][Tt][Ee].*$))';
	
	/* holds mappings for all known states and their abbrev. */
	private static Map<String, String> stateMap = new Map<String,String>();
	
	/* used to normalize some country name variations. */
	private static Map<String, String> countryMap = new Map<String, String>();

	static {
		stateMap.put('alabama','AL');
		stateMap.put('alaska','AK');
		stateMap.put('arizona','AZ');
		stateMap.put('arkansas','AR');
		stateMap.put('california','CA');
		stateMap.put('colorado','CO');
		stateMap.put('connecticut','CT');
		stateMap.put('delaware','DE');
		stateMap.put('district of columbia','DC');
		stateMap.put('washington dc','DC');
		stateMap.put('washington d.c.','DC');
		stateMap.put('florida','FL');
		stateMap.put('georgia','GA');
		stateMap.put('hawaii','HI');
		stateMap.put('idaho','ID');
		stateMap.put('illinois','IL');
		stateMap.put('indiana','IN');
		stateMap.put('iowa','IA');
		stateMap.put('kansas','KS');
		stateMap.put('kentucky','KY');
		stateMap.put('louisiana','LA');
		stateMap.put('maine','ME');
		stateMap.put('maryland','MD');
		stateMap.put('massachusetts','MA');
		stateMap.put('michigan','MI');
		stateMap.put('minnesota','MN');
		stateMap.put('mississippi','MS');
		stateMap.put('missouri','MO');
		stateMap.put('montana','MT');
		stateMap.put('nebraska','NE');
		stateMap.put('nevada','NV');
		stateMap.put('new hampshire','NH');
		stateMap.put('new jersey','NJ');
		stateMap.put('new mexico','NM');
		stateMap.put('new york','NY');
		stateMap.put('north carolina','NC');
		stateMap.put('north dakota','ND');
		stateMap.put('ohio','OH');
		stateMap.put('oklahoma','OK');
		stateMap.put('oregon','OR');
		stateMap.put('pennsylvania','PA');
		stateMap.put('puerto rico','PR');
		stateMap.put('rhode island','RI');
		stateMap.put('south carolina','SC');
		stateMap.put('south dakota','SD');
		stateMap.put('tennessee','TN');
		stateMap.put('texas','TX');
		stateMap.put('utah','UT');
		stateMap.put('vermont','VT');
		stateMap.put('virginia','VA');
		stateMap.put('washington','WA');
		stateMap.put('west virginia','WV');
		stateMap.put('wisconsin','WI');
		stateMap.put('wyoming','WY');
		stateMap.put('alberta','AB');
		stateMap.put('british columbia','BC');
		stateMap.put('manitoba','MB');
		stateMap.put('new brunswick','NB');
		stateMap.put('newfoundland and labrador','NL');
		stateMap.put('newfoundland & labrador','NL');
		stateMap.put('newfoundland/labrador','NL');
		stateMap.put('labrador','NL');
		stateMap.put('newfoundland','NL');
		stateMap.put('northwest territories','NT');
		stateMap.put('nova scotia','NS');
		stateMap.put('nunavut','NU');
		stateMap.put('ontario','ON');
		stateMap.put('prince edward island','PE');
		stateMap.put('quebec','QC');
		stateMap.put('saskatchewan','SK');
		stateMap.put('yukon','YT');
		stateMap.put('al','AL');
		stateMap.put('ak','AK');
		stateMap.put('az','AZ');
		stateMap.put('ar','AR');
		stateMap.put('ca','CA');
		stateMap.put('co','CO');
		stateMap.put('ct','CT');
		stateMap.put('de','DE');
		stateMap.put('dc','DC');
		stateMap.put('fl','FL');
		stateMap.put('ga','GA');
		stateMap.put('hi','HI');
		stateMap.put('id','ID');
		stateMap.put('il','IL');
		stateMap.put('in','IN');
		stateMap.put('ia','IA');
		stateMap.put('ks','KS');
		stateMap.put('ky','KY');
		stateMap.put('la','LA');
		stateMap.put('me','ME');
		stateMap.put('md','MD');
		stateMap.put('ma','MA');
		stateMap.put('mi','MI');
		stateMap.put('mn','MN');
		stateMap.put('ms','MS');
		stateMap.put('mo','MO');
		stateMap.put('mt','MT');
		stateMap.put('ne','NE');
		stateMap.put('nv','NV');
		stateMap.put('nh','NH');
		stateMap.put('nj','NJ');
		stateMap.put('nm','NM');
		stateMap.put('ny','NY');
		stateMap.put('nc','NC');
		stateMap.put('nd','ND');
		stateMap.put('oh','OH');
		stateMap.put('ok','OK');
		stateMap.put('or','OR');
		stateMap.put('pa','PA');
		stateMap.put('pr','PR');
		stateMap.put('ri','RI');
		stateMap.put('sc','SC');
		stateMap.put('sd','SD');
		stateMap.put('tn','TN');
		stateMap.put('tx','TX');
		stateMap.put('ut','UT');
		stateMap.put('vt','VT');
		stateMap.put('va','VA');
		stateMap.put('wa','WA');
		stateMap.put('wv','WV');
		stateMap.put('wi','WI');
		stateMap.put('wy','WY');
		stateMap.put('ab','AB');
		stateMap.put('bc','BC');
		stateMap.put('mb','MB');
		stateMap.put('nb','NB');
		stateMap.put('nl','NL');
		stateMap.put('nt','NT');
		stateMap.put('ns','NS');
		stateMap.put('nu','NU');
		stateMap.put('on','ON');
		stateMap.put('pe','PE');
		stateMap.put('qc','QC');
		stateMap.put('sk','SK');
		stateMap.put('yt','YT');
    
    countryMap.put('usa', 'UNITED STATES');
    countryMap.put('us', 'UNITED STATES');
    countryMap.put('america', 'UNITED STATES');
    countryMap.put('u.s.a.', 'UNITED STATES');
    countryMap.put('can', 'CANADA');
	}

  /**
   * Takes in a state name or 2 letter code and returns the mapped 2 letter code.
   * returns null if there is no match (case insensitive)
   */
  public static String mapState(String stateName) {
  	if (stateName != null) {
  	  return stateMap.get(stateName.toLowerCase());
  	} else {
  		return stateName;
  	}
  }
  
  /**
  * Checks to see if the country name is one of the pre-defined aliases that 
  * needs to be mapped, otherwise returns the value in all upper case.
  */
  public static String normalizeCountry(String countryName) {
  	if (countryName != null) {
	  	if (countryMap.containsKey(countryName.toLowerCase())) {
	  		return countryMap.get(countryName.toLowerCase());
	  	}
	  	return countryName.toUpperCase();
  	} else {
  	  return countryName;
  	}
  }
  
  /**
  * Encapsulates the rules for choosing which field values to sync to all fields. If nothing is changed
  * will return the customNew field.
  */
  public static String syncState(String stdOld, String stdNew, String customOld, String customNew) {
  	if (isChanged(customOld, customNew)) {
  		return mapState(customNew);
  	} else if (isChanged(stdOld, stdNew)) {
    	return mapState(stdNew);
    }
    return customNew;
  }
  
  /**
  * Encapsulates the rules for choosing which field values to sync to all fields. If nothing is changed
  * will return the customNew field.
  */
  public static String getLastChanged(String stdOld, String stdNew, String customOld, String customNew) {
  	if (isChanged(customOld, customNew)) {
      return customNew;
    } else if (isChanged(stdOld, stdNew)) {
      return stdNew;
    }
    return customNew;
  }
  
  /**
  * Helper method to see if two values have changed. Will handle null values.
  */
  public static boolean isChanged(String oldValue, String newValue) {
  	if (oldValue == null && newValue != null) {
  		return true;
  	}
  	if (oldValue != null && newValue == null) {
  		return true;
  	}
  	if (oldValue == null && newValue == null) {
  		return false;
  	}
  	if (!newValue.equals(oldValue)) {
  		return true;
  	}
  	return false;
  }
  
  // This does not cover all cases (meaning address1 could still be longer than 30 chars.)
  public static StreetAddress splitStreetAddress(String oldValue) {
  	StreetAddress addr = new StreetAddress();
  	addr.setAddress1(oldValue);
      
  	if (oldValue != null && oldValue.length() > MAX_ADDRESS_LENGTH) {
  		    
      Pattern myPattern = Pattern.compile(ADDRESS_PATTERN);
      Matcher myMatcher = myPattern.matcher(oldValue);
    
  		while (myMatcher.find()) {
  			addr.setAddress2(myMatcher.group(1));
  			addr.setAddress1(oldValue.substring(0, myMatcher.start()));
  		}
  		
  		// So if it doesn't split or after split address 1 is still too long
  		// crop it to 30 chars on whitespace.
  		if (addr.getAddress1().length() > MAX_ADDRESS_LENGTH) {
  		  Pattern whitespacePattern = Pattern.compile('\\s');
  		  Matcher whitespaceMatcher = whitespacePattern.matcher(oldValue);
  			Integer index = oldValue.length();
  			while (whitespaceMatcher.find()) {
  				if (whitespaceMatcher.start() < MAX_ADDRESS_LENGTH) {
  					index = whitespaceMatcher.start();
  				}
  			}
  			addr.setAddress1(oldValue.substring(0, index));
  			addr.setAddress2(oldValue.substring(index));
  		}
  	}
  	return addr;
  }
  
 
  
  
}