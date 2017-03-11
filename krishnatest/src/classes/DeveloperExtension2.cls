global class DeveloperExtension2 {
      
    public DeveloperExtension2(ApexPages.StandardController controller){}

    @RemoteAction
    global static List<Contact> showContacts(String accName){
    
    
        accName = '%'+ accName+'%';
        List<Contact> lst_contacts = new List<Contact>([select id, name, email from contact where Account.Name = 'test']);
        return lst_contacts;
         
    }

       }