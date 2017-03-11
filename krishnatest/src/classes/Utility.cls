public with sharing class Utility {
	
	public static List<sapComDocumentSapSoapFunctionsMcS.ZgssmbssDatarcrd01> ECCLoadRequestData(List<String> lstInput) {
        List<sapComDocumentSapSoapFunctionsMcS.ZgssmbssDatarcrd01> itm = new List<sapComDocumentSapSoapFunctionsMcS.ZgssmbssDatarcrd01>();
        
        //populating item values
        sapComDocumentSapSoapFunctionsMcS.ZgssmbssDatarcrd01 s1 = new sapComDocumentSapSoapFunctionsMcS.ZgssmbssDatarcrd01();
        s1.Cdata = 'DEVICE-ID:160000000000000:DEVICE-TYPE:SFDC-CLIENT:APPLICATION-ID:SFDC-SALES';
        itm.add(s1);          
        
        sapComDocumentSapSoapFunctionsMcS.ZgssmbssDatarcrd01 s2 = new sapComDocumentSapSoapFunctionsMcS.ZgssmbssDatarcrd01();       
        s2.Cdata = 'NOTATION:ZML:VERSION:0:DELIMITER:[.]';
        itm.add(s2);
        
        for(String s: lstInput) {
            sapComDocumentSapSoapFunctionsMcS.ZgssmbssDatarcrd01 s3 = new sapComDocumentSapSoapFunctionsMcS.ZgssmbssDatarcrd01();
            s3.Cdata = s;
            itm.add(s3);
        }       
        System.debug('item values:'+itm);
        return itm;
        
    }



/******************************************************/
    public static List<sapComDocumentSapSoapFunctionsMcS.ZgssmbssDatarcrd01> LoadRequestData(List<String> lstInput) {
        List<sapComDocumentSapSoapFunctionsMcS.ZgssmbssDatarcrd01> itm = new List<sapComDocumentSapSoapFunctionsMcS.ZgssmbssDatarcrd01>();
        
        //populating item values
        sapComDocumentSapSoapFunctionsMcS.ZgssmbssDatarcrd01 s1 = new sapComDocumentSapSoapFunctionsMcS.ZgssmbssDatarcrd01();
        s1.Cdata = 'DEVICE-ID:160000000000000:DEVICE-TYPE:SFDC-CLIENT:APPLICATION-ID:SFDC-SALES';
        itm.add(s1);          
        
        sapComDocumentSapSoapFunctionsMcS.ZgssmbssDatarcrd01 s2 = new sapComDocumentSapSoapFunctionsMcS.ZgssmbssDatarcrd01();       
        s2.Cdata = 'NOTATION:ZML:VERSION:0:DELIMITER:[.]';
        itm.add(s2);
        
        for(String s: lstInput) {
            sapComDocumentSapSoapFunctionsMcS.ZgssmbssDatarcrd01 s3 = new sapComDocumentSapSoapFunctionsMcS.ZgssmbssDatarcrd01();
            s3.Cdata = s;
            itm.add(s3);
        }       
        System.debug('item values:'+itm);
        return itm;
        
    }



}