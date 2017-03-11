public class clsSearchContact
{
public string searchfiled{get;set;}
public list<contact> getconlist{get;set;}

public clsSearchContact()
{
    getconlist =new list<contact>();
    getconlist=database.query('Select name,phone,email,account.name,title,owner.name from contact limit 10');
}

public void searchcontact()
    {
         try
         {
         system.debug('@@@@@@@@searchfiled'+searchfiled);
         
           searchfiled= '%'+searchfiled+ '%';
             getconlist =new list<contact>();
             getconlist=database.query('Select name,phone,email,account.name,title,owner.name from contact  WHERE Name like :searchfiled limit 100');
           
         }
         catch(Exception e)
         {
             system.debug('Error'+e);
         }
    }
}