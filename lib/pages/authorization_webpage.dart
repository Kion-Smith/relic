import 'package:flutter/material.dart';
import 'package:relic/pleroma/pleroma_account.dart';
import 'package:relic/pleroma/pleroma_auth_data.dart';
import 'package:relic/pleroma/pleroma_auth_storage.dart';
import 'package:relic/pleroma/pleroma_post.dart';
import 'package:relic/pleroma/utils/pleroma_restcalls.dart';
import 'package:relic/pages/timeline.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'login_page.dart';

class AuthorizationWebPage extends StatefulWidget {
  final String loginURL;
  final PleromaAuth authorization;

  const AuthorizationWebPage( {Key? key, required this.loginURL, required this.authorization}) : super(key: key);

  @override
  State<AuthorizationWebPage> createState() => _AuthorizationWebPageState();
}

class _AuthorizationWebPageState extends State<AuthorizationWebPage>
{
  late WebViewController controller;
  
  @override
  void initState() 
  {
    super.initState();
  }

  @override
  Widget build(BuildContext context)  => Scaffold(
    appBar: AppBar(
      title: const Text("Please allow Relic authorization"
      )
    ),
    body: WebView(
      javascriptMode: JavascriptMode.unrestricted,
      initialUrl: widget.loginURL,
      onWebViewCreated: ((controller) {
        this.controller = controller;
      }),
      onPageStarted: (url) async 
      {
        String? domain = await PleromaAuthenticationStorage.getFediverseNode();
        
        if(domain != null && url == "https://$domain/oauth/authorize")
        {

          String token = await controller.runJavascriptReturningResult('window.document.querySelectorAll("h2")[0].childNodes.item(2).data');
          if(token.isEmpty)
          {
            PleromaAuthenticationStorage.clearStorage();
            Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
          }

          //PleromaAuthenticationStorage.setFediverseNode(domain);
           //do login here
          await getAndStoreAuthorizationToken(widget.authorization,token.replaceAll('"', ""));

          //Push to time line on succes
          try
          {
            PleromaAccount user = await verifyUserAccount();
            List<PleromaPost> posts = await getUsersMostRecentTimeline() ?? [];
            Navigator.push(
              context, 
              MaterialPageRoute(
                builder: (context) => Timeline(posts: posts, user: user)
              )
            );
          }
          catch(exception)
          {
            PleromaAuthenticationStorage.clearStorage();
            Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
          }          
          
        }
        // else
        // {
        //   print("Could not sign into authrization page");
        //   PleromaAuthenticationStorage.clearStorage();
        //   Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
        // }
      },
      ),
  );

}