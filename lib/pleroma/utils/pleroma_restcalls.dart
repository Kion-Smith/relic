
import 'dart:convert';
import "package:http/http.dart" as http;
import 'package:relic/pleroma/pleroma_account.dart';
import 'package:relic/pleroma/pleroma_auth_data.dart';

import '../pleroma_auth_storage.dart';
import '../pleroma_post.dart';


String getTokens = "/apps";
String clientName = "Relic";
String redirectURI = "urn:ietf:wg:oauth:2.0:oob";
String scopes = "read write follow";

String authorize = "/oauth/authorize";
String clientId = "?client_id=";
String redirectReq = "&redirect_uri=";
String responseType = "&response_type=";
String resTypeCode = "code";
String scope = "&scope=";

String login = "/oauth/token";
String timeline="/api/v1/timelines/home";
String publicTimeline="/api/v1/timelines/public";
String verifyUser = "/api/v1/accounts/verify_credentials";
String registerApp = "/api/v1/apps/";
String getAccount ="/api/v1/accounts/";

Future<PleromaAccount> getAccountDetails(String account) async 
{
  String? domain = await PleromaAuthenticationStorage.getFediverseNode();
  if(domain == null)
  {
    throw Exception("Domain Name was null");
  }

  final response = await http.get(Uri.parse("https://$domain$getAccount$account"));
  if(response.statusCode == 200)
  {
    return PleromaAccount.fromJson(jsonDecode(response.body));
  }
  else
  {
    throw Exception("Failed to retrive from this account from https://$domain$getAccount$account");
  }
}

// Was getClientTokens
Future<PleromaAuth> registerRelicApp() async
{
  String? domain = await PleromaAuthenticationStorage.getFediverseNode();
  if(domain == null)
  {
    throw Exception("Domain Name was null");
  }

  http.Response response = await http.post(
    Uri.parse("https://$domain$registerApp"),
    headers: <String,String> {
      "Content-Type":"application/json; charset=UTF-8"
    },
    body: jsonEncode( <String,String>{
      'baseurl' : domain,
      'client_name':clientName,
      'redirect_uris':redirectURI,
      'scopes':scopes
    })
  );

  if(response.statusCode == 200)
  {
    return PleromaAuth.fromJson(jsonDecode(response.body));
  }
  else
  {
    throw Exception("Failed to register relic as an app for $domain. ${response.body}");
  }
}

Future<String> getAuthorizationURL(PleromaAuth auth) async
{

  String? domain = await PleromaAuthenticationStorage.getFediverseNode();
  if(domain == null)
  {
    throw MissingDomainNameExcepetion("Domain name was null");
  }

  return "https://"+domain+authorize+clientId+auth.clientID+redirectReq+
    redirectURI+responseType+resTypeCode+scope+"read+write+follow";
}

Future<void> getAndStoreAuthorizationToken(PleromaAuth auth, String authorizationToken) async
{
  String? domain = await PleromaAuthenticationStorage.getFediverseNode();
  if(domain == null)
  {
    throw Exception("Domain Name was null");
  }

  http.Response response = await http.post(
    Uri.parse("https://$domain$login"),
    body: (<String,String> {
      "grant_type": "authorization_code",
      "redirect_uri":redirectURI,
      "client_id": auth.clientID,
      "client_secret": auth.clientSecret,
      "code":authorizationToken,
      "scope":scopes

    })
  );

  if(response.statusCode == 200)
  {
    PleromaAuthenticationStorage.fromJson(jsonDecode(response.body));
  }
  else
  {
    throw Exception("Failed to get acess tokens $domain. ${response.body}");
  }
}

Future<List<PleromaPost>> getUsersMostRecentTimeline() async
{
  
  String? domain = await PleromaAuthenticationStorage.getFediverseNode();
  if(domain == null)
  {
    throw MissingDomainNameExcepetion("Domain name was null");
  }

  String? acccesToken = await PleromaAuthenticationStorage.getAccessToken();
  if(acccesToken == null)
  {
    throw InvalidAccessTokenException("There was no access token");
  }


  http.Response response = await http.get(
    Uri.parse("https://$domain$timeline"),
    headers:<String,String>
    {
      "Authorization": "Bearer $acccesToken"
    });

  if(response.statusCode == 200)
  {
    List<dynamic> json = jsonDecode(response.body);
    List<PleromaPost> posts = [];
    for(int i =0; i<json.length;i++)
    {
      posts.add(PleromaPost.fromJson(json[i]));
    }
    return posts;
  }
  else
  {
    throw MissingTimelineException("Unable to access timeline because ${response.body}");
  }
  
}

//maybe make isonlylocal an enum to handle special cases see https://docs.joinmastodon.org/methods/timelines/ for more information
Future<List<PleromaPost>> getFediversePublicTimeline(String domainName, bool isOnlyLocal, bool isOnlyMedia) async
{

  if(domainName == null || domainName.isEmpty)
  {
    throw MissingDomainNameExcepetion("Missing a domain name");
  }

  //since there are no bodys we do it like this manually
  http.Response response = await http.get(
    Uri.parse("https://$domainName$publicTimeline?local=$isOnlyLocal&only_media=$isOnlyMedia"),);

  switch(response.statusCode)
  {
    case 200:
      List<dynamic> json = jsonDecode(response.body);
      List<PleromaPost> posts = [];
      for(int i =0; i<json.length;i++)
      {
        posts.add(PleromaPost.fromJson(json[i]));
      }
      return posts;
    case 401: //Authorization error
      throw AuthorizationException("Not authorized. ${response.body}");
    default:
     throw Exception("Unable to access timeline. ${response.body}");
  }
  
}

Future<PleromaAccount> verifyUserAccount() async 
{
  String? domain = await PleromaAuthenticationStorage.getFediverseNode();
  if(domain == null)
  {
    throw Exception("Domain Name was null");
  }

  String? acccesToken = await PleromaAuthenticationStorage.getAccessToken();
  if(acccesToken == null)
  {
    Exception("There was no access token");
  }

  http.Response response = await http.get(
    Uri.parse("https://$domain$verifyUser"),
    headers:<String,String>
    {
      "Authorization": "Bearer $acccesToken"
    });

  if(response.statusCode == 200)
  {
      return PleromaAccount.fromJson(jsonDecode(response.body));
  }
  else
  {
    throw Exception("Failed to verify the users account. ${response.body}");
  }

}


class MissingDomainNameExcepetion implements Exception
{
 String cause;
 MissingDomainNameExcepetion(this.cause); 
}

class UnknowDomainNameExcepetion implements Exception
{
 String cause;
 UnknowDomainNameExcepetion(this.cause); 
}

class InvalidAccessTokenException implements Exception
{
  String cause;
  InvalidAccessTokenException(this.cause);  
}

class MissingTimelineException implements Exception
{
  String cause;
  MissingTimelineException(this.cause);  
}

class AuthorizationException implements Exception
{
  String cause;

  AuthorizationException(this.cause);
}
