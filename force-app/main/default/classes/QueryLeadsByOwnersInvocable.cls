/**
 * @description Designed to be used in a flow to reassign leads.
 * Note that the data structure design is intentionally not scalable; this was a choice.
 * See comments for queryLeads and QueryLeadsRequest.
 */
public with sharing class QueryLeadsByOwnersInvocable {


    /**
     * @description basically an end-user/business rule-designated parent Campaign name
     * that is used to get children Campaigns and their children Leads for. Set this directly in the code for now.
     */
    public static final String PARENT_CAMPAIGN_NAME = 'LDC Personal Campaigns';

    /**
     * @description dynamically gets the parent campaign designated by the PARENT_CAMPAIGN_NAME
     */
    private static Id parentCampaignId {
        get {
            if(parentCampaignId == null) {
                parentCampaignId = [
                        SELECT
                                Id
                        FROM Campaign
                        WHERE Name = :PARENT_CAMPAIGN_NAME
                        LIMIT 1
                ]?.Id;
            }
            return parentCampaignId;
        } set;
    }

    /**
     * @description gets ALL Leads that are assigned to a child campaign of the designated parent campaign
     * see PARENT_CAMPAIGN_NAME and parentCampaignId getter.
     */
    private static Set<Id> leadIdsAssignedToCampaigns {
        get {
            if(leadIdsAssignedToCampaigns == null) {
                leadIdsAssignedToCampaigns = queryLeadsIdsAssignedToCampaigns();
            }
            return leadIdsAssignedToCampaigns;
        } set;
    }

    @InvocableMethod(Label='Query Leads by Owner'
            Description='Queries a number of Leads specified from the Lead Owner Id specified. The oldest Lead Ids (according to CreatedDate) are returned. Note that this can execute up to 5 Query statements.')
    public static List<QueryLeadsResult> queryLeadsByOwnersInvocable(List<QueryLeadsRequest> requests) {
        List<QueryLeadsResult> results = new List<QueryLeadsResult>();
        for(QueryLeadsRequest req : requests) {
            QueryLeadsResult result = processQueryLeadsRequest(req);
            results.add(result);
        }
        return results;
    }

    /**
     * @description This method performs validation on each requested queue and then does the query.
     * @param req a QueryLeadsRequest object. See definition below.
     * @return a QueryLeadsResult object. basically, a List of Salesforce Ids for Leads.
     */
    private static QueryLeadsResult processQueryLeadsRequest(QueryLeadsRequest req) {
        List<Id> leadIds = new List<Id>();
        if(req.queue0Id != null && req.queue0numLeads > 0) {
            leadIds.addAll(queryLeads(req.queue0Id, req.queue0numLeads));
        }
        if(req.queue1Id != null && req.queue1numLeads > 0) {
            leadIds.addAll(queryLeads(req.queue1Id, req.queue1numLeads));
        }
        if(req.queue2Id != null && req.queue2numLeads > 0) {
            leadIds.addAll(queryLeads(req.queue2Id, req.queue2numLeads));
        }
        if(req.queue3Id != null && req.queue3numLeads > 0) {
            leadIds.addAll(queryLeads(req.queue3Id, req.queue3numLeads));
        }
        if(req.queue4Id != null && req.queue4numLeads > 0) {
            leadIds.addAll(queryLeads(req.queue4Id, req.queue4numLeads));
        }
        return new QueryLeadsResult(leadIds);
    }

    /**
     * @description a method designed to get more than 50k Lead Ids that are assigned to Campaigns.
     * @return a Set of Ids for Leads Assigned to Campaigns. Set may exceed 50,000 entries.
     */
    private static Set<Id> queryLeadsIdsAssignedToCampaigns() {
        Set<Id> childCampaignIds = new Set<Id>(new Map<Id, SObject>([
                SELECT
                    Id
                FROM Campaign
                WHERE ParentId = :parentCampaignId
        ])?.keySet());
        Set<Id> leadsIdsAssignedToCampaigns = new Set<Id>();
        for(CampaignMember cm : [
                SELECT
                        LeadId
                FROM CampaignMember
                WHERE CampaignId IN :childCampaignIds
        ]) {
            leadsIdsAssignedToCampaigns.add(cm?.LeadId);
        }
        return leadsIdsAssignedToCampaigns;
    }

    /**
     * @description the actual functionality that the class performs is done here.
     * the intention is to get numLeads number of Leads owned by Queue/Group queueId.
     * additionally, only pulls Leads NOT assigned to Campaigns with a specific suffix; see leadIdsAssignedToCampaigns
     * @param queueId the Id of the Lead.Owner to query. normally a queue in expected use case.
     * @param numLeads the number of Lead Ids for that owner to return.
     * @return a Set of Salesforce Ids for the n oldest Leads owned by the given queueId
     */
    private static Set<Id> queryLeads(Id queueId, Integer numLeads) {
        List<Lead> leadsFound = [
                SELECT Id
                FROM Lead
                WHERE OwnerId = :queueId
                    AND Id NOT IN :leadIdsAssignedToCampaigns
                    AND IsConverted = FALSE
                ORDER BY Sales_Last_Contacted__c ASC NULLS LAST, CreatedDate ASC
                LIMIT :numLeads
        ];
        return new Set<Id>(new Map<Id, SObject>(leadsFound).keySet());
    }

    /**
     * @description This Request class is designed to only take 5 queues at a time.
     * This is an intentional design choice.
     * To make it scale it should use a "LeadQueueData" inner class and a list of those in the request.
     */
    public class QueryLeadsRequest {
        /**
         * @description default constructor does not currently initialize anything.
         */
        public QueryLeadsRequest() {
            // no logic
        }

        @InvocableVariable(Label='Queue 0 # of Leads'
                Description='Number of oldest leads to query from Queue 0.'
                Required=false)
        public Integer queue0numLeads;
        @InvocableVariable(Label='Queue 0 Id'
                Description='Salesforce Id of the Owner (Queue) to query.'
                Required=false)
        public String queue0Id;

        @InvocableVariable(Label='Queue 1 # of Leads'
                Description='Number of oldest leads to query from Queue 1.'
                Required=false)
        public Integer queue1numLeads;
        @InvocableVariable(Label='Queue 1 Id'
                Description='Salesforce Id of the Owner (Queue) to query.'
                Required=false)
        public String queue1Id;

        @InvocableVariable(Label='Queue 2 # of Leads'
                Description='Number of oldest leads to query from Queue 2.'
                Required=false)
        public Integer queue2numLeads;
        @InvocableVariable(Label='Queue 2 Id'
                Description='Salesforce Id of the Owner (Queue) to query.'
                Required=false)
        public String queue2Id;

        @InvocableVariable(Label='Queue 3 # of Leads'
                Description='Number of oldest leads to query from Queue 3.'
                Required=false)
        public Integer queue3numLeads;
        @InvocableVariable(Label='Queue 3 Id'
                Description='Salesforce Id of the Owner (Queue) to query.'
                Required=false)
        public String queue3Id;

        @InvocableVariable(Label='Queue 4 # of Leads'
                Description='Number of oldest leads to query from Queue 4.'
                Required=false)
        public Integer queue4numLeads;
        @InvocableVariable(Label='Queue 4 Id'
                Description='Salesforce Id of the Owner (Queue) to query.'
                Required=false)
        public String queue4Id;
    }

    /**
     * @description wrapper for results (Lead Ids) from the InvocableMethod
     */
    public class QueryLeadsResult {
        @InvocableVariable(Label='Lead Ids'
                Description='Unsorted collection of all Lead Ids found from the specified Queues')
        public List<Id> leadIds;
        /**
         * @description the only needed overload constructor
         * @param leadIds a List of Lead Ids to return.
         */
        public QueryLeadsResult(List<Id> leadIds) {
            this.leadIds = leadIds;
        }
    }

}