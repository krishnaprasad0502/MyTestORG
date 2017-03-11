public with sharing class CCW_WrapperSampleController {
 
    /*
    *   The list of ContactWrappers
    */
    public List<ContactWrapper> contactList{get;set;}
    public List<AccountWrapper> accountList{get;set;}
        public List<integer> count{get;set;}
 
    /*
    *   Message displayed to the page
    */
    public String message{get;set;}
 
    /*
    *   Controller
    */
    public CCW_WrapperSampleController(){
 
        this.message = 'Please select one or more Contacts.';
 
        //initialize the ContactWrapper container
        this.contactList  = new List<ContactWrapper>();
        this.accountList  = new List<AccountWrapper>();
 
        loadContacts();
        loadAccounts();
 
    }
 
    /*
    *   Process the record selection
    */
    public void doProcessSelection(){
 
       List<Contact> selectedContacts = new List<Contact>();
       List<Account> selectedAccounts = new List<Account>();

        
        String selectedconRecordID = '' ;
        String selectedAccRecordID = '' ;
        //for(Contact con : selectedContacts) 
        for(ContactWrapper con: this.contactList)
        {
            system.debug('con^^^^^^^^^^^'+con);
            
            if(con.selected==true){
                 selectedconRecordID = con.id;
        }         
            
            
          
        }
           //for(Contact con : selectedContacts) 
        for(AccountWrapper acc: this.accountList)
        {
            system.debug('acc^^^^^^^^^^^'+acc);
             if(acc.selected==true){
                 selectedAccRecordID = acc.id;
        }         
            
           
        }
        contactList=null; // we need this line if we performed a write operation  because getContacts gets a fresh list now
         accountList=null; 
         this.message = 'You have selected '+selectedconRecordID +' records.';
        
        system.debug('selectedconRecordID -----------'+selectedconRecordID );
        system.debug('selectedAccRecordID -----------'+selectedAccRecordID );
        
        //return new PageReference('/'+selectedconRecordID );
        //return null;
 
    }
 
    /*
    *   Load contact records for display
    */
    private void loadContacts(){
         Integer counter = 1;
        //select 50 contacts for sample display
        for(Contact c : [SELECT Id, FirstName, LastName, Email, Phone FROM Contact LIMIT 10]){
 
            this.contactList.add( new ContactWrapper(c,counter) );
             counter++; 
        }
        
 
    }
    private void loadAccounts(){
 
        //select 50 contacts for sample display
       Integer counter = 1;
        for(Account a : [SELECT Id, name FROM Account LIMIT 10]){
 
            this.accountList.add( new AccountWrapper(a,  counter)); //add the account and counter to our list) );
           
            counter++; //increment the counter
 
        }
 
    }
 
    /*
    *   This wrapper class encapsulates a contact record.
    *   An additional property 'selected' tracks whether
    *   the record has been selected.
    */
    public class ContactWrapper{
 
        //the contact record
        public Contact tContact{get;set;}
        public id id{get;set;}
 
        //whether the record is selected
        public Boolean selected{get;set;}
          public Integer numberOfRow {get; set;} 
 
        /*
        *   Constructor
        *   initializes the Contact reference
        */
        public ContactWrapper(Contact c,Integer rowCounter){
            this.tContact = c;
            this.id= c.id;
            
            this.numberOfRow = rowCounter;
           
            if (this.numberOfRow == 1){        
            this.selected = true;
            }else{
            this.selected = false;
            }
             
             
            
        }
 
    }
    
    
      public class AccountWrapper{
 
        //the contact record
        public Account tAccount{get;set;}
        public id id{get;set;}
 
        //whether the record is selected
        public Boolean selected{get;set;}
         public Integer numberOfRow {get; set;} 
 
        /*
        *   Constructor
        *   initializes the Contact reference
        */
        public AccountWrapper(Account a, Integer rowCounter) {
           
            this.numberOfRow = rowCounter; //assign row cou
        
            this.tAccount = a;
            this.id= a.id;  
            if (this.numberOfRow == 1){        
            this.selected = true;
            }else{
            this.selected = false;
            }
             
            
        }
 
    }
 
}