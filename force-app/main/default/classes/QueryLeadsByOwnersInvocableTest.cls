@IsTest
public class QueryLeadsByOwnersInvocableTest {

    @TestSetup
    private static void testSetup() {
        Test.setMock(HttpCalloutMock.class, new PostSlackMessageTestMock.SuccessfulResponseMock());
        // create 7 Queues
        // each with 7 Leads
        List<Group> queues = new List<Group>();
        for(Integer i = 0; i < 7; i++) {
            Group q = new Group(
                    Name = 'Test Lead Queue ' + i,
                    Type = 'Queue'
            );
            queues.add(q);
        }
        insert queues;
        // we have to tell the Queue what kind of SObjects will go into it.
        List<QueueSobject> queueSObjects = new List<QueueSobject>();
        for(Group q : queues) {
            QueueSobject qso = new QueueSobject(
                    QueueId = q.Id,
                    SobjectType = 'Lead'
            );
            queueSObjects.add(qso);
        }
        // since this is considered a "setup object" we have to do the DML for inserting it in a separate thread...
        // this avoids a MIXED_DML_OPERATION Exception
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert queueSObjects;
        }
        // generate and assign Leads to Queues
        // Queue 0 through 5 have 7 Leads.
        // Queue 5's Leads are also part of a Campaign.
        // Queue 6 has no Leads, or better said, there are 8 leads for each Queue 6-8 that are not assigned.
        List<Lead> leads = new List<Lead>();
        Map<Integer, List<Lead>> queueNumToLeadsMap = new Map<Integer, List<Lead>>();
        for(Integer i = 0; i < 7; i++) {
            List<Lead> leadsInQueue = new List<Lead>();
            for(Integer j = 0; j < 7; j++) {
                Lead ld = new Lead(
                        FirstName = 'Test Queue ' + i,
                        LastName = 'Test Lead ' + j,
                        LeadSource = 'Web',
                        Phone = '800-237-9574',
                        Company = 'Coastal Cloud'
                );
                // assign the last group of leads to a User and not a Queue
                if(i < 6) {
                    leadsInQueue.add(ld);
                    ld.OwnerId = queues[i].Id;
                } else {
                    ld.FirstName = 'Unassigned to Queue ' + i;
                    ld.OwnerId = System.UserInfo.getUserId();
                }
                leads.add(ld);
                queueNumToLeadsMap.put(i, leadsInQueue);
            }
        }
        insert leads;
        List<Lead> q5leads = queueNumToLeadsMap.get(5);

        Campaign parentCampaign = new Campaign(
                Name = QueryLeadsByOwnersInvocable.PARENT_CAMPAIGN_NAME
        );
        insert parentCampaign;

        Campaign campaignLDC = new Campaign(
                Name = 'Test Campaign LDC',
                ParentId = parentCampaign.Id
        );
        insert campaignLDC;

        List<CampaignMember> cms = new List<CampaignMember>();
        for(Lead ld : q5leads) {
            CampaignMember cm = new CampaignMember(
                    LeadId = ld.Id,
                    CampaignId = campaignLDC.Id
            );
            cms.add(cm);
        }
        insert cms;
    }

    private static QueryLeadsByOwnersInvocable.QueryLeadsRequest buildSampleRequest(List<Group> testGroups, Integer leadsPerQueue) {
        QueryLeadsByOwnersInvocable.QueryLeadsRequest req = new QueryLeadsByOwnersInvocable.QueryLeadsRequest();
        req.queue0Id = testGroups[0].Id;
        req.queue1Id = testGroups[1].Id;
        req.queue2Id = testGroups[2]?.Id;
        req.queue3Id = testGroups[3]?.Id;
        req.queue4Id = testGroups[4]?.Id;
        req.queue0numLeads = leadsPerQueue;
        req.queue1numLeads = leadsPerQueue;
        req.queue2numLeads = leadsPerQueue;
        req.queue3numLeads = leadsPerQueue;
        req.queue4numLeads = leadsPerQueue;
        return req;
    }

    @IsTest
    private static void queryLeadsByOwnersInvocable_query5QueuesFor5Leads_returns25leads() {
        Test.setMock(HttpCalloutMock.class, new PostSlackMessageTestMock.SuccessfulResponseMock());
        Map<Id, Group> queueMap = new Map<Id, Group>([
                SELECT Id,
                        Name,
                        DeveloperName
                FROM Group
                WHERE Name LIKE 'Test Lead Queue%'
                    AND Name != 'Test Lead Queue 5'
                    AND Name != 'Test Lead Queue 6'
                LIMIT 5
        ]);
        for(Group g : queueMap.values()){
            System.debug(g.Name);
        }
        QueryLeadsByOwnersInvocable.QueryLeadsRequest req = buildSampleRequest(queueMap.values(), 5);
        List<QueryLeadsByOwnersInvocable.QueryLeadsRequest> requests = new List<QueryLeadsByOwnersInvocable.QueryLeadsRequest>();
        requests.add(req);
        List<QueryLeadsByOwnersInvocable.QueryLeadsResult> actualResults;
        QueryLeadsByOwnersInvocable.QueryLeadsResult actualResult;

        Test.startTest();
        actualResults = QueryLeadsByOwnersInvocable.queryLeadsByOwnersInvocable(requests);
        Test.stopTest();

        System.assertNotEquals(null, actualResults);
        actualResult = actualResults.get(0);
        System.assertNotEquals(null, actualResult);
        List<Id> leadIds = actualResult.leadIds;
        System.assertNotEquals(null, leadIds);
        System.assertNotEquals(0, leadIds.size());
        // 5 leadsPerQueue * 5 queues = 25 leadIds expected
        System.assertEquals(25, leadIds.size());
        System.debug(leadIds);
    }

    @IsTest
    private static void queryLeadsByOwnersInvocable_query5QueuesFor5Leads_returns20leads() {
        Test.setMock(HttpCalloutMock.class, new PostSlackMessageTestMock.SuccessfulResponseMock());
        Map<Id, Group> queueMap = new Map<Id, Group>([
                SELECT Id,
                        Name,
                        DeveloperName
                FROM Group
                WHERE Name LIKE 'Test Lead Queue%'
                    AND Name != 'Test Lead Queue 4'
                    AND Name != 'Test Lead Queue 6'
                LIMIT 5
        ]);
        for(Group g : queueMap.values()){
            System.debug(g.Name);
        }
        QueryLeadsByOwnersInvocable.QueryLeadsRequest req = buildSampleRequest(queueMap.values(), 5);
        List<QueryLeadsByOwnersInvocable.QueryLeadsRequest> requests = new List<QueryLeadsByOwnersInvocable.QueryLeadsRequest>();
        requests.add(req);
        List<QueryLeadsByOwnersInvocable.QueryLeadsResult> actualResults;
        QueryLeadsByOwnersInvocable.QueryLeadsResult actualResult;

        Test.startTest();
        actualResults = QueryLeadsByOwnersInvocable.queryLeadsByOwnersInvocable(requests);
        Test.stopTest();

        System.assertNotEquals(null, actualResults);
        actualResult = actualResults.get(0);
        System.assertNotEquals(null, actualResult);
        List<Id> leadIds = actualResult.leadIds;
        System.assertNotEquals(null, leadIds);
        System.assertNotEquals(0, leadIds.size());
        // 5 leadsPerQueue * 5 queues = 25 leadIds expected, but queue 5 has no valid leads due to them being campaign members.
        System.assertEquals(20, leadIds.size());
        System.debug(leadIds);
    }

}