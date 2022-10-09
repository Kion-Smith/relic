import 'package:flutter/material.dart';
import 'package:relic/pages/authorization_webpage.dart';
import 'package:relic/pleroma/pleroma_auth_data.dart';
import 'package:relic/pleroma/pleroma_auth_storage.dart';
import 'package:relic/pleroma/utils/pleroma_restcalls.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}


class _LoginPageState extends State<LoginPage>
{
  final formKey = GlobalKey<FormState>();
  late String username;
  late String password;
  late String fediverseNode;

  @override
  void initState() 
  {
    super.initState();
  }

  @override
  Widget build(BuildContext context)
  {
    double itemWidth = MediaQuery.of(context).size.width*.9;
    double itemHeight = MediaQuery.of(context).size.height*.07;
    return  Scaffold(
      body: Center(
        child: SizedBox(
          width: itemWidth,
          child:Form(
            key: formKey,
            child: Wrap(
              alignment: WrapAlignment.center,
              runSpacing: 30,
              children: <Widget>
              [
                  const Text("Relic",style: TextStyle(fontSize: 42),),
                  Container(),
                  _buildFediverseNameField(),
                  Container(),
                  Container(),
                  _buildLoginButton(itemWidth,itemHeight),
                  _buildClearButton(itemWidth,itemHeight)
              ],
            )
          )
        )
      )
    );
  }

  Widget _buildFediverseNameField()
  {
    return TextFormField(
      
      decoration: InputDecoration(
        labelText: "Fediverse Domain Name",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(35))
      ),
      onSaved:(input) 
      {
        setState(() 
        {
          fediverseNode = input!;
        });
      },
      validator: ((value) 
      {
        if(value == null || value.isEmpty)
        {
          return "You need to enter a fediverse node";
        }
        return null;
      } ),
    );
  }

  Widget _buildLoginButton(double width,double height)
  {
    return SizedBox(
      width: width,
      height: height,
      child:ElevatedButton(
      child: const Text("Login"),
      style: ButtonStyle(
        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(35))),
        backgroundColor: MaterialStateProperty.all(Theme.of(context).toggleableActiveColor)
         
      ),
      onPressed: () async
      {
        final bool isValid = formKey.currentState?.validate() ?? false;
        if(isValid)
        {
          formKey.currentState?.save();
          FocusScope.of(context).unfocus();
          PleromaAuthenticationStorage.setFediverseNode(fediverseNode);

          try
          {
            PleromaAuth auth = await registerRelicApp();
            String loginUrl = await getAuthorizationURL(auth);

            print(loginUrl);
            
            //Navigator.of(context).pushNamed("/web_authentication",arguments: {loginUrl,auth});
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => AuthorizationWebPage(loginURL: loginUrl, authorization: auth)));
            
          }
          catch(e)
          {
            ScaffoldMessenger.of(context).showSnackBar(_buildErrorSnackBar(e.toString()));
          }
        }
        //ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }, 
      )
    );
  }

    Widget _buildClearButton(double width,double height)
  {
    return SizedBox(
      width: width,
      height: height,
      child:ElevatedButton(
      child: const Text("Clear Credentials"),
      style: ButtonStyle(
        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(35))),
        backgroundColor: MaterialStateProperty.all(Theme.of(context).toggleableActiveColor)
         
      ),
      onPressed: ()
      {
        PleromaAuthenticationStorage.clearStorage();
      }, 
      )
    );
  }

  SnackBar _buildErrorSnackBar(String errorMsg)
  {
    return SnackBar(
      content: Text(errorMsg),
      backgroundColor: Colors.red,
      );
  }


}