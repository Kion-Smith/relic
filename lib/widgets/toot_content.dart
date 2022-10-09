import 'package:flutter/widgets.dart';
import 'package:relic/pleroma/pleroma_post.dart';
import 'package:relic/pleroma/utils/parser/toot_parser.dart';

import '../pleroma/utils/parser/toot_tokens.dart';

class TootContent extends StatefulWidget
{
  final PleromaPost postInfo;

  const TootContent({Key? key, required this.postInfo}) : super(key: key);

  @override
  State<TootContent> createState() => _TootContent();
}

class _TootContent extends State<TootContent> 
{
  late List<TootToken> tokens;
   
  @override
  void initState() 
  {
    tokens = getTootTokens(widget.postInfo.content);
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) 
  {
    return Wrap(
      children: <Widget> 
      [

      ],
    );
  }

  // List<Widget> buildTootContentFromTokens()
  // {
  //   //bool shouldIgnore
  //   //for
  // }
}
