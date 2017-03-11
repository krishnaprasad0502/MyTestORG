public class DynamicSObjectCreation {
  public DynamicSObjectCreation (){
    Schema.DescribeFieldResult f = Schema.sObjectType.Account.fields.AccountNumber;
    Sobject s = Database.query('SELECT AccountNumber FROM Account LIMIT 1');
    s.put(f.getsObjectField(), '12345');
    system.debug('test:::1258'+s);
    system.debug('test:::1257'+f);
     }  
}