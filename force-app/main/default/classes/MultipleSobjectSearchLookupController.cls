public with sharing class MultipleSobjectSearchLookupController {
    
    @AuraEnabled
    public static List<Map<String, String>> searchTerm(String searchTerm, String searchType) {
        List<Map<String, String>> resultList = new List<Map<String, String>>();

            if (searchType == 'Who') {
                // Lead + Contact
                String leadQuery = 'SELECT Id, Name FROM Lead WHERE IsConverted = FALSE ';
                String contactQuery = 'SELECT Id, Name FROM Contact ';
                
                if (!String.isBlank(searchTerm)) {
                    leadQuery += ' AND Name LIKE \'%' + String.escapeSingleQuotes(searchTerm) + '%\'';
                    contactQuery += ' WHERE Name LIKE \'%' + String.escapeSingleQuotes(searchTerm) + '%\'';
                }

                leadQuery += ' ORDER BY LastViewedDate DESC NULLS LAST LIMIT 50';
                contactQuery += ' ORDER BY LastViewedDate DESC NULLS LAST LIMIT 50';

                for (Lead l : Database.query(leadQuery)) {
                    resultList.add(new Map<String,String>{
                        'Id' => l.Id,
                        'Name' => l.Name,
                        'iconName' => 'standard:lead',
                        'objectName' => 'Lead'
                    });
                }
                for (Contact c : Database.query(contactQuery)) {
                    resultList.add(new Map<String,String>{
                        'Id' => c.Id,
                        'Name' => c.Name,
                        'iconName' => 'standard:contact',
                        'objectName' => 'Contact'
                    });
                }
            } 
            else if (searchType == 'What') {
                // Account 
                String query = 'SELECT Id, Name FROM Account WHERE Name LIKE \'%' + String.escapeSingleQuotes(searchTerm) + '%\' LIMIT 50 ';
                for (Account a : Database.query(query)) {
                    resultList.add(new Map<String,String>{
                        'Id' => a.Id,
                        'Name' => a.Name,
                        'iconName' => 'standard:account',
                        'objectName' => 'Account'
                    });
                }
                
                /*
                query = 'SELECT Id, Name FROM Contact WHERE Name LIKE \'%' + String.escapeSingleQuotes(searchTerm) + '%\' LIMIT 50 ';
                for (Contact c : Database.query(query)) {
                    resultList.add(new Map<String,String>{
                        'Id' => c.Id,
                        'Name' => c.Name,
                        'iconName' => 'standard:contact',
                        'objectName' => 'Contact'
                    });
                }

                query = 'SELECT Id, Name FROM Lead WHERE IsConverted = FALSE AND Name LIKE \'%' + String.escapeSingleQuotes(searchTerm) + '%\' LIMIT 50 ';
                for (Lead l : Database.query(query)) {
                    resultList.add(new Map<String,String>{
                        'Id' => l.Id,
                        'Name' => l.Name,
                        'iconName' => 'standard:lead',
                        'objectName' => 'Lead'
                    });
                }
*/
		/*
                query = 'SELECT Id, CaseNumber FROM Case WHERE CaseNumber LIKE \'%' + String.escapeSingleQuotes(searchTerm) + '%\' LIMIT 50 ';
                for (Case cs : Database.query(query)) {
                    resultList.add(new Map<String,String>{
                        'Id' => cs.Id,
                        'Name' => cs.CaseNumber,
                        'iconName' => 'standard:case',
                        'objectName' => 'Case'
                    });
                }
                */
            }
            else if (searchType == 'User') {

                String query = 'SELECT Id, Name FROM User WHERE Name LIKE \'%' + String.escapeSingleQuotes(searchTerm) + '%\' LIMIT 50 ';
                for (User u : Database.query(query)) {
                    resultList.add(new Map<String,String>{
                        'Id' => u.Id,
                        'Name' => u.Name,
                        'iconName' => 'standard:user',
                        'objectName' => 'User'
                    });
                }
            }
                
            
            return resultList;

    }
}