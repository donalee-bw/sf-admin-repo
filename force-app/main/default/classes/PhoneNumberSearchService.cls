public class PhoneNumberSearchService {
    public class SearchResult {
        @InvocableVariable(label='Contact Id')
        public String contactId;
        
        @InvocableVariable(label='Case Id')
        public String caseId;
        
        @InvocableVariable(label='Account Id')
        public String accountId;
        
        @InvocableVariable(label='Lead Id')
        public String leadId;
        
        @InvocableVariable(label='Total Records Found')
        public Integer totalRecords;
        
        @InvocableVariable(label='Execution Time (ms)')
        public Long executionTime;
        
        public SearchResult() {
            this.contactId = null;
            this.caseId = null;
            this.accountId = null;
            this.leadId = null;
            this.totalRecords = 0;
            this.executionTime = 0;
        }
    }
    public class FlowInput {
        @InvocableVariable(required=true label='Phone Number' description='Phone number to search')
        public String phoneNumber;
    }
    
    @InvocableMethod(label='Search Records by Phone' description='Searches Contact, Case, Account, and Lead by phone number' category='Phone Search')
    public static List<SearchResult> searchByPhone(List<FlowInput> inputs) {
        List<SearchResult> results = new List<SearchResult>();
        if (inputs == null || inputs.isEmpty()) {
            results.add(new SearchResult());
            return results;
        }
        FlowInput input = inputs[0];
        SearchResult result = new SearchResult();
        Long startTime = System.currentTimeMillis();
        try{
            if (String.isBlank(input.phoneNumber)) {
                result.executionTime = System.currentTimeMillis() - startTime;
                results.add(result);
                return results;
            }
            List<List<SObject>> searchResults = [FIND :input.phoneNumber 
                                                 IN ALL FIELDS RETURNING Contact(Id LIMIT 1), Case(Id WHERE isClosed = false LIMIT 1), 
                                                 Account(Id LIMIT 1),Lead(Id WHERE IsConverted = false LIMIT 1)];
            Integer recordCount = 0;    
            if(searchResults != null && searchResults.size() > 0 && searchResults[0] != null && !searchResults[0].isEmpty()) {
                result.contactId = searchResults[0][0].Id;
                recordCount++;
            }
            
            
            if(searchResults != null && searchResults.size() > 1 && searchResults[1] != null && !searchResults[1].isEmpty()) {
                result.caseId = searchResults[1][0].Id;
                recordCount++;
            }
            
            if(searchResults != null && searchResults.size() > 2 && searchResults[2] != null && !searchResults[2].isEmpty()) {
                result.accountId = searchResults[2][0].Id;
                recordCount++;
            }
            
            if(searchResults != null && searchResults.size() > 3 && searchResults[3] != null && !searchResults[3].isEmpty()) {
                result.leadId = searchResults[3][0].Id;
                recordCount++;
            }
            result.totalRecords = recordCount;
            
        }catch(Exception e){
            System.debug('Error in phone search: ' + e.getMessage());
            System.debug('Stack Trace: ' + e.getStackTraceString());
        }finally{
            Long endTime = System.currentTimeMillis();
            result.executionTime = endTime - startTime;
        }
        System.debug('this was the execution time ' +  result.executionTime);
        results.add(result);
        return results;
        
    }
    
}