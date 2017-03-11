public class RowEditingcontroller {

     //All property....

     public Contact contact{get;set;}
     public Id Id{get;set;}
     List<contactwrapper> contactList = new List<contactwrapper>();
     List<Contact> selectedContacts = new List<Contact>();

     //constructor....

     public RowEditingcontroller(ApexPages.StandardController controller) {
    
         Contact contact = new Contact();

      }

     //displaying contact pageBlock table....
      
     public  List<contactwrapper> getContacts() {
    
        for(Contact c: [select Id,Name,Account.Name,MobilePhone,Email from Contact order by createdDate desc ])
     
              contactList.add(new contactwrapper(c));
              return contactList;
          }

       //all selected contacts...for edit...       
     public PageReference getSelected() {
    
         selectedContacts.clear();
         for(contactwrapper conwrapper: contactList) 
            if(conwrapper.selected == true)
       
            selectedContacts.add(conwrapper.con); 
       
            return null;
        }
        
        
     public List<Contact> GetSelectedContacts(){
    
        if(selectedContacts.size()>0)
        return selectedContacts;
        else
       // ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select at least one Contact.'));
        return null;
    } 
     
    //saving edited value...
   
      public PageReference tosave() { 
      if(selectedContacts.size()>0){
      
        update selectedContacts;
        PageReference RowEditing=new PageReference('/apex/RowEditing');
        RowEditing.setRedirect(true);
        return RowEditing;
        }
        else{
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select at least one Contact.'));
         return null;
        }
       
       }
    
    //wrapper class...
    
    public class contactwrapper
    {
        public Contact con{get; set;}
        public Boolean selected {get; set;}
        public contactwrapper(Contact c)
        {
            con = c;
            selected = false;
        }
    }
 }