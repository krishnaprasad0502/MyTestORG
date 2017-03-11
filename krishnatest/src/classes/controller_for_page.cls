public with sharing class controller_for_page {
  //******Filter Attributes**********
  public list<String> AlphaList {get; set;}
  public String AlphaFilter {get; set;}
  public String AccName {get;set;}
  public String SelectRating {get;set;}
  public String SelectPartner {get;set;}
  public String AccNumSFDC {get;set;}
  public String SAPAccNum {get;set;}
  public String StateCode {get;set;}
  public String PostalCode {get;set;}
  public String PhoneNum {get;set;}
  public String FaxNum {get;set;}
  //*******Harmonize Parameters********
  public Boolean AccNum {get;set;}
  public Boolean Addr {get;set;}
  public Boolean PhoneNo {get;set;}
  public Boolean FaxNo {get;set;}
  
  //public List<SFDCSAPDataDTO> lstSFDCSAP {get;set;}
  public List<Account> lstAccount {get;set;}
    public Integer ReviewCount {get;set;}
    public String harmonizeParam {get;set;}
  public ApexPages.StandardSetController setcon {get;set;}
  public String strQry {get;set;}
    
    public List<accountWrapper> display_list {get; set;} //list for all Account records and a row counter
    public List<String> current_list = new List<String>(); //list for holding many record Ids
    public List<String> next_list = new List<String>(); //list for holding record Ids that are after the current records
    public List<String> previous_list = new List<String>(); //list for holding record Ids that are before the current records
    Integer list_size = 5; //number of records to display on the page
    
    //initiates the controller and displays some initial data when the page loads
    public controller_for_page() {
        Integer record_counter = 0; //counter
        for (Account a : [SELECT Id FROM Account ORDER BY Name LIMIT 10000]) { //for a bunch of accounts
            if (record_counter < list_size) { //if we have not yet reached our maximum list size
                current_list.add(a.Id); //add the Id of the record to our current list
            } else { //otherwise, we reached our list size maximum
                next_list.add(a.Id); //add the Id to our next_list
            }
            record_counter++;
        }
    }
    
    public List<accountWrapper> getRecordsToDisplay() {
        Set<String> record_ids = new Set<String>(); //set for holding distinct Ids
        Boolean records_added = record_ids.addAll(current_list); //add all the records from our current_list list
        display_list = new List<accountWrapper>(); //set the display_list object to a new accountWrapper List
        Integer counter = 1; //row counter variable
        for (Account a : [SELECT AccountNumber, Id, Name, OwnerId, Phone, Site, Type FROM Account WHERE Id in : record_ids ORDER BY Name]) { //query for the details of the records you want to display
            display_list.add(new accountWrapper(a, counter)); //add the account and counter to our list
            counter++; //increment the counter
        }
        return display_list; //return the list of full records plus their row counter
    }
    
    public class accountWrapper {
        public Account act {get; set;} //Account object
        public Integer numberOfRow {get; set;} //row counter variable
        
        public accountWrapper(Account a, Integer rowCounter) {
            this.act = a; //assign account
            this.numberOfRow = rowCounter; //assign row counter
        }
    }
    
    public Integer getCurrentSize() {
        return current_list.size(); //number of record in current_list
    }
    
    public Integer getPrevSize() {
        return previous_list.size(); //number of record in previous_list
    }
    
    public Integer getNextSize() {
        return next_list.size(); //number of record in next_list
    }

}