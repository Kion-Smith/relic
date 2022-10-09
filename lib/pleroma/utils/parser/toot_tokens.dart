class TootToken
{
  final TootTokenType _type;
  final String _data;

  TootToken(this._type, this._data);

  TootTokenType getType() => _type;
  String getData() => _data;

}

enum TootTokenType
{
  plainText, //Just plain text
  lineBreak, //Format text with a break
  link, //Format text with a link
  linkEnd,
  retoot, // what is the post Get this information from the post information
  replyToot, // who is in this reply chain. Get this from the post infomration
  span,
  spanEnd,
}

enum TootParsingState
{

  lookingForChars,
  lookingForTagType,
  quoteRetoot,
  replyToot,
  spanStart,
  spanEnd
}