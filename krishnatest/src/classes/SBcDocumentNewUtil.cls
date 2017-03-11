global with sharing class  SBcDocumentNewUtil{  

     private static Map <Id, General_Dcouments__c> generalDcoumentsMap; 
    private static Map <string, List<General_Dcouments__c>> generalDcoumentsProductMap;   
    private static Map <Id, List<General_Dcouments__c>> parentGeneralDcoumentsMap;  
    private static List<File_Information__c> allSubordinates {get; set;} 
    private static Map<String, List<File_Information__c>> fileWithDocumentMap = new Map<String, List<File_Information__c>>();  
    private static JSONGenerator gen {get; set;}   
    private static Map<String,Schema.SObjectType> gd;  
    private static Map<String, String> keyPrefixMap;  
    private static Set<String> keyPrefixSet; 
   
    public static List<Product2> lstProducts{get;set;}   
    public static List<String> lstProductGroups{get;set;} 
    public static List<String> lstAssestProducts{get;set;}     
    private static String urlForAccandCase {get; set;}
    private static Set<String> productSet{get;set;}
    
   public  list<SelectOption> options = new list<SelectOption>();
    
    private static List<General_Dcouments__c> lstGenDoc{get;set;}
    
    static {        
        init1();  

        init2();  
        
        //init3();
    }  

    private static void init1() {  
        gd = Schema.getGlobalDescribe();
        productSet = new Set<String>();
     if(gd != null && gd.size() > 0){      
        keyPrefixMap = new Map<String, String>{};  
        keyPrefixSet = gd.keySet(); 
        
        for(String sObj : keyPrefixSet) {  
            Schema.DescribeSObjectResult r =  gd.get(sObj).getDescribe();  
            String tempName = r.getName();  
            String tempPrefix = r.getKeyPrefix();  
            keyPrefixMap.put(tempPrefix, tempName);  
        }
      }  
    }  

    private static void init2() {  
       String userId = UserInfo.getUserId();
       System.debug('userId ::: '+userId );
        lstProducts = new List<Product2>();
        lstAssestProducts = new List<String>();
        lstProductGroups = new List<String>();
        List<User> lstUser = [Select id, Name, ContactId, AccountId From User Where id=:UserInfo.getUserId() and AccountId <> null Limit 1]; 
      // List<Account>  accuser = [Select id, Name,Product_Group_Name__c  From Account Where id=:lstUser[0].AccountId Limit 1];     
        // for(Account acc: accuser){
       // lstProductGroups.add(acc.Product_Group_Name__c); 
     //  }
        List<Asset> lstAcc = [SELECT AccountId,ContactId,Id,Name,Product2Id,status FROM Asset Where AccountId=:lstUser[0].AccountId  and Product2Id <> null and status='Active'];          
        for(Asset ass: lstAcc){
        lstAssestProducts.add(ass.Product2Id); 
       }
    List<product2> lstProd= [SELECT id,Name,IsActive,Product_Group_Name__c FROM product2 Where id IN: lstAssestProducts and IsActive = true and Product_Group_Name__c<> null];
    System.debug('lstProd ::: '+lstProd);    
        for(Product2 pro: lstProd){
        lstProductGroups.add(pro.Product_Group_Name__c); 
       }
    
    
        // if(lstAcc != null && lstAcc.size() > 0 && lstAcc[0].Product2Id != null && lstAcc[0].Product2Id != ''){
          // lstProductGroups = lstAcc[0].Product_Group_Access__c.split(';');
            //lstProducts = [Select id, Name,IsActive From Product2 Where Name IN: lstProductGroups  and IsActive = true];
      //  }
       
       
      
       
        System.debug('lstProductGroups ::: '+lstProductGroups);
        if(lstProductGroups != null && lstProductGroups.size() > 0){
            allSubordinates = new List<File_Information__c>();  
           
               //System.debug('generalDcoumentsMap values :::: '+generalDcoumentsMap.values());
            parentGeneralDcoumentsMap = new Map <Id, List<General_Dcouments__c>>(); 
            List<String> lstGDId = new List<String>();
            
            generalDcoumentsMap = new map<Id, General_Dcouments__c>();
            lstGenDoc = new List<General_Dcouments__c>();
            List<General_Dcouments__c> lstGenralDoc =  [select Id, Name, versoins__c,Order_id__c, Product_Group_Name__c from General_Dcouments__c Where Type__c = 'Document' and Product_Group_Name__c IN:lstProductGroups order by Order_id__c asc];
            System.debug('lstGenralDoc ::::: '+lstGenralDoc);           
             generalDcoumentsProductMap = new Map <string, List<General_Dcouments__c>> ();   
             for (General_Dcouments__c genralDoc : lstGenralDoc)  { 
                if(genralDoc.versoins__c == null){
                    List<General_Dcouments__c>  tempfileName = new  List<General_Dcouments__c >(); 
                    if(generalDcoumentsProductMap.containsKey(genralDoc.Product_Group_Name__c)){ 
                        tempfileName = generalDcoumentsProductMap.get(genralDoc.Product_Group_Name__c);  
                        tempfileName.add(genralDoc); 
                        generalDcoumentsProductMap.put(genralDoc.Product_Group_Name__c, tempfileName);                  
                    }else{                                                            
                        tempfileName.add(genralDoc); 
                        generalDcoumentsProductMap.put(genralDoc.Product_Group_Name__c, tempfileName);                           
                    }   
                }  
                generalDcoumentsMap.put(genralDoc.id, genralDoc);
            }
            if(generalDcoumentsMap != null && generalDcoumentsMap.size() > 0){
                for(Id gdId : generalDcoumentsMap.keySet()){
                    String keyV = String.valueOf(gdId).substring(0, (String.valueOf(gdId).length()-3));
                    lstGDId.add(keyV);
                   system.debug('keyV ::: '+keyV);
                }
            } 
                    system.debug('generalDcoumentsProductMap----'+generalDcoumentsProductMap);
                    system.debug('lstGDId----'+lstGDId);
              List<File_Information__c> lstFInfo =  [Select id, Name, Record_ID__c ,Object_Name__c,Content_Type__c From File_Information__c Where Record_ID__c IN: lstGDId and  Status__c !='In Progress' and Status__c !='Delete'];
            System.debug('lstFInfo  ::: '+lstFInfo );
            for (General_Dcouments__c r : lstGenralDoc) {  
                List<General_Dcouments__c> tempList;  
                if (!parentGeneralDcoumentsMap.containsKey(r.versoins__c)){  
                    tempList = new List<General_Dcouments__c>();  
                    tempList.Add(r);  
                    parentGeneralDcoumentsMap.put(r.versoins__c, tempList);  
                } else {  
                    tempList = (List<General_Dcouments__c>)parentGeneralDcoumentsMap.get(r.versoins__c);  
                    tempList.add(r);  
                    parentGeneralDcoumentsMap.put(r.versoins__c, tempList);  
                }  
            }
             system.debug('parentGeneralDcoumentsMap----'+parentGeneralDcoumentsMap);
            if(lstFInfo != null && lstFInfo.size() > 0){
                for(File_Information__c fI: lstFInfo){
                    System.debug('fI.Record_ID__c ::: '+fI.Record_ID__c);
                    if (!fileWithDocumentMap.containsKey(fI.Record_ID__c)){  
                        List<File_Information__c> tempList1 = new List<File_Information__c>();  
                        tempList1.Add(fI);  
                        fileWithDocumentMap.put(fI.Record_ID__c, tempList1);  
                    } else {  
                        List<File_Information__c> tempList1 = fileWithDocumentMap.get(fI.Record_ID__c);  
                        tempList1.add(fI);  
                        fileWithDocumentMap.put(fI.Record_ID__c, tempList1);  
                    }
                }
            } 
        } 
    }   
    
    public Static  GNDcoumentNodeWrapper getRootNodeOfUserTree (Id accId) {  
        return createNode(accId);  
    }  

    private static GNDcoumentNodeWrapper createNode(Id objId) {  
        GNDcoumentNodeWrapper n = new GNDcoumentNodeWrapper();  
        Id acId;  
        
        if(isGeneralDoc(objId)){              
          acId = objId;
          String keyV = String.valueOf(acId).substring(0, (String.valueOf(acId).length()-3));
          System.debug('keyV ::: '+keyV);
          if (fileWithDocumentMap.containsKey(keyV)) {  
                n.fileDetails = fileWithDocumentMap.get(keyV);  
                allSubordinates.addAll(n.fileDetails);  
                n.hasFiles = true;  
            }
            n.parentId = acId;
            if(generalDcoumentsMap.containsKey(acId)){
                General_Dcouments__c gdv = generalDcoumentsMap.get(acId);
                n.parentName = generalDcoumentsMap.get(acId).Name; 
                n.productName =  gdv.Product_Group_Name__c;     
            }          
        }else{
          List<File_Information__c> tempFileList = new List<File_Information__c>();  
            File_Information__c tempFile = [Select Id, Name, Record_ID__c, Object_Name__c,Content_Type__c from File_Information__c where Id =: objId and  Status__c !='In Progress' and Status__c !='Delete'];  
            tempFileList.add(tempFile);  
            n.fileDetails = tempFileList;  
            acId = tempFile.Record_ID__c;
        }   
        //n.myAccountId = acId;  
        //n.myAccountName = generalDcoumentsMap.get(acId).Name;  
        //n.myParentAccountId = generalDcoumentsMap.get(acId).versoins__c;  
  
        if (parentGeneralDcoumentsMap.containsKey(acId)){  
            n.hasChildren = true;  
            n.isLeafNode = false;  
            List<GNDcoumentNodeWrapper> lst = new List<GNDcoumentNodeWrapper>();  
            for (General_Dcouments__c a : parentGeneralDcoumentsMap.get(acId)) { 
                 System.debug('acId ::: '+acId);  
                lst.add(createNode(a.Id));  
            }             
            n.childNodes = lst;  
        } else {  
            n.isLeafNode = true;  
            n.hasChildren = false;  
        } 
        return n;  
    }  
      
    public  List<File_Information__c> getAllSubordinates(Id caseId){  
        createNode(caseId);  
        return allSubordinates;  
    }  
      
    /*public static String getTreeJSON(Id accId) {  
        gen = JSON.createGenerator(true);  
        GNDcoumentNodeWrapper node = createNode(accId);  
        gen.writeStartArray();  
            convertNodeToJSON(node);  
        gen.writeEndArray();  
        return gen.getAsString();  
    } */ 
    public list<String> countries{get;set;}
     public list<SelectOption> getassigneeNames() {
		countries = new list<String>();
        for(String prodName :generalDcoumentsProductMap.keySet()){
        	   system.debug('prodName:::___==='+prodName);
        	  options.add(new SelectOption(prodName,prodName));
              
               List<General_Dcouments__c> lstGD = new List<General_Dcouments__c>();
           
            lstGD = generalDcoumentsProductMap.get(prodName);
            if(lstGD != null && lstGD.size() > 0){
                 
                for(General_Dcouments__c genDoc : lstGD){
                   system.debug('genDoc:::___==='+genDoc.Name);
                 options.add(new SelectOption(''+genDoc.Name,'-'+genDoc.Name));
                    GNDcoumentNodeWrapper node = createNode(genDoc.id); 
                    convertNodeToJSON(node);
                }
            }
        }  
         return options; 
                     
    }
     
     public Integer addFirstValue = 1 ;
     public void convertNodeToJSON(GNDcoumentNodeWrapper objRNW){ 
   
               system.debug('objRNW2:::___==='+objRNW.parentName);  
                 	addFirstValue += 1;



 
          
          //options.add(new SelectOption(''+objRNW.parentName,'-+i'+objRNW.parentName)); 
                    if (objRNW.hasChildren)  {                    	
                    	 for (GNDcoumentNodeWrapper childNodes : objRNW.childNodes)  {
                    	 	system.debug('addFirstValue'+addFirstValue);
                        
                        	//if(addFirstValue != 0){  
                            	convertNodeToJSON(childNodes);   
                            	options.add(new SelectOption(''+childNodes.parentName,'--=+--'+addFirstValue+childNodes.parentName));
                            	/*for(childNodes.){
                            		options.add(new SelectOption(''+childNodes.parentName,'-+i'+childNodes.parentName));
                            	} */
                        	//}  
                        	
                        }  
                    } 
               
             
       //   }  
              

   }
         
          
 
    public static String getSObjectTypeById(Id objectId) {  
        String tPrefix = objectId;  
        tPrefix = tPrefix.subString(0,3);  

        String objectType = keyPrefixMap.get(tPrefix);  
        return objectType;  
    }  

    public static Boolean isGeneralDoc (Id objId) {  
        if (getSObjectTypeById(objId) == String.valueOf(General_Dcouments__c.sObjectType)) {  
            return true;  
        }else if (getSObjectTypeById(objId) == String.valueOf(File_Information__c.sObjectType)) {  
            return false; 
        }
        return false;  
    }  

        public class GNDcoumentNodeWrapper {  
        public String parentName {get; set;}  
        public String productName {get; set;}  
        public Id parentId {get; set;}        
        public Boolean hasChildren {get; set;}    
        public Boolean isLeafNode {get; set;}        
        public Boolean hasFiles {get; set;}  
        public List<File_Information__c> fileDetails {get; set;}  
        public List<GNDcoumentNodeWrapper> childNodes {get; set;}      
        //public static boolean productAdded = false;               
        public GNDcoumentNodeWrapper(){  
            hasFiles = false;  
            hasChildren = false;  
        }  
    }     
}