/*
*********************************************************
Apex Class Name    : JungleGymPayloadBuilder
Created Date       : 6/1/2025
@description       : This class builds the structured data (payload) used for sending Opportunities and 
Child Site records to the JungleGym platform. It gathers and formats related information 
such as Account, Contact, and Opportunity or Child Site Creation details, 
applies normalization rules using utility methods, and returns the final payload as a map 
for use in API callouts. Supports both single-site and multi-site record formats.
@author            : Justin Strout
Modification Log:
Ver   Date         Author                               Modification
1.0   6/1/2025     Justin Strout                        Added support for multi-site (Child Site) payloads
*********************************************************
*/

public class JungleGymPayloadBuilder {
        
    // 1) Use Opportunity for Single-Site or Parent Opp of Multi-Site
    public static Map<String, Object> buildFrom(Opportunity opp) {
        Map<String,Object> payload = new Map<String,Object>();
        
        final Boolean existsInJG = JungleGymUtils.effectiveExistsInJG(
            opp.Exists_In_JG__c,
            opp.Exists_In_JG_Override__c
        );


        // Account
        payload.put('Account', new Map<String,Object>{
            'id'               => opp.AccountId,
            'name'             => opp.Account.Name,
            'centerType'       => JungleGymUtils.mapCenterType(opp.Center_Type__c),
            'capacity'         => opp.Capacity__c,
            'multiSite'        => opp.Number_of_Schools__c > 1,
            'billingStreet'    => opp.Account.BillingStreet,
            'billingCity'      => opp.Account.BillingCity,
            'billingState'     => opp.Account.BillingState,
            'billingPostalCode'=> opp.Account.BillingPostalCode,
            'billingCountry'   => JungleGymUtils.replaceCountry(opp.Account.BillingCountry)
                });
        
        // Opportunity
        payload.put('Opportunity', new Map<String,Object>{
            'id'                   => opp.Id,
            'name'                 => opp.Name,
            'billingInterval'      => (opp.Subscription__c == 'Annual') ? 'annually' : opp.Subscription__c,
            'amount'               => opp.Amount,
            'promoCode'            => opp.Promo_Code__c,
            'firstBillDate'        => opp.First_Bill_Date__c,
            'achFeeStructure'      => (opp.ACH_Fee_Structure__c == 'Variable') ? 'percentage' : opp.ACH_Fee_Structure__c,
            'achFeeFlat'           => JungleGymUtils.parseDecimal(opp.ACH_Fee_Flat__c, '$'),
            'achFeePercentage'     => JungleGymUtils.parseDecimal(opp.ACH_Fee_Variable__c, '%'),
            'achFeeMax'            => JungleGymUtils.parseInteger(opp.ACH_Fee_Max__c, '$'),
            'paymentProcessingFee' => opp.HelloSign_Payment_Processing_Fee__c,
            'repEmail'             => opp.Owner.Email,
            'objectType'           => 'parent', 
            'organizationId'       => existsInJG ? opp.Account.bw_Organization_UUID__c : opp.Organization_Id__c,
            'schoolId'             => existsInJG ? opp.Account.bw_School_UUID__c       : opp.Closed_Won_School_ID__c,
            'existsInJG'		   => existsInJG,
            'JGRole'               => opp.JG_Identification_Reason__c,
            'payerType'            => (opp.SaaS_Offline_Payer__c) ? 'offline' : 'online'
            
            
                        });
        
        // Contact
        if (opp.Contact__r != null) {
            payload.put('Contact', new Map<String,Object>{
                'id'         => opp.Contact__r.Id,
                'firstName'  => opp.Contact__r.FirstName,
                'lastName'   => opp.Contact__r.LastName,
                'email'      => opp.Contact__r.Email,
                'phone'      => opp.Contact__r.Normalized_Phone__c,
                'usTimeZone' => JungleGymUtils.mapTimeZone(opp.Contact__r.US_Time_Zone__c)
                    });
        }
        
        return payload;
    }
    
    // For multi-site Opportunities we send the data from the Child_Site_Creation record(s) since the Opp is not created yet
    public static Map<String, Object> buildFrom(Child_Site_Creation__c cs, Contact con) {
        Map<String,Object> payload = new Map<String,Object>();

        final Boolean existsInJG = JungleGymUtils.effectiveExistsInJG(
            cs.Original_CW_Opportunity__r.Exists_In_JG__c,
            cs.Original_CW_Opportunity__r.Exists_In_JG_Override__c
        );
        
        // "Account" information from child-site
        payload.put('Account', new Map<String,Object>{
            'name'             => cs.Child_Site_Name__c,
            'id'		       => cs.Original_CW_Opportunity__r.AccountId,	
            'centerType'       => JungleGymUtils.mapCenterType(cs.Center_Type__c),
            'capacity'         => cs.Capacity__c,
            'multiSite'        => true,
            'billingStreet'    => cs.Street_Address__c,
            'billingCity'      => cs.City__c,
            'billingState'     => cs.State_Province__c,
            'billingPostalCode'=> cs.Zip_Postal_Code__c,
            'billingCountry'   => JungleGymUtils.replaceCountry(cs.Country__c)
                });
        
        // "Opportunity" information from child-site
        payload.put('Opportunity', new Map<String,Object>{
            //child-site id is sent as Opp Id because JungleGym writes back to Child Site Creation for Multi Site
            'id'                   => cs.Id, 
            'name'                 => cs.Child_Site_Name__c,
            'billingInterval'      => (cs.Original_CW_Opportunity__r.Subscription__c == 'Annual')? 'annually': cs.Original_CW_Opportunity__r.Subscription__c,
            'amount'               => cs.Amount__c,
            'promoCode'            => cs.Original_CW_Opportunity__r.Promo_Code__c,
            'firstBillDate'        => cs.First_Bill_Date__c,
            //billing information is the same as the Parent so we pull this from the original CW opp
            'achFeeStructure'      => (cs.Original_CW_Opportunity__r.ACH_Fee_Structure__c == 'Variable') ? 'percentage': cs.Original_CW_Opportunity__r.ACH_Fee_Structure__c,
            'achFeeFlat'           => JungleGymUtils.parseDecimal(cs.Original_CW_Opportunity__r.ACH_Fee_Flat__c,'$'),
            'achFeePercentage'     => JungleGymUtils.parseDecimal(cs.Original_CW_Opportunity__r.ACH_Fee_Variable__c,'%'),
            'achFeeMax'            => JungleGymUtils.parseInteger(cs.Original_CW_Opportunity__r.ACH_Fee_Max__c,'$'),
            'paymentProcessingFee' => cs.Original_CW_Opportunity__r.HelloSign_Payment_Processing_Fee__c,
            'repEmail'             => cs.Original_CW_Opportunity__r.Owner.Email,
            'objectType'           => (cs.Original_CW_Opportunity__r.Site_Add_Details__c == 'Add to Existing JG Org') ? 'site-add' : 'child',
            'organizationId'       => (existsInJG || cs.Original_CW_Opportunity__r.Site_Add_Details__c == 'Add to Existing JG Org') ? cs.Original_CW_Opportunity__r.Account.bw_Organization_UUID__c : cs.Original_CW_Opportunity__r.Organization_Id__c,
            'schoolId'             => existsInJG ? cs.Original_CW_Opportunity__r.Account.bw_School_UUID__c : null,
            'existsInJG'           => cs.Original_CW_Opportunity__r.Exists_In_JG__c,
            'JGRole'               => cs.Original_CW_Opportunity__r.JG_Identification_Reason__c,
            'payerType'            => (cs.Original_CW_Opportunity__r.SaaS_Offline_Payer__c) ? 'offline' : 'online'
                        });
        
        // Contact will already exist in Salesforce so we use Contact data
        if (con != null) {
            payload.put('Contact', new Map<String,Object>{
                'id'         => cs.Contact__c,
                'firstName'  => con.FirstName,
                'lastName'   => con.LastName,
                'email'      => con.Email,
                'phone'      => con.Normalized_Phone__c,
                'usTimeZone' => JungleGymUtils.mapTimeZone(con.US_Time_Zone__c)
                    });
        }
        
        return payload;
    }
}