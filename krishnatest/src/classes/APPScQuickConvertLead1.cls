public class APPScQuickConvertLead1{ 
    public Boolean conselected { get; set; }
    public Boolean accselected { get; set; }
    

     /*
    *   The list of Account/Contact Wrappers
    */
    public List<ContactWrapper> contactList{get;set;}
    public List<AccountWrapper> accountList{get;set;}
       
    public id leadId {get;set;}    
    public Lead ldSource {get;set;}
       public map<id,Contact> conName = new map<id,Contact>() ;
     public map<id,Account> accName = new map<id,Account>() ;
 
    /*
    *   Controller
    */

    public APPScQuickConvertLead1(){
    
        //this.message = 'Please select one or more Contacts.';
        //initialize the ContactWrapper container
        this.contactList  = new List<ContactWrapper>();
        this.accountList  = new List<AccountWrapper>();
        leadId = ApexPages.currentPage().getParameters().get('param1');        
        //ldSource = [SELECT Id, FirstName, LastName, OwnerId, Company, Street, City, State,Product_Family__c, PostalCOde, Country, Phone, Fax,
                            //Status FROM Lead WHERE Id = : leadId ];      
        ldSource = [SELECT Id, FirstName, LastName, OwnerId, Company, Street, City, State, PostalCOde, Country, Phone, Fax,
                            Status FROM Lead WHERE Id = : leadId ];        
        loadContacts( ldSource);
        loadAccounts( ldSource.Company );
        //conselected = false;
        
    }
    
    public pagereference backToLead(){    
        system.debug('leadid---'+leadId );
        return new PageReference('/'+leadId );     
    }
    
    
    private void loadContacts(Lead ldSource){
        string strContactFirst = '%'+ldSource.FirstName+'%';
        string strContactLast = '%'+ldSource.LastName+'%';
        List<Contact> lsContact = [select Id ,FirstName,LastName,AccountId,Owner.Name,Name from Contact where (FirstName like : strContactFirst and LastName like :strContactLast)
                                   and AccountId = :[select Id from Account where Name like :ldSource.Company]];
         Integer counter = 1;
        //select 50 contacts for sample display
        //for(Contact c : [SELECT Id, FirstName, LastName, Email, Phone FROM Contact WHERE Name LIKE 'leadCompany%'  LIMIT 100]){
        for(Contact c : lsContact ){
        //for(Contact c : [SELECT Id, FirstName, LastName, Email, Phone FROM Contact LIMIT 5]){
            this.contactList.add( new ContactWrapper(c,counter) );  
            conName.put(c.id, c);
            Counter++; 
        } 
        system.debug('conselected ---+++--'+conselected );
        system.debug('contactList.isEmpty()---+++--'+contactList.isEmpty());
        if(contactList.isEmpty()){
        system.debug('conselected -----'+conselected );
        conselected = true;
        }
    }
    
    
     private void loadAccounts(string leadCompany){
      String strCompanyWildcard = '%' + leadCompany + '%';
         Integer counter = 1;
        //select 50 contacts for sample display
        List<Account> lstAcct = [SELECT Id, Name, Owner.Name FROM Account WHERE Name LIKE :strCompanyWildcard];
        for(Account a : lstAcct ){  
        //for(Account a : [SELECT Id, name FROM Account WHERE Name LIKE 'leadCompany%'  LIMIT 100]){
        //for(Account a : [SELECT Id, name FROM Account LIMIT 5]){         
             this.accountList.add( new AccountWrapper(a,  counter)); //add the account and counter to our list) );
             accName.put(a.id, a);
             counter++;             
        } 
        if(accountList.isEmpty()){
        system.debug('conselected -----'+accountList);
         accselected = true;
        }  
     }
     
     
       /*
    *   Process the record selection
    */

    public PageReference doProcessSelection(){
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
       
        
        system.debug('selectedconRecordID -----------'+selectedconRecordID );
        system.debug('selectedAccRecordID -----------'+selectedAccRecordID );
        
        Database.LeadConvert lc = new Database.LeadConvert();        
        lc.setLeadId(ldSource.Id);
        lc.setOwnerId(ldSource.OwnerId);
        if(selectedAccRecordID.length() > 1 && selectedconRecordID.length() < 1 )         {
        	 lc.setAccountId(selectedAccRecordID); 
        	 lc.setOpportunityName('Needs Analysis1'+'-'+accName.get(selectedAccRecordID ).Name+'-'+ldSource.FirstName+' '+ldSource.LastName);
        	 system.debug('++conName1+');
        	 }        	 
        else if(selectedconRecordID.length() > 1 && selectedAccRecordID.length() > 1) { 
            lc.setContactId(selectedconRecordID );
            lc.setAccountId(selectedAccRecordID); 
             system.debug('++selectedconRecordID +'+selectedconRecordID );
             system.debug('++conName+'+conName);
             system.debug('++conName2+');
            system.debug('++++'+conName.get(selectedconRecordID ).FirstName);
            lc.setOpportunityName('Needs Analysis2'+'-'+accName.get(selectedAccRecordID ).Name+'-'+conName.get(selectedconRecordID ).FirstName+' '+conName.get(selectedconRecordID ).LastName);
        }else{
        	system.debug('++conName3+');
             lc.setOpportunityName('Needs Analysis3'+'-'+ldSource.Company+'-'+ldSource.FirstName+' '+ldSource.LastName);
        }
        //lc.setOpportunityName(ldSource.Product_Family__c+'-'+
         //Product Family – Stage  - AccountProduct_Family__c Name – Primary Contact
         //lc.setOpportunityName(ldSource.Product_Family__c);\
         //lc.setOpportunityName(ldSource.Product_Family__c);\
         
        
         
         LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
         lc.setConvertedStatus(convertStatus.MasterLabel);
         
         
         // Convert!
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        system.debug('lcr ---+++'+lcr );
        
        // Mop up Opportunity
        //if(bolCreateOpp == true) {
        Opportunity o = new Opportunity(Id=lcr.getOpportunityId());
        Contact con = new Contact(Id=lcr.getcontactId());
        o.StageName= 'Needs Analysis';
        o.Contact__c = con.id;
        update o;
        //}
                
      
        return new PageReference('/'+o.id);
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
            this.numberOfRow = rowCounter; //assign row counter
            this.tAccount = a;
            this.id= a.id;  
            if (this.numberOfRow == 1){        
                this.selected = true;
                }else{
                this.selected = false;
                }
        }
       
    }
     

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
     
}