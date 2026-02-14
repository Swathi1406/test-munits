package com.auchan.google;

import io.jsonwebtoken.Jwts;
import java.security.KeyFactory;
import java.security.NoSuchAlgorithmException;
import java.security.PrivateKey;
import java.security.spec.InvalidKeySpecException;
import java.security.spec.PKCS8EncodedKeySpec;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Base64;
import java.util.Date;


public class GenerateJWTToken {


	public static String createJwtSignedHMAC(String issuer, String subject, String scope, String tokenUrl, String key, int tokenDuration) throws InvalidKeySpecException, NoSuchAlgorithmException {

		PrivateKey privateKey = getPrivateKey(key);
		Instant now = Instant.now();
		//System.out.println("issuer--" + issuer);
		//Auchan Service Account JWT
		String jwtToken = Jwts.builder().setIssuer(issuer)  
				.setSubject(subject) 
				.claim("scope", scope) 
				.setAudience(tokenUrl).setIssuedAt(Date.from(now))
				.setExpiration(Date.from(now.plus(tokenDuration, ChronoUnit.MINUTES))).signWith(privateKey).compact();

		return jwtToken;
	}


	private static PrivateKey getPrivateKey(String key) throws NoSuchAlgorithmException, InvalidKeySpecException {
		 
		String rsaPrivateKey = key;
		//Auchan Service Account key
//		String rsaPrivateKey = "-----BEGIN PRIVATE KEY-----"
//	               + "MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDl5Ral049AVm8M"
//				   + "b/0xtgEtHRxdFVsP9xmOlCJz5r+JG6QBIIY0F8e9hJDqWv7B9ccrJtDthx8CZmQe"
//	               + "6/NlEQtImCAvGowXuo7KHvtPFgv7C772yNCfvMErVW5zM4XXGuJqGCQWp0zCj5TV"
//				   + "70GzCLzYIM7AU29MwGUda64Tat9WZP0UzCXvB8wFwxFhPeuct2GZO2BmRUrcWsfG"
//	               + "5tZ3XrM4VWsgp1yvl/RZK6r4xYd8yjZpjqZRTRB6N7Gl5egsgfhHrw6UI9U1bQDx"
//				   + "4VaqXoTv+MjTFofgnID73h/OLNNZkKNGIBWE3vBewEToQ9ftlv+qjGnpIs3vrXpU"
//	               + "BJh3bhGBAgMBAAECggEABwndCCWyiJc83iYdm+SFI7L099qcB6CanTVm2qKRcaqx"
//				   + "ekFbKoQh3ukMoMg5bYnPV8Bf/C27YtDsts+li44aiNXzgk2vRVi2X3TUX+b+ZejF"
//	               + "p3ude46FYYTDlW5Z5iySCwqDLFhh7sEDnwssuUUGtx1GBzhmu3RWhDCUS07l2Ji/"
//				   + "FfirVK7IDGTvChmYjkkiKh8rhU10hrl1eOy1C9gdM3oefCquE8Gqm8S5k0KBia2q"
//	               + "YrDxepnLAu2Tuj0sEbImSQAH3BYE1egaOI5Ut341hz89mxvIPBxye8W40xXKcpb0"
//				   + "ozVhgKxZCGsPyTM8oPZfVZs5zFp5t+5596v3ANATYwKBgQDzRfsYbidla8mMMWsU"
//	               + "6A+Dx8/baDllBU0xHnrLXR1BLcXHN/7UkOWbVfoBxohMSku+YF4ZJdmiBKgdperE"
//				   + "SjewgBrloxsyl1GitndLxsATXhK9qyS+U87D7HkSjwYEy+JR7QulFRKMCviClqCQ"
//	               + "K6Y64dk0VQUxdMMw4QrLOgFJgwKBgQDx6+/0IgCmf9JsfqdwlrZ7Oc5Q8OiDxI4b"
//				   + "CuUgJcgbJN3a3JSY583LuFKZDwPoTpnDla7W2DsGQfD4Pd9qM0dpgb/P30BFvrZ+"
//	               + "36x6zc+wWPYTBZMTPoG/1sjPpcd/FUCxZhdYw0Ige1HYGkNLTfccLsK5G+U1mCvQ"
//				   + "m118ww99qwKBgAnkeZ53tEBqjqqVw934xdC9ClXIujTCb24k6Cdm5O6mltlQDJvG"
//	               + "PKABcgYqdZZsmwHl1028fUoaWF/ERHSw8+zIeM+Hv25iOt6b/uPk9CCVfbuavwbC"
//				   + "T7El55J6oGsHg2+DbSrMXZG2TH6681KJg9v3HScEog5tyhYtwIudEzpTAoGBAJld"
//	               + "lJo1cCodgH3NcULcGMVX6SbBAvZ+BgS4zHar3QbwQUE9c2rYEUwkByEHNtfv9GTc"
//				   + "oKGNJSYbabNGLjt6VLxbSAl1I57Tf4hBLmwPy6mlTCLU9t9NUh4XAOk61JUJGSEd"
//	               + "cpGP/3zuEP2p8J1tyMlyD3ogaBeo56XwyLyOQGTPAoGBAKe5Nqj1yvq62iO3UI3O"
//				   + "OptZoAolIaTjzw1KN+QeQ03T4GflNXfj4ZAim1RcKI8BxovRv93ya2wN85FxzT99"
//	               + "eDMrQJ3NkbXoh65vNLk3F3BkDMqtWmDYMwFYBDhKpd4l9tmC4f2mG+i9/2QqbAyY"
//				   + "UM5FE3oHFuXR9dVVcGvvBc93"
//	               + "-----END PRIVATE KEY-----";
		//System.out.println(rsaPrivateKey);
		rsaPrivateKey = rsaPrivateKey.replace("-----BEGIN PRIVATE KEY-----", "");
		rsaPrivateKey = rsaPrivateKey.replace("-----END PRIVATE KEY-----", "");
        
		PKCS8EncodedKeySpec keySpec = new PKCS8EncodedKeySpec(Base64.getDecoder().decode(rsaPrivateKey));
		KeyFactory kf = KeyFactory.getInstance("RSA");
		PrivateKey privKey = kf.generatePrivate(keySpec);
		return privKey;
	}
	
//	public static void main(String[] args) throws NoSuchAlgorithmException, InvalidKeySpecException {
//		new GenerateJWTToken();
//		GenerateJWTToken.getPrivateKey();
//	}
}