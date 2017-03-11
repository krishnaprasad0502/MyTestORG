public class Listcontactcontroller {

//All variable decliration
public Contact contact{get;set;}
public Id Id{get;set;}


List<contactwrapper> contactList = new List<contactwrapper>();
List<Contact> selectedContacts = new List<Contact>();

public Listcontactcontroller(ApexPages.StandardController controller) {
Contact contact = new Contact();
}


//All contacts in a pageblock table
public List<contactwrapper> getContacts() {

for(Contact c: [select Id,Name,Account.Name,MobilePhone,Email from Contact order by createdDate desc ])

contactList.add(new contactwrapper(c));
return contactList;
}

// selected contacts

public PageReference getSelected() {

selectedContacts.clear();
for(contactwrapper conwrapper: contactList)
if(conwrapper.selected == true)
selectedContacts.add(conwrapper.con);

return null;
}


public List<Contact> GetSelectedContacts()
{
if(selectedContacts.size()>0)
return selectedContacts;
else
return null;
}
public PageReference massdelete() {

if(selectedContacts.size()>0){
delete selectedContacts;
}



else{
ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select at least one Contact.'));
return null;
}


PageReference listcontact=new PageReference('/apex/listcontact');
listcontact.setRedirect(true);
return listcontact;

}
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