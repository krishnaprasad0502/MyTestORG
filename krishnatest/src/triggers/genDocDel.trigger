trigger genDocDel on General_Dcouments__c (before delete) { 
             list<Id> lstProductId = new list<Id>();
                 List<String> lstGDId = new List<String>();       
            for(General_Dcouments__c newAsset:Trigger.old){
                //if(!lstProductId.contains(newAsset.Id)){
                    lstProductId.add(newAsset.Id);
                //}               
            }            
             system.debug('lstProductId::: '+lstProductId);
             String keyV = String.valueOf(lstProductId).substring(1,16 );
             lstGDId.add(keyV);         
             list<File_Information__c > lstFInfo =   [Select id,Record_ID__c  From File_Information__c where Status__c = 'Uploaded' and Record_ID__c IN: lstGDId ];
             try{
             if(lstFInfo != null && lstFInfo.size() > 0){
              for (General_Dcouments__c FolderTrigger: trigger.old){                
                	FolderTrigger.addError('Error: please Delete Files in Attachment section ');
           			 }
             }else{
             	
             }
             }catch(Exception ex){
        System.debug('case Trigger exception ::: '+ex.getMessage());
    }
}