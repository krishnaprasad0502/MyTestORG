@istest 
public class genDocDelTest {
    static testmethod void unittest(){
        
        
          
       Account objAccount=new Account();
        objAccount.Name='TestAccount';       
        insert objAccount;
        Account insertedAcct = [Select id,name from Account where name =: 'TestAccount'];
        system.assertEquals('TestAccount',insertedAcct.Name);
          General_Dcouments__c genDoc = new General_Dcouments__c();
             genDoc.Name = 'softDoc';
            
             genDoc.versoins__c = genDoc.id;
             genDoc.Order_id__c = '1';
             genDoc.Product_Group_Name__c = 'test1';
        insert genDoc;        
        String keyV = String.valueOf(genDoc.id).substring(0, (String.valueOf(genDoc.id).length()-3));    
           File_Information__c f = new File_Information__c();
             f.Name = 'testfile.txt';
             f.Filesize__c = '10 KB';
             f.Filepath__c = 'testbf123/Account/'+insertedAcct.id;
             f.Content_type__c = 'txt';
             f.Object_Name__c = 'Account';
             f.Record_Id__c = keyV;
              insert f;
             

    list<File_Information__c > fileIn =   [Select name  From File_Information__c where name ='testfile.txt' ];
     if(fileIn  != null && fileIn.size()>0){
                delete fileIn ;
              }  
              
                  list<General_Dcouments__c > DocIn =   [Select name  From General_Dcouments__c where name ='softDoc' ];
     if(DocIn  != null && DocIn.size()>0){
                delete DocIn ;
              }  
    }
}