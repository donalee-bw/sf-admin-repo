public class SigmaEmbedClass_Opportunity {
    private string client_id = 'c54707e2b26fb56f2fd196f1e929381db3236dbe3f69a5d40643d85c97748127';
    private string secret = '65a219f86904e5451e7e76c0047bcd417669f77e921f0b42f1e2f404f4e86d58045bc7518afd2c3db5ff1645228767a2c8fcf35729478cc2567ec7384f29da7c';
    public string embed_path { get; set; }
    public string embed_user { get; set; }
    public string embed_account { get; set; }
    public String selectedAccountId { get; set; }
    public List<Opportunity> oppID { get; set; }

    public SigmaEmbedClass_Opportunity() {
        // Fetch the Account ID from the page parameters
        String opportunityIdFromPage = ApexPages.currentPage().getParameters().get('id');
        System.debug('Opportunity ID from page parameters: ' + opportunityIdFromPage);

        // Validate and set the Account ID
        if (String.isNotBlank(opportunityIdFromPage)) {   
            // Fetch opp to get AccountId
            oppID = [SELECT Id, AccountId, Name FROM Opportunity WHERE ID = :opportunityIdFromPage LIMIT 1];
            if(oppID.size()>0 && oppid != NULL){
               embed_account = oppID[0].AccountId;
            }
            else
            {
                embed_account = 'No Account ID Found';  
            }
        } else {
            embed_account = 'No Account ID Found';
        }
        
        // Set the default selected account ID
        selectedAccountId = embed_account;
        System.debug('Initial embed_account set to: ' + embed_account);
    }
    
   // public PageReference selectAccount() {
   //     System.debug('selectAccount() called');
   //     System.debug('selectedAccountId before assignment: ' + selectedAccountId);
        
        // Update embed_account with the selected account ID when an account is chosen
   //   embed_account = selectedAccountId;
        
   //     System.debug('embed_account after assignment in selectAccount: ' + embed_account);
   //     return null;
   // }

    private String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx + 1);
        }
        return randStr;
    }

    public String getGenerateIframeUrl() {      
        System.debug('getGenerateIframeUrl() called');
        
        string url = this.embed_path + '?';
        url += ':nonce=' + generateRandomString(16);
        url += '&:allow_export=true';
        url += '&:time=' + json.serialize(datetime.now().getTime()/1000);
        url += '&:session_length=86400';
        url += '&:mode=explore';
        url += '&:external_user_id=' + EncodingUtil.urlEncode(this.embed_user, 'UTF-8');
        
        // Pass the account ID to the control ID in Sigma
        String controlId = 'SF_AccountID'; // Replace with the actual control ID
        System.debug('BDW Control ID: ' + controlID + ' Salesforce account: ' + this.embed_account + ' ' + embed_account) ;
         
        url += '&' + EncodingUtil.urlEncode(controlId, 'UTF-8') + '=' + EncodingUtil.urlEncode(this.embed_account, 'UTF-8').replace('+', '%20');

        url += '&:client_id=' + this.client_id;
        url += '&:signature=' + EncodingUtil.convertToHex(Crypto.generateMac('HMacSHA256', Blob.valueOf(url), Blob.valueOf(this.secret))); 

        System.debug('Generated URL with Control ID: ' + url);
        return url;
    }
}