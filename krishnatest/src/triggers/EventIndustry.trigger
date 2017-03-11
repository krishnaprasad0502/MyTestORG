trigger EventIndustry on Event (before insert, before update) {

    set<id> eveId = new set<id>();
    list<id> eveIdq = new list<id>();   

    for(Event eve : trigger.new ){ 
        eveId.add(eve.id);
    }
    //list<event> evedetails = [SELECT AccountId,ActivityDate,ActivityDateTime,CreatedById,CreatedDate,Description,DurationInMinutes,EndDateTime,GroupEventType,Id,IsAllDayEvent,IsArchived,IsChild,IsDeleted,IsGroupEvent,IsPrivate,IsRecurrence,IsReminderSet,LastModifiedById,LastModifiedDate,Location,OwnerId,RecurrenceActivityId,RecurrenceDayOfMonth,RecurrenceDayOfWeekMask,RecurrenceEndDateOnly,RecurrenceInstance,RecurrenceInterval,RecurrenceMonthOfYear,RecurrenceStartDateTime,RecurrenceTimeZoneSidKey,RecurrenceType,ReminderDateTime,ShowAs,StartDateTime,Subject,SystemModstamp,WhatCount,WhatId,WhoCount,WhoId FROM Event WHERE Id IN :eveId];
    list<event> evedetails = [SELECT AccountId,ActivityDate,ActivityDateTime,CreatedById,CreatedDate,Description,DurationInMinutes,EndDateTime,GroupEventType,Id,IsAllDayEvent,IsArchived,IsChild,IsDeleted,IsGroupEvent,IsPrivate,IsRecurrence,IsReminderSet,LastModifiedById,LastModifiedDate,Location,OwnerId,RecurrenceActivityId,RecurrenceDayOfMonth,RecurrenceDayOfWeekMask,RecurrenceEndDateOnly,RecurrenceInstance,RecurrenceInterval,RecurrenceMonthOfYear,RecurrenceStartDateTime,RecurrenceTimeZoneSidKey,RecurrenceType,ReminderDateTime,ShowAs,StartDateTime,Subject,WhoId FROM Event WHERE Id IN :eveId];
    for(Event eve : evedetails ){
        eveIdq.add(eve.id);
    }
    //list<EventWhoRelation> eveIdqrq = new list<EventWhoRelation>();
    //list<EventRelation> EventRelationdetails = [SELECT AccountId,CreatedById,CreatedDate,EventId,Id,IsDeleted,IsInvitee,IsParent,IsWhat,LastModifiedById,LastModifiedDate,RelationId,RespondedDate,Response,Status,SystemModstamp FROM EventRelation WHERE IsParent = false and EventId IN : eveIdq];
    list<EventRelation> EventRelationdetails = [SELECT EventId,Id,RelationId,RespondedDate,Response,Status FROM EventRelation WHERE  EventId IN : eveIdq];
    for(EventRelation ever : EventRelationdetails ){ 
    
        
    }
     
    //insert eveIdqrq;
}