public class SigmaEmbedClass_JWTTest {
    
    // Credentials - MOVE TO CUSTOM METADATA FOR PRODUCTION
    private String client_id = 'c54707e2b26fb56f2fd196f1e929381db3236dbe3f69a5d40643d85c97748127';
    private String secret = '65a219f86904e5451e7e76c0047bcd417669f77e921f0b42f1e2f404f4e86d58045bc7518afd2c3db5ff1645228767a2c8fcf35729478cc2567ec7384f29da7c';
    
    // Properties set from Visualforce component
    public String embed_path { get; set; }
    public String embed_user { get; set; }
    public String sf_account_id { get; set; }  // Salesforce Account ID for filtering
    
    // Base64URL encoding (JWT requires URL-safe base64)
    private String base64UrlEncode(Blob input) {
        String base64 = EncodingUtil.base64Encode(input);
        base64 = base64.replace('+', '-');
        base64 = base64.replace('/', '_');
        base64 = base64.replace('=', '');
        return base64;
    }
    
    // Generate a unique ID for jti claim
    private String generateJti() {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
        String randStr = '';
        while (randStr.length() < 32) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx + 1);
        }
        return randStr;
    }
    
    // Build the JWT token
    private String generateJWT() {
        
        // JWT Header
        Map<String, String> header = new Map<String, String>{
            'alg' => 'HS256',
            'typ' => 'JWT',
            'kid' => client_id  // Required: embed client ID
        };
        String headerJson = JSON.serialize(header);
        String encodedHeader = base64UrlEncode(Blob.valueOf(headerJson));
        
        // JWT Payload
        Long nowSeconds = DateTime.now().getTime() / 1000;
        Long expSeconds = nowSeconds + 3600;  // 1 hour (max 30 days)
        
        Map<String, Object> payload = new Map<String, Object>{
            // Required claims
            'sub' => embed_user,              // User email (Required)
            'jti' => generateJti(),           // Unique token ID (Required)
            'iat' => nowSeconds,              // Issued at time (Required)
            'exp' => expSeconds,              // Expiration time (Required)
            
            // Optional claims
            'iss' => client_id,               // Issuer (Optional)
            'account_type' => 'Viewer',       // Permission level
            'teams' => new List<String>{'Salesforce_Embed'}
        };
        
        // Add user_attributes with SF_AccountID for row-level security
        if (String.isNotBlank(sf_account_id)) {
            Map<String, String> userAttributes = new Map<String, String>{
                'SF_AccountID' => sf_account_id
            };
            payload.put('user_attributes', userAttributes);
        }
        
        String payloadJson = JSON.serialize(payload);
        String encodedPayload = base64UrlEncode(Blob.valueOf(payloadJson));
        
        // Signature
        String signatureInput = encodedHeader + '.' + encodedPayload;
        Blob signature = Crypto.generateMac(
            'HMacSHA256', 
            Blob.valueOf(signatureInput), 
            Blob.valueOf(secret)
        );
        String encodedSignature = base64UrlEncode(signature);
        
        return encodedHeader + '.' + encodedPayload + '.' + encodedSignature;
    }
    
    // Main method called by Visualforce component
    public String getGenerateIframeUrl() {
        String jwt = generateJWT();
        String url = embed_path + '?:jwt=' + EncodingUtil.urlEncode(jwt, 'UTF-8') + '&:embed=true';
        return url;
    }
}