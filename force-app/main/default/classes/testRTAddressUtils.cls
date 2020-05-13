@isTest
private class testRTAddressUtils {
    static testMethod void testStateMappings() {
        new RTAddressUtils();
        
        String p1 = 'Wyoming';
        String p2 = 'Texas';
        String p3 = 'TX';
        String p4 = 'Foo';
        
        System.assert(RTAddressUtils.mapState(p1) == 'WY');
        System.assert(RTAddressUtils.mapState(p2) == 'TX');
        System.assert(RTAddressUtils.mapState(p3) == 'TX');
        System.assert(RTAddressUtils.mapState(p4) == null);
        System.assert(RTAddressUtils.mapState(null) == null);
        
    }
    
    static testMethod void testIsChanged() {
    	System.assert(RTAddressUtils.isChanged(null, 'hello'));
    	System.assert(RTAddressUtils.isChanged('hello', null));
    	System.assert(RTAddressUtils.isChanged('test1', 'test2'));
    	System.assert(!RTAddressUtils.isChanged('hello', 'hello'));
    }
    
    static testMethod void testCountryMappings() {
    	System.assert('UNITED STATES'.equals(RTAddressUtils.normalizeCountry('United States')));
    	System.assert('FOO'.equals(RTAddressUtils.normalizeCountry('foo')));
    	System.assert('UNITED STATES'.equals(RTAddressUtils.normalizeCountry('USA')));
    	System.assert('UNITED STATES'.equals(RTAddressUtils.normalizeCountry('UsA')));
    	System.assert('UNITED STATES'.equals(RTAddressUtils.normalizeCountry('US')));
    	System.assert('CANADA'.equals(RTAddressUtils.normalizeCountry('Can')));
    	System.assert(RTAddressUtils.normalizeCountry(null) == null);
    }
    
    static testMethod void testSyncState() {
      // test insert from Data.com scenario w/ case insensitive
      String master = RTAddressUtils.syncState(null, 'TeXas', null, null);
      System.assert('TX'.equals(master));
      
      // test insert from CC scenario w/ case insensitive
      master = RTAddressUtils.syncState(null, null, null, 'Texas');
      System.assert('TX'.equals(master));
      
      // test change from Data.com scenario w/ case insensitive
      master = RTAddressUtils.syncState('Tejas', 'Texas', 'foo', 'foo');
      System.assert('TX'.equals(master));
      
      // test update from AM scenario w/ case insensitive
      master = RTAddressUtils.syncState('OK', 'OK', 'OK', 'TX');
      System.assert('TX'.equals(master));
      
      // test both changed.
      master = RTAddressUtils.syncState('OK', 'AR', 'WI', 'TX');
      System.assert('TX'.equals(master));
      
      // test invalid.
      master = RTAddressUtils.syncState('OK', 'OK', 'OK', 'BLAHIDAHO');
      System.assert(master == null);
      
    }
    
    static testMethod void testGetLastChanged() {
      // test insert from Data.com scenario w/ case insensitive
      String master = RTAddressUtils.getLastChanged(null, 'foo', null, null);
      System.assert('foo'.equals(master));
      
      // test insert from CC scenario w/ case insensitive
      master = RTAddressUtils.getLastChanged(null, null, 'foo', null);
      System.assert(master == null);
      
      // test change from Data.com scenario w/ case insensitive
      master = RTAddressUtils.getLastChanged('Tejas', 'Texas', 'foo', 'foo');
      System.assert('Texas'.equals(master));
      
      // test update from AM scenario w/ case insensitive
      master = RTAddressUtils.getLastChanged('OK', 'OK', 'OK', 'TX');
      System.assert('TX'.equals(master));
      
      // test both changed.
      master = RTAddressUtils.getLastChanged('OK', 'AR', 'WI', 'TX');
      System.assert('TX'.equals(master));
      
    }
    
    static testMethod void testSplitStreetAddress() {
      StreetAddress test1 = RTAddressUtils.splitStreetAddress('asasdf asdfasdf asdfasdfasdf STE. 100 asdfas-asdfasdf sadfas sdfsdf');
      System.assert('asasdf asdfasdf asdfasdfasdf'.equals(test1.getAddress1()));
      System.assert('STE. 100 asdfas-asdfasdf sadfas sdfsdf'.equals(test1.getAddress2()));
      
      StreetAddress test2 = RTAddressUtils.splitStreetAddress('101 Mainste asdfasdf asdfasdf asdfasdfersf asfwegwe Ste 100');
      System.assert('101 Mainste asdfasdf asdfasdf'.equals(test2.getAddress1()));
      System.debug ('test2 - address2 = ""' + test2.getAddress2()+'""');
      System.assert(' asdfasdfersf asfwegwe Ste 100'.equals(test2.getAddress2()));
    	
    	StreetAddress test3 = RTAddressUtils.splitStreetAddress('101 Main Ste 100');
    	System.debug ('test3 - address1 = "' + test3.getAddress1()+'"');
      System.assert('101 Main Ste 100'.equals(test3.getAddress1()));
      System.assert(test3.getAddress2() == null);
    	
    }
    
}