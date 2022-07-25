/*
 * https://help.salesforce.com/articleView?id=individuals_data_privacy_for_existing_records.htm&type=5
 */
//Devops change1
global class CreateIndividualFromLead implements Database.Batchable<sObject> {

    global Database.Querylocator start(Database.BatchableContext BC) {
       //Query to fetch non-converted Leads that don't have Individual created. You may modify the query to add custom fields  
       return Database.getQueryLocator('Select FirstName, LastName, Salutation from Lead where IsConverted = false and IndividualId = NULL');
    }
    
    global void execute(Database.BatchableContext BC, List<Lead> leadList) { 
        Map<Id, Individual> individualRecordsToCreate = new Map<Id, Individual>();
        for(Lead l : leadList) {
            individualRecordsToCreate.put(l.Id, new Individual(FirstName = l.FirstName, LastName = l.LastName, Salutation=l.Salutation));
        }
        insert individualRecordsToCreate.values();
        for(Lead l : leadList) {
            l.IndividualId = individualRecordsToCreate.get(l.Id).Id;
        }
        update leadList;
    }
    
    global void finish(Database.BatchableContext BC) {}   
}