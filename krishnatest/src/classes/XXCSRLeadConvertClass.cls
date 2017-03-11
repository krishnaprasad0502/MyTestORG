public class XXCSRLeadConvertClass {
public Lead ldSource {get;set;}
public Boolean bolCreateOpp {get;set;}
public String strAccountId {get;set;}
public String strContactId {get;set;}



//////////////////////////
// Constructors / GETers
//////////////////////////
public XXCSRLeadConvertClass(ApexPages.StandardController scMain) {



ldSource = [SELECT Id, FirstName, LastName, OwnerId, Company, Street, City, State, PostalCOde, Country, Phone, Fax,Status FROM Lead WHERE Id = '00Q9000000RrNhO'];
bolCreateOpp = false;

    
}

public List<SelectOption> getlstCompanyInfo() {

String strCompanyWildcard = '%' + ldSource.Company + '%';
List<Account> lstAcct = [SELECT Id, Name, Owner.Name FROM Account WHERE Name LIKE :strCompanyWildcard];

List<SelectOption> lstCompanies = new List<SelectOption>();

// Add New Account if not found
lstCompanies.add(new SelectOption('1','Create New Account: ' + ldSource.Company));

// Add found Accounts to SelectList
for(Account a : lstAcct) {
lstCompanies.add(new SelectOption(a.Id, 'Attach to Existing: ' + a.Name + ' (' + a.Owner.Name + ')'));
}

return lstCompanies;      
}

    public List<SelectOption> getlstContactInfo(){
       
       string strContactFirst = '%'+ldSource.FirstName+'%';
        string strContactLast = '%'+ldSource.LastName+'%';
        List<Contact> lsContact = [select Id ,FirstName,LastName,AccountId,Owner.Name from Contact where (FirstName like : strContactFirst and LastName like :strContactLast)
                                   and AccountId = :[select Id from Account where Name like :ldSource.Company]];
       List<SelectOption> lstContact = new List<SelectOption>();
       
        // Add New Contact if not found
lstContact.add(new SelectOption('1','Create New Contact: ' + ldSource.FirstName+''+ldSource.LastName));

// Add found Accounts to SelectList
for(Contact c : lsContact) {
lstContact.add(new SelectOption(c.Id, 'Attach to Existing: ' + c.FirstName +' '+c.LastName+ ' (' + c.Owner.Name + ')'));
    }
return lstContact;         
    }
//////////////////////////
// Action Methods
//////////////////////////

public void doNothing() {  }

public PageReference convertLead() {

//check if status = qualified and Approved
if (ldSource.Status == 'Qualified' ){


// Create LeadConvert object
Database.LeadConvert lc = new Database.LeadConvert();

        
lc.setLeadId(ldSource.Id);
lc.setOwnerId(ldSource.OwnerId);
if(strAccountId.length() > 1) { lc.setAccountId(strAccountId); }
if(strContactId.length() > 1) { lc.setContactId(strContactId); }
lc.setDoNotCreateOpportunity(bolCreateOpp);

// Set Opportunity Name
if(bolCreateOpp == true) { lc.setOpportunityName(ldSource.Company); }

// Set Lead Converted Status
LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
lc.setConvertedStatus(convertStatus.MasterLabel);



// Convert!
Database.LeadConvertResult lcr = Database.convertLead(lc);

// Mop up Opportunity
if(bolCreateOpp == true) {
Opportunity o = new Opportunity(Id=lcr.getOpportunityId());
update o;
}
// Redirect...
PageReference prResult;
if(lcr.isSuccess()) {
prResult = new PageReference('/' + lcr.getAccountId());
prResult.setRedirect(true);
return prResult;  
} else {
return null;
}
}else{
ldSource.addError('Lead cannot be converted without Lead status Qualified and Approved !'); 
      ldSource.addError('Please Go back to Lead screen to change status'); 
    }
   
return null;}
}