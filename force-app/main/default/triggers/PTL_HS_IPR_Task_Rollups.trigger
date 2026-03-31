trigger PTL_HS_IPR_Task_Rollups on Task (after insert, after update, after delete) {

    public id who;
    public string rec_type;
    public Lead l;
    public Contact c;

    if(Trigger.isInsert || Trigger.isUpdate){
        for(Task t : Trigger.New) {
            who = t.WhoID;
            rec_type = t.RecordTypeId;
        }

        //system.debug('>>>> rec ' + rec_type);

        if(rec_type == '0121I000000OEYAQA4' || rec_type == '0121I000000OEvZQAW' || rec_type == '0121I000000OEnWQAW') {
            // find all tasks with same whoID lead
            List<Task> PTL_task = [select id, RecordTypeId from Task where WhoID=:who and status = 'Open' and RecordTypeId = '0121I000000OEYAQA4'];
            Integer PTL_task_size = PTL_task.size();
            List<Task> HS_task = [select id, RecordTypeId from Task where WhoID=:who and status = 'Open' and RecordTypeId = '0121I000000OEvZQAW'];
            Integer HS_task_size = HS_task.size();
            List<Task> IPR_task = [select id, RecordTypeId from Task where WhoID=:who and status = 'Open' and RecordTypeId = '0121I000000OEnWQAW'];
            Integer IPR_task_size = IPR_task.size();

        // find lead / contact whoID
        try {
            l = [select id from Lead where id=:who];
        }
        catch (Exception e) {
        }
        try {
            c = [select id from Contact where id=:who];
        }
        catch (Exception e) {
        }

        // update lead
        if(l != null) {
            if(!PTL_task.isEmpty()) {
                l.LOGIC_Open_PTL_task__c = PTL_task_size;
            } else {
                l.LOGIC_Open_PTL_task__c = null;
            }
            if(!HS_task.isEmpty()) {
                l.LOGIC_Open_HS_task__c = HS_task_size;
            } else {
                l.LOGIC_Open_HS_task__c = null;
            }
            if(!IPR_task.isEmpty()) {
                l.LOGIC_Open_IPR_task__c = IPR_task_size;
            } else {
                l.LOGIC_Open_IPR_task__c = null;
            }
            update l;
        }
        // update contact
        if(c != null) {
            if(!PTL_task.isEmpty()) {
                c.LOGIC_Open_PTL_task__c = PTL_task_size;
            } else {
                c.LOGIC_Open_PTL_task__c = null;
            }
            if(!HS_task.isEmpty()) {
                c.LOGIC_Open_HS_task__c = HS_task_size;
            } else {
                c.LOGIC_Open_HS_task__c = null;
            }
            if(!IPR_task.isEmpty()) {
                c.LOGIC_Open_IPR_task__c = IPR_task_size;
            } else {
                c.LOGIC_Open_IPR_task__c = null;
            }
            update c;
        }

        }
    }


        if(Trigger.isDelete){
        for(Task t : Trigger.Old) {
            who = t.WhoID;
            rec_type = t.RecordTypeId;
        }

        //system.debug('>>>> rec ' + rec_type);

        if(rec_type == '0121I000000OEYAQA4' || rec_type == '0121I000000OEvZQAW' || rec_type == '0121I000000OEnWQAW') {
            // find all tasks with same whoID lead
            List<Task> PTL_task = [select id, RecordTypeId from Task where WhoID=:who and status = 'Open' and RecordTypeId = '0121I000000OEYAQA4'];
            Integer PTL_task_size = PTL_task.size();
            List<Task> HS_task = [select id, RecordTypeId from Task where WhoID=:who and status = 'Open' and RecordTypeId = '0121I000000OEvZQAW'];
            Integer HS_task_size = HS_task.size();
            List<Task> IPR_task = [select id, RecordTypeId from Task where WhoID=:who and status = 'Open' and RecordTypeId = '0121I000000OEnWQAW'];
            Integer IPR_task_size = IPR_task.size();

        // find lead / contact whoID
        try {
            l = [select id from Lead where id=:who];
        }
        catch (Exception e) {
        }
        try {
            c = [select id from Contact where id=:who];
        }
        catch (Exception e) {
        }

        // update lead
        if(l != null) {
            if(!PTL_task.isEmpty()) {
                l.LOGIC_Open_PTL_task__c = PTL_task_size;
            } else {
                l.LOGIC_Open_PTL_task__c = null;
            }
            if(!HS_task.isEmpty()) {
                l.LOGIC_Open_HS_task__c = HS_task_size;
            } else {
                l.LOGIC_Open_HS_task__c = null;
            }
            if(!IPR_task.isEmpty()) {
                l.LOGIC_Open_IPR_task__c = IPR_task_size;
            } else {
                l.LOGIC_Open_IPR_task__c = null;
            }
            update l;
        }
        // update contact
        if(c != null) {
            if(!PTL_task.isEmpty()) {
                c.LOGIC_Open_PTL_task__c = PTL_task_size;
            } else {
                c.LOGIC_Open_PTL_task__c = null;
            }
            if(!HS_task.isEmpty()) {
                c.LOGIC_Open_HS_task__c = HS_task_size;
            } else {
                c.LOGIC_Open_HS_task__c = null;
            }
            if(!IPR_task.isEmpty()) {
                c.LOGIC_Open_IPR_task__c = IPR_task_size;
            } else {
                c.LOGIC_Open_IPR_task__c = null;
            }
            update c;
        }

        }
    }
}