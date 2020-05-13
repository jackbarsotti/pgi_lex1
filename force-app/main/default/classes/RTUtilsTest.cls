@isTest
public class RTUtilsTest {
    public  static testMethod void  testdateInRange(){
       /* Date d = date.today();
        Date startDate = date.today();
        Date endDate = date.today().addDays(1);
        boolean inclusiveStart = true;
        boolean inclusiveEnd = true;*/
        
        RTUtils.dateInRange( date.today(),  date.today(),  date.today().addDays(1),  true,  false);
        RTUtils.dateInRange( date.today(),  date.today(),  null,  false,  true);
        RTUtils.dateInRange( date.today(),  date.today(),  date.today().addDays(1),  true,  true);
        RTUtils.dateInRange( Date.today().addDays(2),  Date.today(),  null,  false,  false);
        RTUtils.dateInRange(Date.today().addDays(2),Date.today(),null);    
        RTUtils.dateInRange(Date.today(),Date.today(),Date.today().addDays(-2));
        System.assertEquals(true, RTUtils.dateInRange( date.today(),  date.today(),  date.today().addDays(1),  true,  false));

        RTUtils.dateIsBefore(Date.today(),Date.today().addDays(2));
        RTUtils.dateIsBefore(Date.today().addDays(2),Date.today());
        System.assertEquals(false, RTUtils.dateIsBefore(Date.today().addDays(2),Date.today()));

        RTUtils.formatDateSafe(Date.today(),'test');
        RTUtils.formatDateSafe(null,'test');
        System.assertEquals('test', RTUtils.formatDateSafe(null,'test'));
        
    }
}