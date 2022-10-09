// ignore: avoid_web_libraries_in_flutter

import 'package:flutter/material.dart';
import 'package:relic/pleroma/pleroma_post.dart';
import 'package:relic/pleroma/utils/parser/toot_parser.dart';
import 'package:relic/pleroma/utils/parser/toot_tokens.dart';
import 'package:relic/pleroma/utils/post_format_utils.dart';

class TootCard extends StatefulWidget
{
  final PleromaPost postInfo;

  const TootCard({Key? key, required this.postInfo}) : super(key: key);

  @override
  State<TootCard> createState() => _TootCardState();
}

class _TootCardState extends State<TootCard> 
{
@override
  void initState() {

    List<TootToken> tokens = getTootTokens(widget.postInfo.content);
    for( TootToken curToken in tokens)
    {
       print("${curToken.getType()} : ${curToken.getData()} ,");
    }

    print("-------------------------");
   // var fragment = parse(widget.postInfo.content);//DocumentFragment.html(widget.postInfo.content);
    //print(fragment);
    super.initState();
  }

  @override
  Widget build(BuildContext context) 
  {
    // return SizedBox(
    //   //width: MediaQuery.of(context).size.width,
    //   //height: MediaQuery.of(context).size.height,
    //   child: Padding(
    //   padding: const EdgeInsets.symmetric(vertical: 5.0),
    //   child: _buildTootCard()
    //   ),
    // );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: _buildTootHeader(),
          ),
          Expanded(
            flex: 5,
            child: _buildTootBody()
          ),
        ],
      ),
    );
  }

  Widget _buildTootHeader()
  {
    return CircleAvatar(//radius: (52),
            backgroundColor: Colors.black,
            child: ClipRRect(
              borderRadius:BorderRadius.circular(50),
              child: Image.network(widget.postInfo.acount.staticAvatar ?? ""),
            )
        );
  }

  Widget _buildTootBody()
  {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "${widget.postInfo.acount.displayName}\t" 
            "@${widget.postInfo.acount.accountName}\t\t"
            "${formatTimeDifferance(DateTime.now().difference(widget.postInfo.postedAt))}",
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14.0,
            ),
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 10.0)),
          Text(
            widget.postInfo.content,
            //style: const TextStyle(fontSize: 10.0),
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 15.0)),
          _buildTootFooter(),
          const Padding(padding: EdgeInsets.symmetric(vertical: 1.0)),
        ],
      ),
    );
  }


  Widget _buildTootFooter()
  {
    return Row(
      children: <Widget>
      [
        _buildIconLabelButton("${widget.postInfo.replyCount}",Icons.chat_bubble_outlined),
        _buildIconLabelButton("${widget.postInfo.reblogCount}",Icons.repeat_rounded),
        _buildIconLabelButton("${widget.postInfo.favoritedCount}",Icons.thumb_up_alt_rounded),
     ],
    );
  }

  Widget _buildIconLabelButton(String count, IconData icon)
  {
    //Maybe change this to row too?
    return InkWell(
      child: Wrap(
      spacing: 5,
      children: <Widget>
      [
        Icon(icon,size: 20),
        Text(count)
      ],
    ),
      onTap: () 
      {

      },
    );
  }
  
}
