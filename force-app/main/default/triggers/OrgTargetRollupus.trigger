trigger OrgTargetRollupus on Organization__c (before update) {

    // Trigger new update
    if(Trigger.isUpdate) {  

    // Maps
    Map<Id,String> mapAccs = new Map<Id,String>();
    Map<Id,Id> mapOps = new Map<Id,Id>();
    //Map<String, Object> mapLeads = new Map<String,Object>();
    List<String> listLeads_T = new List<String>();
    List<String> listLeads_NT = new List<String>();
    List<String> listLeads_U = new List<String>();

    Map<String, String> mapLeads_O = new Map<String,String>();


    // Account type
    for(Account acc : [select id, type, name from Account where Organization__c = : Trigger.New]) {
        mapAccs.put(acc.id, acc.type);
    }
    System.debug('>>>>AcctsOnOrg ' + mapAccs);
    System.debug('>>>>AcctMapsize ' + mapAccs.size());
    System.debug('>>>>AcctValues ' + mapAccs.values());

    // Ops from Accounts
    for(Opportunity op : [select id, AccountId from Opportunity where RecordTypeId = '0123u000000aNBgAAM' and Isclosed = False and AccountId = : mapAccs.keySet()]) {
        mapOps.put(op.AccountId, op.id);
    }
    System.debug('>>>>OpsOnOrgAcct ' + mapOps);
    System.debug('>>>>OptMapsize ' + mapOps.size());
    System.debug('>>>>OpValues ' + mapOps.values());

    // Leads - Target, Owned, Unknown
    for(Lead l : [select id, LOGIC_PTL_target_school__c, LOGIC_HS_form_qualification__c, LOGIC_TAM_target_school__c, LOGIC_Owned_by_queue__c, Center_Type__c, FTS_program_type__c, School_size__c, FTS_number_of_students__c, TAM_program_type__c, TAM_number_of_students__c, State from Lead where isconverted = False and Organization__c = : Trigger.New]) {
        String ls = JSON.serialize(l);
        //System.debug('>>>>ls ' + ls);
        Map<String, Object> mapLeads = (Map<String, Object>)JSON.deserializeUntyped(ls);

        String PTL = String.valueOf(mapLeads.get('LOGIC_PTL_target_school__c'));
        String HS = String.valueOf(mapLeads.get('LOGIC_HS_form_qualification__c'));
        String TAM = String.valueOf(mapLeads.get('LOGIC_TAM_target_school__c'));
        String Owned = String.valueOf(mapLeads.get('LOGIC_Owned_by_queue__c'));
        String Prog_PTL = String.valueOf(mapLeads.get('FTS_program_type__c'));
        String Prog_HS = String.valueOf(mapLeads.get('Center_Type__c'));
        String Prog_TAM = String.valueOf(mapLeads.get('TAM_program_type__c'));
        String Size_PTL = String.valueOf(mapLeads.get('FTS_number_of_students__c'));
        String Size_HS = String.valueOf(mapLeads.get('School_size__c'));
        String Size_TAM = String.valueOf(mapLeads.get('TAM_number_of_students__c'));
        String State = String.valueOf(mapLeads.get('State'));
        String Id = String.valueOf(mapLeads.get('Id'));

        // Populate maps and lists        
        if(PTL == 'true' || HS == 'true' || TAM == 'true') {
            listLeads_T.add(Id);
        } else {
            listLeads_NT.add(Id);
        }

        if((Prog_PTL == null && Prog_HS == null && Prog_TAM == null) || (Size_PTL == null && Size_HS == null && Size_TAM == null) || State == null)  {
            listLeads_U.add(Id);
        }

        mapLeads_O.put(Id, Owned);
    }

    System.debug('>>>>listLeads_T ' + listLeads_T);
    System.debug('>>>>listLeads_T ' + listLeads_T.size());

    System.debug('>>>>listLeads_NT ' + listLeads_NT);
    System.debug('>>>>listLeads_NT ' + listLeads_NT.size());

    System.debug('>>>>listLeads_U ' + listLeads_U);
    System.debug('>>>>listLeads_U ' + listLeads_U.size());

    System.debug('>>>>mapLeads_O ' + mapLeads_O);
    System.debug('>>>>OptMapsize ' + mapLeads_O.size());


        for(Organization__c org : Trigger.New) {
            if (mapAccs.values().contains('Customer')) {
                org.Target__c = 'Target';
                org.Sales_Actionable__c = 'Not Actionable';
                org.Account_Status__c = 'Customer';
                org.Open_SaaS_Ops__c = mapOps.size();
                org.Target_Leads__c = listLeads_T.size();
                org.Apex_last_updated_at__c = Datetime.now();

            } else if (mapAccs.values().contains('Prospect') && mapOps.size() > 0) {
                        org.Target__c = 'Target';
                        org.Sales_Actionable__c ='Not Actionable';
                        org.Account_Status__c = 'Prospect';
                        org.Open_SaaS_Ops__c = mapOps.size();
                        org.Target_Leads__c = listLeads_T.size();
                        org.Apex_last_updated_at__c = Datetime.now();

            } else if (mapAccs.values().contains('Prospect') && mapOps.size() == 0) {
                        org.Target__c = 'Target';
                        org.Sales_Actionable__c ='Actionable';
                        org.Account_Status__c = 'Prospect';
                        org.Open_SaaS_Ops__c = mapOps.size();
                        org.Target_Leads__c = listLeads_T.size();
                        org.Apex_last_updated_at__c = Datetime.now();

            } else if (mapAccs.values().contains('Inactive Prospect')) {
                        org.Target__c = 'Target';
                        org.Sales_Actionable__c ='Actionable';
                        org.Account_Status__c = 'Inactive Prospect';
                        org.Open_SaaS_Ops__c = mapOps.size();
                        org.Target_Leads__c = listLeads_T.size();
                        org.Apex_last_updated_at__c = Datetime.now();

            } else if (mapAccs.values().contains('Cancelled Customer')) {
                        org.Target__c = 'Target';
                        org.Sales_Actionable__c = 'Actionable';
                        org.Account_Status__c = 'Canceled Customer';
                        org.Open_SaaS_Ops__c = mapOps.size();
                        org.Target_Leads__c = listLeads_T.size();
                        org.Apex_last_updated_at__c = Datetime.now();            

            //Target not owned
            } else if (listLeads_T.size() > 0 && !mapLeads_O.values().contains('false')) {
                        org.Target__c = 'Target';
                        org.Sales_Actionable__c = 'Actionable';
                        org.Open_SaaS_Ops__c = 0;
                        org.Target_Leads__c = listLeads_T.size();
                        if(mapAccs.size() == 0) {
                            org.Account_Status__c = null;
                            org.Open_SaaS_Ops__c = null;
                        }
                        org.Apex_last_updated_at__c = Datetime.now();
            //Target and owned
            } else if (listLeads_T.size() > 0 && mapLeads_O.values().contains('false')) {
                        org.Target__c = 'Target';
                        org.Sales_Actionable__c = 'Not Actionable';
                        org.Open_SaaS_Ops__c = 0;
                        org.Target_Leads__c = listLeads_T.size();
                        if(mapAccs.size() == 0) {
                            org.Account_Status__c = null;
                            org.Open_SaaS_Ops__c = null;
                        }
                        org.Apex_last_updated_at__c = Datetime.now();
            //Unknown not owned
            } else if (listLeads_T.size() == 0 && !mapLeads_O.values().contains('false') && listLeads_U.size() > 0 && listLeads_NT.size() == listLeads_U.size()) {
                        org.Target__c = 'Unknown';
                        org.Sales_Actionable__c = 'Actionable';
                        org.Open_SaaS_Ops__c = 0;
                        org.Target_Leads__c = listLeads_T.size();
                        if(mapAccs.size() == 0) {
                            org.Account_Status__c = null;
                            org.Open_SaaS_Ops__c = null;
                        }
                        org.Apex_last_updated_at__c = Datetime.now();
            //Unknown and owned
            } else if (listLeads_T.size() == 0 && mapLeads_O.values().contains('false') && listLeads_U.size() > 0 && listLeads_NT.size() == listLeads_U.size()) {
                        org.Target__c = 'Unknown';
                        org.Sales_Actionable__c = 'Not Actionable';
                        org.Open_SaaS_Ops__c = 0;
                        org.Target_Leads__c = listLeads_T.size();
                        if(mapAccs.size() == 0) {
                            org.Account_Status__c = null;
                            org.Open_SaaS_Ops__c = null;
                        }
                        org.Apex_last_updated_at__c = Datetime.now();
            //Non Target not owned
            } else if (listLeads_T.size() == 0 && !mapLeads_O.values().contains('false') && listLeads_NT.size() > 0) {
                    org.Target__c = 'Non-target';
                    org.Sales_Actionable__c = 'Actionable';
                    org.Open_SaaS_Ops__c = 0;
                    org.Target_Leads__c = listLeads_T.size();
                    if(mapAccs.size() == 0) {
                        org.Account_Status__c = null;
                        org.Open_SaaS_Ops__c = null;
                    }
                    org.Apex_last_updated_at__c = Datetime.now();
            //Non Target and owned
            } else if (listLeads_T.size() == 0 && mapLeads_O.values().contains('false') && listLeads_NT.size() > 0) {
                    org.Target__c = 'Non-target';
                    org.Sales_Actionable__c = 'Not Actionable';
                    org.Open_SaaS_Ops__c = 0;
                    org.Target_Leads__c = listLeads_T.size();
                    if(mapAccs.size() == 0) {
                        org.Account_Status__c = null;
                        org.Open_SaaS_Ops__c = null;
                    }
                    org.Apex_last_updated_at__c = Datetime.now();
            //NO lead or accts
            } else if (listLeads_T.size() == 0 && mapAccs.size() == 0) {
                org.Target__c = null;
                org.Sales_Actionable__c = null;
                org.Account_Status__c = null;
                org.Open_SaaS_Ops__c = null;
                org.Target_Leads__c = null;
                org.Apex_last_updated_at__c = Datetime.now();
            }
        }
    }
}