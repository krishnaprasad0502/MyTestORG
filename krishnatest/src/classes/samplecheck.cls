public class samplecheck
{   
    public Boolean metro {get;set;}
    public Boolean city {get;set;}
    public Boolean bool {get;set;}
   
    public samplecheck()
    {
       
    }
   
    public void demo()
    {
        if(metro)
        {
            bool = true;
        }
        else
        {
            bool = false;
        }        
    }
     
}