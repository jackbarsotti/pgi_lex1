public class IST_NCS_CSV_Controller {

  /*  public String filename {
        get {
            String fn = '';
            if (this.forAddresses) fn = 'Addresses';
            if (!this.forAddresses) fn = 'None';
            return fn;
        }
        private set;
    }

    public Boolean forAddresses {get;set;}

   public List<Address__c> addresses {get;set;}

    public String header {
        get {
            if (forAddresses) return 'Name,Recipient,Street 1,Street 2,City,State,Postal Code,Country';
            
            return 'Neither CPEs nor Addresses were specified for exporting';
        }
        private set;
    }

    public List<String> rows {
        get {
            List<String> rs = new List<String>();
            if (forAddresses) {
                rs = new List<String>();
                for (Address__c addr : addresses) {
                    String r = '\n';

                    if (addr.Name != null) r += addr.Name.escapeCsv();
                    r += ',';

                    if (addr.Recipient_Name__c != null) r += addr.Recipient_Name__c.escapeCsv();
                    r += ',';

                    if (addr.Street_Address_1__c != null) r += addr.Street_Address_1__c.escapeCsv();
                    r += ',';

                    if (addr.Street_Address_2__c != null) r += addr.Street_Address_2__c.escapeCsv();
                    r += ',';

                    if (addr.City__c != null) r += addr.City__c.escapeCsv();
                    r += ',';

                    if (addr.State__c != null) r += addr.State__c.escapeCsv();
                    r += ',';

                    if (addr.Postal_Code__c != null) r += addr.Postal_Code__c.escapeCsv();
                    r += ',';

                    if (addr.Country__c != null) r += addr.Country__c.escapeCsv();

                    rs.add(r);
                }
            }
            return rs;
        }
        private set;
    } 

	private final Implementation_Services__c ISRecord;

    public IST_NCS_CSV_Controller(ApexPages.StandardController stdController) {
        this.ISRecord = (Implementation_Services__c)stdController.getRecord();

        this.forAddresses = false;

        Map<String, String> pageParams = ApexPages.currentPage().getParameters();
        if (pageParams.containsKey('address')) this.forAddresses = true;

    //    if (this.forAddresses) this.forAddresses = false;

       this.addresses = new List<Address__c>();

        if (this.forAddresses) {
            this.addresses = [SELECT Id, Name, Recipient_Name__c, Street_Address_1__c, Street_Address_2__c, City__c, Postal_Code__c, State__c, Country__c FROM Address__c ORDER BY CreatedDate DESC LIMIT 9000];
        }  
    }*/
}