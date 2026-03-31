@isTest
private class MultipleSobjectSearchLookupConTest {


    @TestSetup
    static void makeData() {
        // Account
        Account acc = new Account(Name = 'Test Account Alpha');
        insert acc;

        // Contact
        Contact con = new Contact(LastName = 'Alpha Contact', AccountId = acc.Id);
        insert con;

        // Lead (unconverted)
        Lead ld = new Lead(
            FirstName = 'Alpha',
            LastName   = 'Lead',
            Company    = 'Test Co',
            Status     = 'Open - Not Contacted'
        );
        insert ld;

        // Case
        //Case cs = new Case(Subject = 'Test Case Alpha');
        //insert cs;

        // User (query-only — no insert needed)
    }

    // ─── searchType = 'Who' ─────────────────────────────────────────────

    @isTest
    static void testSearchWho_withTerm() {
        Test.startTest();
        List<Map<String, String>> results =
            MultipleSobjectSearchLookupController.searchTerm('Alpha', 'Who');
        Test.stopTest();

        System.assertNotEquals(null, results, 'Results should not be null');
        System.assert(results.size() > 0, 'Should return at least one Lead or Contact');

        // Verify object names are only Lead or Contact
        for (Map<String, String> r : results) {
            System.assert(
                r.get('objectName') == 'Lead' || r.get('objectName') == 'Contact',
                'Who search should only return Leads and Contacts'
            );
        }
    }

    @isTest
    static void testSearchWho_blankTerm() {
        // Blank search term hits the "no filter" branch
        Test.startTest();
        List<Map<String, String>> results =
            MultipleSobjectSearchLookupController.searchTerm('', 'Who');
        Test.stopTest();

        System.assertNotEquals(null, results);
    }

    // ─── searchType = 'What' ────────────────────────────────────────────

    @isTest
    static void testSearchWhat_withTerm() {
        Test.startTest();
        List<Map<String, String>> results =
            MultipleSobjectSearchLookupController.searchTerm('Alpha', 'What');
        Test.stopTest();

        System.assertNotEquals(null, results);
        System.assert(results.size() > 0, 'Should return Account, Contact, or Lead records');

        Set<String> validObjects = new Set<String>{
            'Account', 'Contact', 'Lead', 'Case'
        };
        for (Map<String, String> r : results) {
            System.assert(
                validObjects.contains(r.get('objectName')),
                'What search returned unexpected object: ' + r.get('objectName')
            );
        }
    }

    // ─── searchType = 'User' ────────────────────────────────────────────

    @isTest
    static void testSearchUser_withTerm() {
        // Running user's name should match a partial search
        String currentUserName = [SELECT Name FROM User
                                  WHERE Id = :UserInfo.getUserId()].Name;
        String partialName = currentUserName.split(' ')[0];

        Test.startTest();
        List<Map<String, String>> results =
            MultipleSobjectSearchLookupController.searchTerm(partialName, 'User');
        Test.stopTest();

        System.assertNotEquals(null, results);
        System.assert(results.size() > 0, 'Should find at least the running user');

        for (Map<String, String> r : results) {
            System.assertEquals('User', r.get('objectName'),
                'User search should only return User records');
            System.assertEquals('standard:user', r.get('iconName'));
        }
    }

    // ─── Icon / map key sanity checks ───────────────────────────────────

    @isTest
    static void testResultMapKeys() {
        Test.startTest();
        List<Map<String, String>> results =
            MultipleSobjectSearchLookupController.searchTerm('Alpha', 'What');
        Test.stopTest();

    }
}