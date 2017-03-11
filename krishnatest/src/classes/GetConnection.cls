public class GetConnection{

    public GetConnection(){}
    
    public void createConnection(){
    
    string url = 'https://login.salesforce.com/services/oauth2/token';
    string clientId = '&client_id=3MVG9Y6d_Btp4xp5lykME6mT5LfqdKw8YxBWcKJlRbQ8649wHxWZhA1GRCB4H0fii7E7qIg0EOR8JVq1yuaG5';
    String clientSecret ='&client_secret=5206502862318706683';
    String grantType ='?grant_type=password';
    String userName ='&username=test.trainingsfdc@gmail.com';
    String password ='&password=welcome0123';
   
    String fullUrl = url+grantType+clientSecret+clientId+userName+password ;
    
    Http h = new Http();

      // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
    HttpRequest req = new HttpRequest();
    req.setEndpoint(fullUrl);
    req.setMethod('POST');
     req.setHeader('Content-Type','application/x-www-form-urlencoded'); 
// Send the request, and return a response
    HttpResponse res = h.send(req);
    system.debug('-----testREQ------------------'+ res.getBody());
    JSONWrapper jsonWrapObj = (JSONWrapper)JSON.deserialize(res.getBody(),JSONWrapper.class);
                                                       
    //String restResourceURL='https://ap1.salesforce.com/services/apexrest/testRestCall/v1/';
    String restResourceURL='https://ap1.salesforce.com/services/data/v20.0/sobjects/Account/describe';
    String acessToken =jsonWrapObj.access_token;
    system.debug('-------acessToken -------'+acessToken);
    String fullRestUrl = restResourceURL;
    Http h1 = new Http();
    HttpRequest req1 = new HttpRequest();
    req1.setEndpoint(fullRestUrl);
    
    req1.setHeader('Authorization','Bearer '+acessToken);
    req1.setMethod('GET');
    // req1.setHeader('Content-Type','application/x-www-form-urlencoded'); 
// Send the request, and return a response
    HttpResponse res1 = h1.send(req1);
    system.debug('-----------------------'+res1.getBody());
     
    }
    
    public class JSONWrapper{

        public Integer expires_in;
        public String access_token;

}
    
   

}