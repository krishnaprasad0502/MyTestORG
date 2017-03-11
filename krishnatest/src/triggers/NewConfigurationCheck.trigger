trigger NewConfigurationCheck on Configuration__c (before insert) {
    
    Map<String,String>  configFields = new Map<String,String>{'Organization_Name__c'=>'create','Organization_Name__c'=>'edit'};
            
    Configuration__c configObj = new Configuration__c();
            
    if(!SBcUtil.checkFieldAccessiblity(configObj,configFields)){
        configObj.addError('Insufficient access - Please contact your System Administrator.');
    }else{
        Integer  count = 0;
        count  = [select  count() from Configuration__c limit 100];
        
        for (Configuration__c objConfig : Trigger.new) {
            if(count > 0) {
                objConfig.addError('You can not add more than one configuration');
            }
        }
    }
}