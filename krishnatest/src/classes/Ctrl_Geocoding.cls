public class Ctrl_Geocoding{
 
    public Account acc{get;set;}
     
    public Ctrl_Geocoding(ApexPages.StandardController con){
        acc = [select Id, Name, BillingLatitude, BillingLongitude, BillingCity,
                      BillingCountry, BillingPostalCode, BillingStreet, BillingState
               from Account
               where Id =: con.getId()];
    }
     
    public string getAddress(){
        return getValue(acc.BillingStreet) + getValue(acc.BillingCity) + getValue(acc.BillingCountry) 
             + getValue(acc.BillingState) + getValue(acc.BillingPostalCode);
    }
     
    public string getValue(string value){
        return (value == null)? '':value + ' ';
    }
     
    public PageReference saveAccount(){
        upsert acc;
        return null;
    }
     
}