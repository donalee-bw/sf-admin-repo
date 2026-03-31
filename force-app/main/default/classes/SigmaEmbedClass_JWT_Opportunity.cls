public class SigmaEmbedClass_JWT_Opportunity {
    // CHANGE: These credentials stay the same, but are now used for JWT signing
    private string client_id = 'c54707e2b26fb56f2fd196f1e929381db3236dbe3f69a5d40643d85c97748127';
    private string secret = '65a219f86904e5451e7e76c0047bcd417669f77e921f0b42f1e2f404f4e86d58045bc7518afd2c3db5ff1645228767a2c8fcf35729478cc2567ec7384f29da7c';
    
    // CHANGE: embed_path is now the workbook URL, not the embed path
    public string embed_path { get; set; }
    public string embed_user { get; set; }
    public string embed_account { get; set; }
    public String selectedAccountId { get; set; }
    public List<Opportunity> oppID { get; set; }

    public SigmaEmbedClass_JWT_Opportunity() {
        // NO CHANGE: Constructor stays exactly the same
        String opportunityIdFromPage = ApexPages.currentPage().getParameters().get('id');
        System.debug('Opportunity ID from page parameters: ' + opportunityIdFromPage);

        if (String.isNotBlank(opportunityIdFromPage)) {     
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
        
        selectedAccountId = embed_account;
        System.debug('Initial embed_account set to: ' + embed_account);
    }

    // NO CHANGE: This helper method stays the same
    private String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx + 1);
        }
        return randStr;
    }
    
    // NEW: Helper method for Base64 URL encoding (JWT requires URL-safe base64)
    private String base64UrlEncode(Blob input) {
        String base64 = EncodingUtil.base64Encode(input);
        // Convert to URL-safe base64: replace + with -, / with _, remove padding =
        base64 = base64.replace('+', '-');
        base64 = base64.replace('/', '_');
        base64 = base64.replace('=', '');
        return base64;
    }
    
    // NEW: Helper method for Base64 URL encoding a string
    private String base64UrlEncodeString(String input) {
        return base64UrlEncode(Blob.valueOf(input));
    }

    // CHANGE: This is the main method that changed significantly
    public String getGenerateIframeUrl() {        
        System.debug('getGenerateIframeUrl() called - JWT VERSION');
        
        // ==========================================
        // STEP 1: Build JWT Header
        // ==========================================
        // CHANGE: Instead of URL params, we build a JWT header
        // Header must include: alg (algorithm) and kid (key id = client_id)
        String header = '{"alg":"HS256","typ":"JWT","kid":"' + this.client_id + '"}';
        String encodedHeader = base64UrlEncodeString(header);
        
        // ==========================================
        // STEP 2: Build JWT Payload (Claims)
        // ==========================================
        // CHANGE: URL parameters become JWT claims
        Long currentTime = datetime.now().getTime() / 1000;  // Unix timestamp in seconds
        Long expirationTime = currentTime + 86400;           // 24 hours (same as your session_length)
        String jti = generateRandomString(16);               // Replaces :nonce
        
        // Build the payload JSON
        // Required claims: sub, jti, iat, exp
        // Optional: iss (issuer = client_id)
        String payload = '{' +
            '"sub":"' + this.embed_user + '",' +             // CHANGE: :external_user_id -> sub claim
            '"iss":"' + this.client_id + '",' +              // CHANGE: :client_id -> iss claim
            '"jti":"' + jti + '",' +                         // CHANGE: :nonce -> jti claim
            '"iat":' + currentTime + ',' +                   // CHANGE: :time -> iat claim
            '"exp":' + expirationTime +                      // CHANGE: :session_length calculation -> exp claim
        '}';
        String encodedPayload = base64UrlEncodeString(payload);
        
        // ==========================================
        // STEP 3: Create Signature
        // ==========================================
        // CHANGE: Instead of signing the full URL, we sign header.payload
        String signatureInput = encodedHeader + '.' + encodedPayload;
        Blob signatureBlob = Crypto.generateMac(
            'HmacSHA256', 
            Blob.valueOf(signatureInput), 
            Blob.valueOf(this.secret)
        );
        String encodedSignature = base64UrlEncode(signatureBlob);
        
        // ==========================================
        // STEP 4: Assemble the JWT
        // ==========================================
        String jwt = encodedHeader + '.' + encodedPayload + '.' + encodedSignature;
        
        // ==========================================
        // STEP 5: Build the final URL
        // ==========================================
        // CHANGE: URL structure is completely different
        // Old: embed_path?:nonce=X&:time=Y&:signature=Z&controlId=value
        // New: embed_path?:jwt={token}&:embed=true&controlId=value
        
        String url = this.embed_path;
        url += '?:jwt=' + EncodingUtil.urlEncode(jwt, 'UTF-8');
        url += '&:embed=true';
        
        // CHANGE: :mode and :allow_export are now controlled via account_type permissions
        // These URL params are no longer needed/supported with JWT
        // If you need explore mode, set it in the account_type in Sigma admin
        
        // NO CHANGE: Control values are still passed as URL parameters (after the JWT)
        String controlId = 'SF_AccountID';
        System.debug('BDW Control ID: ' + controlID + ' Salesforce account: ' + this.embed_account);
        url += '&' + EncodingUtil.urlEncode(controlId, 'UTF-8') + '=' + 
               EncodingUtil.urlEncode(this.embed_account, 'UTF-8').replace('+', '%20');

        System.debug('Generated JWT URL with Control ID: ' + url);
        return url;
    }
}