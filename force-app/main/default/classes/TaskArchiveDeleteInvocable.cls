public  with sharing class TaskArchiveDeleteInvocable {

 public class Request {

        @InvocableVariable(
            label = 'Lead ID'
            description = 'ID of the Lead delete Archived Tasks'
            required = true
        )
        public ID leadId;

    }   
    
    public class Response {

        @InvocableVariable( label = 'Lead ID' )
        public ID leadId;

    }

    // --------------------------------------------------------------------------------

    @InvocableMethod(
        label = 'Delete Archived Tasks'
    )
       public static List<Response> execute( List<Request> requests ) {

        List<Response> responses = new List<Response>();
        List<Id> LeadIds = new List<Id>();
        List<Task> tasksToDelete = new List<Task>();
        List<Lead> leadsToUpdate = new List<Lead>();

        system.debug('BW: Starting TaskArchiveDeleteInvocable class');
           
        for (Request req : requests ) {
            LeadIds.add(req.leadId);
            system.debug('BW Lead id: ' + req.leadId);
            
        }

       if(LeadIds.size() > 0 & LeadIds !=null){
           tasksToDelete = [SELECT id
                          FROM Task where IsArchived = True and WhoId IN : LeadIds ALL ROWS];
           
           leadsToUpdate = [Select id,ADMIN_Duplicate_Tag__c
                           FROM Lead where Id IN : LeadIds];
           
           if(leadsToUpdate.size() > 0 && leadsToUpdate != NULL){
               for (Lead l : leadsToUpdate){
                   l.ADMIN_Duplicate_Tag__c = 'Running Task Archive Job for ' +  l.id + ' : ' + tasksToDelete.size();
               }
               
               update leadsToUpdate;
           }
           
           system.debug('BW Tasks to delete: ' + tasksToDelete.size()); 
           if(tasksToDelete.size() > 0 && tasksToDelete != null){
               delete tasksToDelete;  
           }
        }

        system.debug('BW: Finished TaskArchiveDeleteInvocable class');
        return responses;
    }
}