import 'package:flutter/material.dart';
import 'package:relic/pages/login_page.dart';
import 'package:relic/pleroma/pleroma_account.dart';
import 'package:relic/pleroma/pleroma_auth_storage.dart';
import 'package:relic/pleroma/pleroma_post.dart';
import 'package:relic/pleroma/utils/pleroma_restcalls.dart';
import 'home_page.dart';

class LoadingScreen extends StatefulWidget 
{
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<LoadingScreen> 
{

  @override
  void initState()
  {
    checkAcessTokens();
    super.initState();
  }

  void checkAcessTokens() async
  {
    String? accessToken =await PleromaAuthenticationStorage.getAccessToken();
    String? fediverseNode = await PleromaAuthenticationStorage.getFediverseNode();
    
    //Case 1: We have both a node and access token
    if(accessToken != null && fediverseNode != null)
    {
      PleromaAccount user = await verifyUserAccount();
      List<PleromaPost> posts = await getUsersMostRecentTimeline() ?? [];

      Navigator.push(
        context, 
        MaterialPageRoute(
          builder: (context) => HomePage(posts: posts, user: user)//Timeline(posts: posts, user: user)
          )
      );
    }
    //Case : We are missing some key data so treat as new user
    else
    {
      //If we have some old data that we need to get rid off
      if (accessToken != null || fediverseNode != null)
      {
          print("Missing either access token or fediverse url, reseting");
          PleromaAuthenticationStorage.clearStorage();
      }

      print("Sending user to login page");

      Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));

    }

  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Loading Relic'),
      ),
    );
  }
}
