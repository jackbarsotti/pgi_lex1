@isTest
private class testRTUtils {

  static testMethod void testDateInRange(){

    //In range assertions:
    //Assert: That 12/18/2013 is in 12/18/2013 - NULL when start is inclusive 
    System.assert(RTUtils.dateInRange(Date.parse('12/18/2013'), Date.parse('12/18/2013'), null, true, false) == true);

    //Assert: That 12/18/2013 is in 1/1/2013 - 12/18/2013 when end is inclusive
    System.assert(RTUtils.dateInRange(Date.parse('12/18/2013'), Date.parse('1/1/2013'), Date.parse('12/18/2013'), true, true) == true);

    //Not in range assertions:
    //Assert: That 12/18/2013 is NOT in 1/1/2013 - 12/18/2013 when end is exclusive
    System.assert(RTUtils.dateInRange(Date.parse('12/18/2013'), Date.parse('1/1/2013'), Date.parse('12/18/2013'), true, false) == false);
  }    
    
}