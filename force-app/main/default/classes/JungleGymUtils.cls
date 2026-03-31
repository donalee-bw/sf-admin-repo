/*
*********************************************************
Apex Class Name    : JungleGymUtils
Created Date       : 6/1/2025
@description       : Utility class for data normalization and formatting used throughout 
the JungleGym integration. Provides helper methods to map center types, 
time zones, and countries to expected values, and to safely parse 
string values into numbers. Supports consistent formatting for outbound 
callouts and data transformation logic.
@author            : Justin Strout
Modification Log:
Ver   Date         Author                               Modification
1.0   6/1/2025     Justin Strout                        Initial Implementation
*********************************************************
*/

public class JungleGymUtils {
    public static String mapCenterType(String centerType) {
        if (centerType == null) return null;
        switch on centerType {
            when 'Preschool or Child Care' { return 'preschool_or_child_care'; }
            when 'After School'            { return 'after_school'; }
            when 'Camp_2'                  { return 'camp'; }
            when 'Other_2'                 { return 'other'; }
            when else                      { return centerType; }
        }
    }
    
    public static String mapTimeZone(String tz) {
        if (tz == null) return null;
        switch on tz {
            when 'Pacific'                    { return 'Pacific Time (US & Canada)'; }
            when 'Mountain'                   { return 'Mountain Time (US & Canada)'; }
            when 'Central'                    { return 'Central Time (US & Canada)'; }
            when 'Eastern'                    { return 'Eastern Time (US & Canada)'; }
            when 'Hawaii - Aleutian Standard' { return 'Hawaii'; }
            when 'Alaska - Alaska Daylight'   { return 'Alaska'; }
            when else                         { return tz; }
        }
    }
    
    public static Decimal parseDecimal(String val, String stripChar) {
        if (val == null) return null;
        return Decimal.valueOf(val.replace(stripChar, ''));
    }
    
    public static Integer parseInteger(String val, String stripChar) {
        if (val == null) return null;
        String s = val.replace(stripChar, '').replace('.', '');
        return Integer.valueOf(s);
    }
    
    public static Boolean effectiveExistsInJG(Boolean existsInJG, Boolean overrideFlag) {
        return overrideFlag ? false : existsInJG;
            }
    
    public static String replaceCountry(String country) {
        if (country == null) return null;
        final Set<String> usAliases = new Set<String>{'usa','united states','united states of america','us'};
            if (usAliases.contains(country.trim().toLowerCase())) {
                return 'US';
            }
        if (country.equalsIgnoreCase('canada')) return 'CA';
        return country;
    }
}