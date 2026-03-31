public with sharing class WorkQueueController {

    public class StepTargetWrapper {
        @AuraEnabled public String taskId;
        @AuraEnabled public String targetId;
        @AuraEnabled public String targetName;
        @AuraEnabled public String targetType;
        @AuraEnabled public String organizationName;
        @AuraEnabled public String phone;
        @AuraEnabled public String stepType;
        @AuraEnabled public String stepName;
        @AuraEnabled public Integer daysOverdue;
        @AuraEnabled public Datetime lastModifiedDate;
        @AuraEnabled public String cadenceName;
    }

    public class StepGroupWrapper {
        @AuraEnabled public String stepName;
        @AuraEnabled public String stepType;
        @AuraEnabled public Integer count;
        @AuraEnabled public List<StepTargetWrapper> targets;
    }

    public class CadenceGroupWrapper {
        @AuraEnabled public String cadenceName;
        @AuraEnabled public Integer totalCount;
        @AuraEnabled public List<StepGroupWrapper> stepGroups;
    }

    @AuraEnabled
    public static List<CadenceGroupWrapper> getPendingCadenceSteps(String sortField) {
        try {
            String userId = UserInfo.getUserId();

            List<Task> cadenceTasks = [
                SELECT Id, Subject, Status, WhoId, Who.Name, Who.Type,
                       ActivityDate, LastModifiedDate
                FROM Task
                WHERE OwnerId = :userId
                  AND TaskSubtype = 'Cadence'
                  AND IsClosed = false
                ORDER BY LastModifiedDate DESC
                LIMIT 500
            ];

            if (cadenceTasks.isEmpty()) {
                return new List<CadenceGroupWrapper>();
            }

            Set<Id> leadIds = new Set<Id>();
            Set<Id> contactIds = new Set<Id>();
            for (Task t : cadenceTasks) {
                if (t.WhoId != null) {
                    String prefix = String.valueOf(t.WhoId).substring(0, 3);
                    if (prefix == '00Q') {
                        leadIds.add(t.WhoId);
                    } else if (prefix == '003') {
                        contactIds.add(t.WhoId);
                    }
                }
            }

            Map<Id, Lead> leadsMap = new Map<Id, Lead>();
            if (!leadIds.isEmpty()) {
                leadsMap = new Map<Id, Lead>([
                    SELECT Id, Name, Company, Phone
                    FROM Lead
                    WHERE Id IN :leadIds
                ]);
            }

            Map<Id, Contact> contactsMap = new Map<Id, Contact>();
            if (!contactIds.isEmpty()) {
                contactsMap = new Map<Id, Contact>([
                    SELECT Id, Name, Account.Name, Phone
                    FROM Contact
                    WHERE Id IN :contactIds
                ]);
            }

            Map<String, CadenceGroupWrapper> cadenceMap = new Map<String, CadenceGroupWrapper>();

            for (Task t : cadenceTasks) {
                String stepType = 'Task';
                String stepName = 'Step';
                String cadenceName = 'Unknown Cadence';

                // Parse Subject: "{Type}: {StepName}, {CadenceName}, {TargetName}[, {OrgName}]"
                if (String.isNotBlank(t.Subject)) {
                    Integer colonIdx = t.Subject.indexOf(': ');
                    if (colonIdx > 0) {
                        stepType = t.Subject.substring(0, colonIdx);
                        String remainder = t.Subject.substring(colonIdx + 2);
                        List<String> parts = remainder.split(', ');
                        if (parts.size() >= 2) {
                            stepName = parts[0];
                            cadenceName = parts[1];
                        } else if (parts.size() == 1) {
                            stepName = parts[0];
                        }
                    }
                }

                StepTargetWrapper target = new StepTargetWrapper();
                target.taskId = t.Id;
                target.targetId = t.WhoId;
                target.stepName = stepName;
                target.stepType = stepType;
                target.cadenceName = cadenceName;
                target.lastModifiedDate = t.LastModifiedDate;

                if (t.ActivityDate != null && t.ActivityDate < Date.today()) {
                    target.daysOverdue = t.ActivityDate.daysBetween(Date.today());
                } else {
                    target.daysOverdue = 0;
                }

                if (t.WhoId != null) {
                    String prefix = String.valueOf(t.WhoId).substring(0, 3);
                    if (prefix == '00Q' && leadsMap.containsKey(t.WhoId)) {
                        Lead l = leadsMap.get(t.WhoId);
                        target.targetName = l.Name;
                        target.targetType = 'Lead';
                        target.organizationName = l.Company;
                        target.phone = l.Phone;
                    } else if (prefix == '003' && contactsMap.containsKey(t.WhoId)) {
                        Contact c = contactsMap.get(t.WhoId);
                        target.targetName = c.Name;
                        target.targetType = 'Contact';
                        target.organizationName = c.Account != null ? c.Account.Name : '';
                        target.phone = c.Phone;
                    }
                }

                if (target.targetName == null) {
                    target.targetName = t.Who != null ? t.Who.Name : 'Unknown';
                    target.targetType = t.Who != null ? t.Who.Type : 'Lead';
                }

                if (!cadenceMap.containsKey(cadenceName)) {
                    CadenceGroupWrapper cg = new CadenceGroupWrapper();
                    cg.cadenceName = cadenceName;
                    cg.totalCount = 0;
                    cg.stepGroups = new List<StepGroupWrapper>();
                    cadenceMap.put(cadenceName, cg);
                }

                CadenceGroupWrapper cg = cadenceMap.get(cadenceName);
                cg.totalCount++;

                String stepKey = stepName + '|' + stepType;
                StepGroupWrapper matchedGroup = null;
                for (StepGroupWrapper sg : cg.stepGroups) {
                    if ((sg.stepName + '|' + sg.stepType) == stepKey) {
                        matchedGroup = sg;
                        break;
                    }
                }
                if (matchedGroup == null) {
                    matchedGroup = new StepGroupWrapper();
                    matchedGroup.stepName = stepName;
                    matchedGroup.stepType = stepType;
                    matchedGroup.count = 0;
                    matchedGroup.targets = new List<StepTargetWrapper>();
                    cg.stepGroups.add(matchedGroup);
                }
                matchedGroup.count++;
                matchedGroup.targets.add(target);
            }

            return cadenceMap.values();
        } catch (Exception e) {
            System.debug('WorkQueueController.getPendingCadenceSteps error: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }
}