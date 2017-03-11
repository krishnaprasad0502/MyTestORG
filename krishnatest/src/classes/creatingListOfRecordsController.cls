public with sharing class creatingListOfRecordsController {
    
    public list<Account> accountList{get;set;}
    public list<Accountwrapper> accountwrapperList{get;set;}
    public Integer counter{get;set;}
    
    public creatingListOfRecordsController(){
           counter = 0;
           accountList = new list<Account>(); 
           accountwrapperList = new list<Accountwrapper>();
           for(Integer i=0;i<5;i++){
               Accountwrapper actWrap = new Accountwrapper(new Account()); 
               counter++;
               actWrap.counterWrap = counter;
               accountwrapperList.add(actWrap); 
               
           }
       
    }
    
    public PageReference addRow(){
        //accountList.add(new Account());
        Accountwrapper actWrap = new Accountwrapper(new Account()); 
        
        counter++;
        actWrap.counterWrap = counter; 
        accountwrapperList.add(actWrap); 
        return null;    
    }
    public PageReference removingRow(){
    
        Integer param = Integer.valueOf(Apexpages.currentpage().getParameters().get('index'));
        
        for(Integer i=0;i<accountwrapperList.size();i++){
            if(accountwrapperList[i].counterWrap == param ){
                accountwrapperList.remove(i);     
            }
        }
        
        
        counter--;
        return null;    
    }
    
    public PageReference saving(){
        list<Account> updateAccountList;
        updateAccountList = new list<Account>();
        if(!accountwrapperList.isEmpty()){
            for(Accountwrapper accountWrapper:accountwrapperList){
                updateAccountList.add(accountWrapper.account);
            }
        }
        if(!updateAccountList.isEmpty()){
            upsert updateAccountList;
        }
       ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info,'Record Saved Successfully.');
       ApexPages.addMessage(myMsg); 
        return null;
    }
    
    public class Accountwrapper{
        public Account account{get;set;}
        public Integer counterWrap{get;set;}
        
        public Accountwrapper(Account act){
            this.account = act;  
             
        }
    }
    
}