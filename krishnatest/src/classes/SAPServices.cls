global with sharing class SAPServices {
	
	
	 public static List<CustomerMasterResponseDTO> GetSAPCustomerMaster() {
        List<CustomerMasterResponseDTO> prdlist = new LIst<CustomerMasterResponseDTO> {};
        try {
        //Variable declaration
        sapComDocumentSapSoapFunctionsMcS.Z_GSSMWFM_HNDL_EVNTRQST00 sap1 = new sapComDocumentSapSoapFunctionsMcS.Z_GSSMWFM_HNDL_EVNTRQST00();       
        Map<List<String>,List<List<String>>> mapSAP = new Map<List<String>,List<List<String>>> {};
        List<String> strReqData = new List<String>{};
        
        
        sap1.timeout_x = 12000;
        sapComDocumentSapSoapFunctionsMcS.ZgssmbstDatarcrd01 req = new sapComDocumentSapSoapFunctionsMcS.ZgssmbstDatarcrd01();
        
        //Products Upsert
        /*
        //FETCH CUSTOMER DETAILS
        
        DEVICE-ID:160000000000000:DEVICE-TYPE:SFDC-CLIENT:APPLICATION-ID:SFDC-SALES
        
        NOTATION:ZML:VERSION:0:DELIMITER:[.]
        
        EVENT[.]SFDC-FET-CUST[.]VERSION[.]0[.]RESPONSE-TYPE[.]FULL-SETS 

        Account Owner   Customer Name   Email   Telephone   Fax     Street Addr     Postal Code:    City:   Region: Country
        ACCOUNT_OWNER   NAME1           EMAIL   TELF1       TELFX   STRAS           PSTLZ           ORT01   REGIO   LAND1
        
    DATA-TYPE[.]ZGSESDST_CUSTDETAILS_01[.]RESPONSE-TYPE=FULL-SETS;ROW-COUNT=8859;
    [.]KUNNR[.]PART_FUNC[.]SALES_GROUP_NO[.]ACCOUNT_OWNER[.]SALES_OFFICE_NO[.]SALES_OFFICE[.]NAME1[.]
    STRAS[.]ORT01[.]PSTLZ[.]REGIO[.]LAND1[.]TELF1[.]TELFX[.]EMAIL

KUNNR
PART_FUNC
SALES_GROUP_NO
ACCOUNT_OWNER
SALES_OFFICE_NO
SALES_OFFICE
NAME1
STRAS
ORT01
PSTLZ
REGIO
LAND1
TELF1
TELFX
EMAIL
SALES_ORG
DISTR_CHANNEL
DIVISION
ADDR
        */
        
        String EventType = 'EVENT[.]SFDC-FET-CUST[.]VERSION[.]0[.]RESPONSE-TYPE[.]FULL-SETS';
        String InputData = '';
        strReqData.add(EventType);
        strReqData.add(InputData);
        req.item = Utility.ECCLoadRequestData(strReqData);
        sapComDocumentSapSoapFunctionsMcS.ZGssmwfmHndlEvntrqst00Response_element ret =  sap1.ZGssmwfmHndlEvntrqst00('',req);
        System.debug('$$$$$$$$$$$$$$$$$$$$$$$$$'+ret);

                mapSAP = TestSAPService.ECCParseMultipleResponse(ret); 
        
                if(!mapSAP.isEmpty() && mapSAP.size()>0) {
                    System.debug(mapSAP.values());
                    Integer cnt = 0;
                    for(List<List<String>> n: mapSAP.values()) {
                        for(List<String> l: n) {
                            System.debug('internal list:'+l);
                            cnt = 0;
                            CustomerMasterResponseDTO sobj = new CustomerMasterResponseDTO();
                            for(String s: l) {
                                System.debug('s:'+s);
        
                                if(cnt == 1) {
                                    sobj.CustomerNo = s;
                                } else if(cnt == 2) {
                                    sobj.PartFunc = s;
                                } else if(cnt == 3) {
                                    sobj.SalesGroupNo = s;
                                } else if(cnt == 4) {
                                    sobj.AccountOwner = s; 
                                } else if(cnt == 5) {
                                    sobj.SalesOfficeNo = s;
                                } else if(cnt == 6) {
                                    sobj.SalesOffice = s;
                                } else if(cnt == 7) {
                                    sobj.CustomerName = s;
                                } else if(cnt == 8) {
                                    sobj.StreetAddr = s;
                                } else if(cnt == 9) {
                                    sobj.City = s;
                                } else if(cnt == 10) {
                                    sobj.PostCode = s;
                                } else if(cnt == 11) {
                                    sobj.State = s;
                                } else if(cnt == 12) {
                                    sobj.Country = s;
                                } else if(cnt == 13) {
                                    sobj.Telephone = s;
                                } else if(cnt == 14) {
                                    sobj.Fax = s;
                                } else if(cnt == 15) {
                                    sobj.Email = s;
                                } else if(cnt == 16) {
                                    sobj.SalesOrg = s;
                                } else if(cnt == 17) {
                                    sobj.DistrChannel = s; 
                                } else if(cnt == 18) {
                                    sobj.Division = s;
                                } else if(cnt == 19) {
                                    sobj.Address = s;
                                }
                                
                                cnt++;
                            }
                            prdlist.add(sobj);
                        }
                    }
                }
            }catch(Exception e) {
                Apexpages.Message msg = new Apexpages.Message(Apexpages.Severity.FATAL,'Oops, please try again!!');
                Apexpages.addMessage(msg);
            }
        return prdlist;         
        
    } 
	
	 public class CustomerMasterResponseDTO {
        /*
        Customer Number KUNNR
        Account Owner   ACCOUNT_OWNER
        Customer Name   NAME1
        Email           EMAIL
        Telephone       TELF1
        Fax             TELFX
        Street Addr     STRAS
            
        Postal Code:    PSTLZ
        City:           ORT01
        Region:         REGIO
        Country         LAND1

        
        */
        public String CustomerNo {get;set;}
        public String AccountOwner {get;set;}
        public String CustomerName {get;set;}
        public String PartFunc {get;set;}
        public String SalesGroupNo {get;set;}
        public String SalesOffice {get;set;}
        public String SalesOfficeNo {get;set;}                        
        public String Email {get;set;}
        public String Telephone {get;set;}
        public String Fax {get;set;}
        public String StreetAddr {get;set;}
        public String PostCode {get;set;}
        public String City {get;set;}
        public String State {get;set;}
        public String Country {get;set;}
        public String Region {get;set;}
        public String SalesOrg {get;set;}
        public String DistrChannel {get;set;}
        public String Division {get;set;}
        public String Address {get;set;}
    }
    
    /***********************@Future*******************************/
    @Future(callout=true)
	//Webservice to Update SAP Customer master data with Account data
	webservice static void CreateServiceNotification(String CaseId) {
		//Variable declaration
		List<String> lstData = new List<String> {};
		InquiryCreateRequestDTO inq = new InquiryCreateRequestDTO();
		sapComDocumentSapSoapFunctionsMcS.Z_GSSMWFM_HNDL_EVNTRQST00 sap1 = new sapComDocumentSapSoapFunctionsMcS.Z_GSSMWFM_HNDL_EVNTRQST00();       
		sapComDocumentSapSoapFunctionsMcS.ZgssmbstDatarcrd01 req = new sapComDocumentSapSoapFunctionsMcS.ZgssmbstDatarcrd01();      
		List<String> strReqData = new List<String>{};
		sap1.timeout_x = 90000;
		//DMsapComDocumentSapSoapFunctionsMcS.ZgssmbstDatarcrd01 req = new DMsapComDocumentSapSoapFunctionsMcS.ZgssmbstDatarcrd01();
		Case cas = [Select c.Type, c.SystemModstamp, c.SuppliedPhone, 
		c.SuppliedName, c.SuppliedEmail, c.SuppliedCompany, 
		c.Subject, c.Status, c.Reason, 
		 c.Priority,  c.ParentId, 
		c.OwnerId, c.Origin, c.LastViewedDate, c.LastReferencedDate, 
		c.LastModifiedDate, c.LastModifiedById, c.IsEscalated, c.IsDeleted, 
		c.IsClosed, c.Id, c.EngineeringReqNumber__c, c.Description, c.CreatedDate, 
		c.CreatedById, c.Contact.Name, c.ClosedDate, c.CaseNumber, c.Asset.Description, 
		c.Asset.Quantity, c.Asset.Price, c.Asset.Status, c.Asset.UsageEndDate, 
		c.Asset.PurchaseDate, c.Asset.InstallDate, c.Asset.SerialNumber, 
		c.Asset.Name, c.Asset.IsDeleted, c.Asset.SystemModstamp, 
		c.Asset.LastModifiedById, c.Asset.LastModifiedDate, c.Asset.CreatedById,
		c.Asset.CreatedDate, c.Asset.IsCompetitorProduct, 
		c.Asset.Product2.ProductCode, c.Asset.Account.SAP_KUNNR__c, 
		c.Asset.Contact.Name, c.Asset.Id, c.AssetId, c.Account.Id, 
		c.Account.SAP_KUNNR__c From Case c where c.Id=: CaseId];
		//Create Service Notification for a Case in SAP
		/*
		Scenario: SFDC-CR-SVNTF
		'ZGSESDST_SERV_PARAM[.]'+cas.CaseNumber+'[.]'+cas.Contact.Name+'[.]'+cas.Account.SAP_KUNNR__c+'[.]'+cas.Priority+'[.]'+
		cas.Origin+'[.]'+cas.Subject+'[.]'+cas.Description+'[.]'+cas.Status+'[.]3000[.]'+cas.Asset.Product2.ProductCode+'[.]'+cas.Asset.SerialNumber+'[.]'+
		[.]02.12.2014[.]05.12.2014[.]';

		ZGSESDST_SERV_PARAM[.]CASE_NO_SFDC[.]CONTACT_NAME[.]ACCOUNT_NUMBER[.]PRIORITY[.]CASE_ORIGIN[.]SUBJECT[.]DESCRIPTION[.]
		STATUS[.]PLANT[.]MATERIAL[.]SERIAL_NO[.]START_DATE[.]FINISH_DATE[.]

		Input          5  rows
		//CREATE SERVICE NOTIFICATION FROM SFDC
		DEVICE-ID:160000000000000:DEVICE-TYPE:SFDC-CLIENT:APPLICATION-ID:SFDC-SALES
		NOTATION:ZML:VERSION:0:DELIMITER:[.]
		EVENT[.]SFDC-CREATE-SERVICE-NOTIF[.]VERSION[.]0[.]RESPONSE-TYPE[.]FULL-SETS
		ZGSESDST_SERV_PARAM[.]case testing[.][.]1171[.]MEDIUM[.][.]SERVICE ESY[.]SERVICE TEST FROM ESY[.]NEW[.]1200[.]R-1001[.]000000000000010010[.]02.12.2014[.]05.12.2014[.]


		Output          4  rows
		NOTATION:ZML:VERSION:0:DELIMITER:[.]
		EVENT-RESPONSE[.]SFDC-CREATE-SERVICE-NOTIF[.]SERVICE-VERSION[.]0
		DATA-TYPE[.]ZGSESDST_INQ_DATA[.]RESPONSE-TYPE=FULL-SETS;ROW-COUNT=1;[.]TYPE[.]ID[.]NUMBER[.]MESSAGE[.]LOG_NO[.]LOG_MSG_NO[.]MESSAGE_V1[.]MESSAGE_V2[.]MESSAGE_V3[.]MESSAGE_V4
		ZGSESDST_INQ_DATA[.]S[.][.][.]SERVICE NOTIFICATION HAS BEEN CREATED IN SAP WITH NO 000200001252[.][.][.][.]000200001252[.][.]
		*/
		String EventType;
		EventType = 'EVENT[.]SFDC-CREATE-SERVICE-NOTIF[.]VERSION[.]0[.]RESPONSE-TYPE[.]FULL-SETS';
		String InputFields = '';
		//Add account fields
		//String InputData = 'ZGSESDST_SERV_PARAM[.]case testing[.][.]1171[.]MEDIUM[.][.]SERVICE ESY[.]SERVICE TEST FROM ESY[.]NEW[.]1200[.]R-1001[.]000000000000010010[.]02.12.2014[.]05.12.2014[.]';
		String InputData = 'ZGSESDST_SERV_PARAM[.]'+cas.CaseNumber+'[.]'+cas.Contact.Name+'[.]'+cas.Account.SAP_KUNNR__c+'[.]'+cas.Priority+'[.]';
		InputData += cas.Origin+'[.]'+cas.Subject+'[.]'+cas.Description+'[.]'+cas.Status+'[.]1200[.]'+cas.Asset.Product2.ProductCode+'[.]'+cas.Asset.SerialNumber+'[.]';
		InputData += '02.12.2014[.]05.12.2014[.]';
		strReqData.add(EventType);
		strReqData.add(InputFields);
		strReqData.add(InputData);
		req.item = Utility.LoadRequestData(strReqData); 
		sapComDocumentSapSoapFunctionsMcS.ZGssmwfmHndlEvntrqst00Response_element ret;
		try {
			ret =  sap1.ZGssmwfmHndlEvntrqst00('',req);
			//System.debug('$$$$$$$$$$$$$$$$$$$$$$$$$---+++'+ret);
			//System.debug('ret.DpostMssg.item$$$$$$$$$$$$$$$$$$$$$$$$$----'+ret.DpostOtpt.item[0]);
			//DMsapComDocumentSapSoapFunctionsMcS.Bapiret2 re = ret.DpostMssg.item;
			//DMsapComDocumentSapSoapFunctionsMcS.ZgssmbssDatarcrd01 r = ret.DpostOtpt.item[0];
			//ProcessorControl.inFutureContext = true;
			Integer cnt = 0;
			lstData = new List<String> {};

			for(sapComDocumentSapSoapFunctionsMcS.ZgssmbssDatarcrd01 r: ret.DpostOtpt.item) {
			System.debug('cdata value:'+r.Cdata);
			if(cnt >= 3) {
			lstData = r.Cdata.split('\\[.]');
			System.debug('cdata value>>>>>>>>>>>>>'+lstData[4]);
			}
			cnt ++;

			}            
			System.debug('lstData>>>>>>>>>:'+lstData);
			cas.Description = lstData[4];

			update cas;
		} catch(Exception ex) {
			System.debug('>>>>>>>>>>>>>>>>>>>>'+ex.getmessage());
			cas.Description = lstData[4];
			//update acc;
		}
	} 
   /*******************************************/
      public class InquiryCreateRequestDTO {
        /*
        Account Type
        Customer Number
        */
        public String OppID {get;set;}
        public String AccountType {get;set;}
        public String CustomerNumber {get;set;}
        public String ValidDt {get;set;}
    }
    

}