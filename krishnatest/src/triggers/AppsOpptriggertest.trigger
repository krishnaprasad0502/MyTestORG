trigger AppsOpptriggertest on Opportunity (before update) {
	string Name;
	list<Opportunity> listOppor = new list<Opportunity>();	
	Set<Id> contactsIds = new Set<Id>();
	Set<Id> AccountIds = new Set<Id>();
	for (Opportunity op : Trigger.old) {
		   contactsIds.add(op.Contact__c);
		   accountIds.add(op.AccountId);
	}
	Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Name FROM Account WHERE Id IN :accountIds]);
	Map<Id, Contact> ContactMap = new Map<Id, Contact>([SELECT Name, LastName FROM Contact WHERE Id IN :contactsIds]);
	for (Opportunity opp : Trigger.new) {
		if (Trigger.isUpdate) { 
			if (opp.StageName != Trigger.oldMap.get(opp.Id).StageName) { 			
				Name = Trigger.oldMap.get(opp.Id).Name;
				String[] parts = Name.split('-');
				system.debug('parts-'+parts[0]+parts[1]+parts[2]);
				String part1 = parts[0]; 
				String part2 = parts[1]; 
				String part3 = parts[2]; 
				//String part4 = parts[3]; 
				//opp.Name = part1+'-'+opp.StageName+'-'+part3+'-'+part4;
				opp.Name = opp.StageName+'-'+part2+'-'+part3;					
			} 
		if (Trigger.isInsert || Trigger.isUpdate) {
				 if(opp.StageName == 'Closed/Won' && opp.RecordTypeId  == '012i0000000Hrcv' && (opp.Type  == 'Design' ||   opp.Type  == 'Breeding' )) 
				 {
				     Opportunity oppNew = new Opportunity();
					//name the opportunity and assign the fields
					//oppNew.name = 'Opportunity Name'; 
					//oppNew.RecordTypeId = '';
					oppNew.StageName = 'Needs Analysis';	
					oppNew.ownerId = Trigger.oldMap.get(opp.Id).OwnerId;
					oppNew.Type  = 'Management';
					oppNew.Contact__c = Trigger.oldMap.get(opp.Id).Contact__c;
					oppNew.AccountId  = Trigger.oldMap.get(opp.Id).AccountId ;
					string oaName = accountMap.get(oppNew.AccountId).Name;
					string ocName = ContactMap.get(oppNew.Contact__c).Name;
					//oppNew.Product_Family__c = Trigger.oldMap.get(opp.Id).Product_Family__c;
					//oppNew.Name = oppNew.Product_Family__c+'-'+oppNew.StageName+'-'+oaName+'-'+ocName;
					oppNew.Name = oppNew.StageName+'-'+oaName+'-'+ocName;										
				    listOppor.add(oppNew);
			       }
			    if(listOppor.size() > 0)
			     insert listOppor;  				
			 }				
			
		}
	}	
}