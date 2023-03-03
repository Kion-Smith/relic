import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:relic/pleroma/pleroma_account.dart';
import 'package:relic/pleroma/pleroma_post.dart';
import 'package:relic/pleroma/utils/post_format_utils.dart';
import 'package:relic/widgets/network_image_preview.dart';

import 'package:html/parser.dart' as html;

class TootCard extends StatefulWidget {
  final PleromaPost postInfo;

  const TootCard({Key? key, required this.postInfo}) : super(key: key);

  @override
  State<TootCard> createState() => _TootCardState();
}

enum TootCardType {
  normal,
  reply,
  quoteRetoot,
}

class _TootCardState extends State<TootCard> {
  //make into an enum
  bool isReblogged = false;
  TootCardType tootState = TootCardType.normal;

  late String postMessage;
  late dom.NodeList? htmlElements;
  late PleromaAccount reblogAccount;
  late Map<String, dynamic> quoteRetootAccount;

  @override
  void initState() {
    if (widget.postInfo.getReblogContent.isNotEmpty) {
      isReblogged = true;
      reblogAccount =
          PleromaAccount.fromJson(widget.postInfo.getReblogContent["account"]);
    }

    if (widget.postInfo.getMentionedAccounts.isNotEmpty && !isReblogged) {
      tootState = TootCardType.reply;
    } else if (widget.postInfo.getCardInformation != null &&
        widget.postInfo.getCardInformation!.isNotEmpty) {
      tootState = TootCardType.quoteRetoot;
      quoteRetootAccount = widget.postInfo.getCardInformation!;
    }

    //Replace paragraphs for mastodon instances that use <p>, I should handle parsing diffriently but idk how to tell programatically if
    // a website is pleroma or mastodon
    String content = widget.postInfo.getContent
        .replaceAll("</p><p>", "<br/><br/>")
        .replaceAll("<p>", "")
        .replaceAll("</p>", "");
    htmlElements = html.parse(content).documentElement?.nodes.last.nodes;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(isReblogged
              ? (reblogAccount.staticAvatar ?? "")
              : (widget.postInfo.getAccount.staticAvatar ?? '')),
          backgroundColor: const Color.fromARGB(70, 0, 0, 0),
        ),
        title: buildRetootWidget(),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
                "${isReblogged ? reblogAccount.displayName : widget.postInfo.getAccount.displayName}"
                " @${isReblogged ? reblogAccount.accountName : widget.postInfo.getAccount.accountName} \t"
                "${formatTimeDifferance(DateTime.now().difference(widget.postInfo.getTimePosted))}"),
            ..._buildReplyChain(),
            _buildTextContent(),
            const SizedBox(
                height: 15,
                child: Placeholder(
                  color: Color.fromARGB(0, 0, 0, 0),
                )),
            ..._parseMediaAttachments(),

            _buildRetootCard(),
            // GridView.count(
            //     crossAxisCount: 2,
            //     children: parseMediaAttachments()
            // ),
            const Padding(padding: EdgeInsets.only(bottom: 15)),
            Wrap(
              spacing: 30,
              children: <Widget>[
                _buildIconLabelButton("${widget.postInfo.getReplyCount}",
                    Icons.chat_bubble_outlined),
                _buildIconLabelButton(
                    "${widget.postInfo.getReblogCount}", Icons.repeat_rounded),
                _buildIconLabelButton("${widget.postInfo.getFavouritedCount}",
                    Icons.thumb_up_alt_rounded),
              ],
            ),
            const Padding(padding: EdgeInsets.only(bottom: 10))
          ],
        ));
  }

/* --- BUILD WIDGETS --- */
  Widget _buildRetootCard() {
    if (tootState != TootCardType.quoteRetoot) {
      return Container();
    }

    return ListTile(
        leading: CircleAvatar(
          backgroundImage: quoteRetootAccount["image"] != null
              ? NetworkImage(quoteRetootAccount["image"])
              : NetworkImage(
                  "https://i.poastcdn.org/20df1b300b784dd0a5e1dbd2033dfea887bbd29d46a501203a52151df7b1a634.png"),
          backgroundColor: const Color.fromARGB(70, 0, 0, 0),
        ),
        title: Text(quoteRetootAccount["title"]),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(quoteRetootAccount["description"]),
            const Padding(padding: EdgeInsets.only(bottom: 10)),
            const SizedBox(
                height: 15,
                child: Placeholder(
                  color: Color.fromARGB(0, 0, 0, 0),
                )),
          ],
        ));
  }

  Widget? buildRetootWidget() {
    if (isReblogged) {
      return Wrap(
        children: [
          Text("${widget.postInfo.getAccount.displayName ?? ""} Retooted "),
          const Icon(Icons.repeat)
        ],
      );
    }

    return null;
  }

  Widget _buildIconLabelButton(String count, IconData icon) {
    //Maybe change this to row too?
    return InkWell(
      child: Wrap(
        spacing: 5,
        children: <Widget>[Icon(icon, size: 20), Text(count)],
      ),
      onTap: () {},
    );
  }

  List<Widget> _buildReplyChain() {
    List<Widget> replies = [];
    List<String> mentionedAccounts = [];

    if (tootState == TootCardType.reply) {
      int count = 0;
      for (PleromaAccount curAccount in widget.postInfo.getMentionedAccounts) {
        mentionedAccounts.add("@${curAccount.accountName}" ?? "");
      }

      print(mentionedAccounts);

      replies.add(RichText(
        text: TextSpan(text: "Replying to ", children: <TextSpan>[
          TextSpan(
            text: mentionedAccounts.length < 3
                ? mentionedAccounts.join(",").replaceAll(",", " and ")
                : mentionedAccounts[0] +
                    " and " +
                    mentionedAccounts[1] +
                    " and others",
            style: TextStyle(color: Theme.of(context).toggleableActiveColor),
          )
        ]),
      ));
    }
    return replies;
  }

  Widget _buildTextContent() {
    if (htmlElements == null) {
      return const Text("");
    }

    return RichText(text: TextSpan(children: getTooTextSpanList()));
  }

  List<Widget> _parseMediaAttachments() {
    List<Widget> mediaWidgets = [];

    for (Map<String, dynamic> curMedia in widget.postInfo.getMediaAttachments) {
      if (curMedia["type"] != null) {
        switch (curMedia["type"]) {
          case "gifv":
          case "image":
            if (curMedia["url"] != null && curMedia["preview_url"] != null) {
              mediaWidgets.add(SizedBox(
                  width: curMedia["width"],
                  height: curMedia["height"],
                  child: NetworkImagePreview(
                    actualImage: curMedia["url"],
                    previewImage: curMedia["preview_url"],
                  )));
            } else {
              mediaWidgets.add(const Text("Unable to load image"));
            }
            break;
          case "video":
            break;
          case "audio":
            break;
          default:
            mediaWidgets.add(const Text("Unknown media type"));
        }
      }
    }

    return mediaWidgets;
  }

  /* --- HELPER FUNCTIONS */
  List<TextSpan> getTooTextSpanList() {
    StringBuffer contentTextBuilder = StringBuffer();
    List<TextSpan> tootTextSpanWidgets = [];
    Iterator<dom.Node> elements = htmlElements!.iterator;

    while (elements.moveNext()) {
      if (elements.current is dom.Text) {
        contentTextBuilder.write(elements.current.text);
      } else if (elements.current is dom.Element) {
        dom.Element e = elements.current as dom.Element;
        if (e.className == "h-card") {
          //Replying to someone
          //contentTextBuilder.write(e.text);
          if (contentTextBuilder.isNotEmpty) {
            tootTextSpanWidgets
                .add(TextSpan(text: contentTextBuilder.toString()));
            contentTextBuilder.clear();
          }
          //TODO add some way to go to a new page
          tootTextSpanWidgets.add(TextSpan(
            text: e.text,
            style: TextStyle(color: Theme.of(context).toggleableActiveColor),
          ));
        } else if (e.localName == "br") {
          //Line break
          contentTextBuilder.write("\n");
        } else if (e.localName == "a") {
          //Link
          //add conditinonals for links and tags
          if (contentTextBuilder.isNotEmpty) {
            tootTextSpanWidgets
                .add(TextSpan(text: contentTextBuilder.toString()));
            contentTextBuilder.clear();
          }
          //TODO add some way to go to a new page
          tootTextSpanWidgets.add(TextSpan(
            text: e.text,
            style: TextStyle(color: Theme.of(context).toggleableActiveColor),
          ));
        }
      }
      //mentions -> mention directly in message I want to parse this information and create a builder to go to that users profile
      //recipents-inline -> means replying to I can ignore this and get this information from somewhere else
      //print(elements.current.toString());
    }

    if (contentTextBuilder.isNotEmpty) {
      tootTextSpanWidgets.add(TextSpan(text: contentTextBuilder.toString()));
      contentTextBuilder.clear();
    }
    return tootTextSpanWidgets;
  }
}
