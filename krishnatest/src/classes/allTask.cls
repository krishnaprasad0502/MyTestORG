//Krishna
public with sharing class allTask {
    public list<allTask_Wrapper> lstTASKWrapper {get;set;} 
    public allTask(ApexPages.StandardController controller){//Krishna
        List<Task> lstTask = [SELECT Subject,id FROM Task  ];  
        system.debug('lstTask ::::'+lstTask );     
        lstTASKWrapper  =  new list<allTask_Wrapper>(); 
        if(lstTask != null && lstTask.size() > 0){
            for(Task itrVar : lstTask){
                allTask_Wrapper objRecord = new allTask_Wrapper();
                objRecord.SLACName = itrVar.id;
                objRecord.SLAType = itrVar.Subject;             
                lstTASKWrapper.add(objRecord);
            }
        }
        system.debug('lstTASKWrapper::::'+lstTASKWrapper);
    }
    
    public class allTask_Wrapper{
        public String SLACName {get;set;}
        public String SLAType {get;set;}    
        public allTask_Wrapper(){
        }
    }
}