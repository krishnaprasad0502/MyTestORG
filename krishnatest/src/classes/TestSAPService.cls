public with sharing class TestSAPService {
	  public static Map<List<String>,List<List<String>>> ECCParseMultipleResponse(sapComDocumentSapSoapFunctionsMcS.ZGssmwfmHndlEvntrqst00Response_element ret) {
    List<String> lstHeader = new List<String> {};
     List<String> lstData = new List<String> {};
     List<List<String>> nlstData = new List<List<String>> {};
     Map<List<String>,List<List<String>>> mapSAP = new Map<List<String>,List<List<String>>> {};
     System.debug('response value 1:'+ret.DpostMssg.item);
     System.debug('response value 2:'+ret.DpostOtpt.item);
    
     //if(ret.DpostMssg.item.isEmpty()) {
       Integer cnt = 0;
       
       for(sapComDocumentSapSoapFunctionsMcS.ZgssmbssDatarcrd01 r: ret.DpostOtpt.item) {
         System.debug('cdata value:'+r.Cdata);
         if(cnt == 2) {
           lstHeader = r.Cdata.split('\\[.]',-1);
         }
         
         if(cnt >= 3) {
           lstData = r.Cdata.split('\\[.]',-1);
           nlstData.add(lstData);
         }
         cnt ++;
       }
       
       System.debug('lstHeader:'+lstHeader.size());
       System.debug('lstData:'+lstData);
       System.debug('nlstData:'+nlstData);
       System.debug('lstdata size'+lstData.size());
    mapSAP.put(lstHeader,nlstData);
       
     //}
     //System.debug('mapSAP:'+mapSAP);
     return mapSAP;    
  }

}