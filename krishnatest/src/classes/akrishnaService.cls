global class akrishnaService{ 
    webService static Id makeContact(String lastName, Id accountId) { 
        Contact c = new Contact(LastName = lastName, AccountId = accountId); 
        insert c;
        System.debug(LoggingLevel.Info, 'Created ' + c.Id + ' for ' + accountId);
        return c.id; 
    }
}