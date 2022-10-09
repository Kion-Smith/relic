import 'package:relic/pleroma/pleroma_account.dart';
import 'package:relic/pleroma/pleroma_data.dart';

class PleromaPost
{
  final PleromaAccount acount;
  final String? application;
  final bool bookmarked;
  final Map<String,dynamic>? card;
  final String content; // maybe make this a dom objec?
  final DateTime postedAt;
  final List<String> emojis;

  final bool favourited;
  final int favoritedCount;
  final String id;
  final String? replyAccountId;
  final String? replyPostId;
  final String? language; // maybe this should be an enum

  final List<Map<String,dynamic>> mediaAttachment;
  final List<PleromaAccount> mentionedAccounts;
  final bool isPinned;
  final Map<String,dynamic>? poll; //??
  final Map<String,dynamic> reblog;
  final bool reblogged;
  final int reblogCount;
  final int replyCount;
  final bool isSenstive;
  final String spolierText;
  final List<String> tags;
  final String text;
  final Uri uri;
  final Uri url;
  final String visibility; // this should be a enum but idk what the visbiligies are


  final PleromaData? pleromaData;

  PleromaPost(
    this.acount, 
    this.application, 
    this.bookmarked, 
    this.card, 
    this.content, 
    this.postedAt, 
    this.emojis, 
    this.favourited, 
    this.favoritedCount, 
    this.id, 
    this.replyAccountId, 
    this.replyPostId, 
    this.language, 
    this.mediaAttachment, 
    this.mentionedAccounts, 
    this.isPinned, 
    this.pleromaData,
    this.poll, 
    this.reblog, 
    this.reblogged, 
    this.reblogCount, 
    this.replyCount, 
    this.isSenstive, 
    this.spolierText, 
    this.tags, 
    this.text, 
    this.uri, 
    this.url, 
    this.visibility, 
    );

  factory PleromaPost.fromJson(Map<String,dynamic> json)
  {
    List<PleromaAccount> mentionedAccounts = [];
    for(int i =0;i<json['mentions'].length;i++)
    {
      mentionedAccounts.add(PleromaAccount.mentions(json['mentions'][i]));
    }


    List<String> emojiList= [];
    for(int i = 0;i<json['emojis'].length;i++)
    {
      emojiList.add(json['emojis'][i]);
    }

    List<Map<String,dynamic>> mediaAttachmentsList = [];
    for (int i =0;i<json['media_attachments'].length;i++)
    {
      mediaAttachmentsList.add(json['media_attachments'][i]);
      
    }

    List<String> tagsList = [];
    for(int i =0;i<json['tags'].length;i++)
    {
      tagsList.add(json['tags'][i]);
    }

    // List<String> reblogList = [];
    // for(int i =0;i<json['reblog'].length;i++)
    // {
    //   reblogList.add(json['reblog'][i]);
    // }

    PleromaData? pleromaData = null;
    try
    {
      pleromaData = PleromaData.fromJson(json['pleroma']);
    }
    catch(e)
    {
      print("Could not use pleroma data"+e.toString());
    }
     
    return PleromaPost(
      PleromaAccount.fromJson(json['account']),
      json['application'],
      json['bookmarked'],
      json['card'] ,
      json['content'],
      DateTime.parse(json['created_at']),
      emojiList,
      json['favourited'],
      json['favourites_count'],
      json['id'],
      json['in_reply_to_account_id'],
      json['in_reply_to_id'],
      json['language'],
      mediaAttachmentsList,
      mentionedAccounts, // come back to this
      json['muted'],
      pleromaData, // come back to this
      json['poll'],
      json['reblog'] ?? {},
      json['reblogged'],
      json['reblogs_count'],
      json['replies_count'],
      json['sensitive'],
      json['spoiler_text'],
      tagsList,
      json['text'] ?? "",
      Uri.parse(json['uri']),
      Uri.parse(json['url']),
      json['visibility'],
    );
  }

}