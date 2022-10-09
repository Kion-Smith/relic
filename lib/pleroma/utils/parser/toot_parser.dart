library fediverse_parser;
import 'toot_tokens.dart';

// final Map<String, TootParsingState> spanStates = {
//   r'<span class=\"quote-inline\">': TootParsingState.quoteRetoot,
//   r'<span class=\"recipients-inline\">':TootParsingState.replyToot,
//   r'<span class=\"h-card\">':TootParsingState.spanStart,
//   '<span>': TootParsingState.spanStart,
//   '</span>': TootParsingState.spanEnd
// };

final Map<String, TootParsingState> spanStates = {
  r'<span class="quote-inline">': TootParsingState.quoteRetoot,
  r'<span class="recipients-inline">':TootParsingState.replyToot,
  r'<span class="h-card">':TootParsingState.spanStart,
  '<span>': TootParsingState.spanStart,
  '</span>': TootParsingState.spanEnd
};

List<TootToken> getTootTokens(String tootContents)
{
  
  List<TootToken> tokens = [];
  TootParsingState curState = TootParsingState.lookingForChars;
  StringBuffer currentData = StringBuffer();

  for (var charValue in tootContents.runes) 
  { 
    
    String char = String.fromCharCode(charValue);
    
    if(curState == TootParsingState.lookingForChars)
    {
      if(char == "<")
      {
        if(currentData.isNotEmpty)
        {
            TootToken currentToken = TootToken(TootTokenType.plainText, currentData.toString());
            tokens.add(currentToken);
            currentData.clear();
        }

        currentData.write("<");
        curState =TootParsingState.lookingForTagType;
        
      }
      else
      {
        currentData.write(char);
      }
      
    }
    else if(curState != TootParsingState.lookingForChars)
    {
      if(char == ">")
      {
        currentData.write(">");
        String bufferValue = currentData.toString();
        curState = spanStates[bufferValue] ?? TootParsingState.lookingForChars; 

        switch(curState)
        {
          case TootParsingState. quoteRetoot:
              TootToken currentToken = TootToken(TootTokenType.retoot, currentData.toString());
              currentData.clear();
              tokens.add(currentToken);
              break;
          case TootParsingState.replyToot:
              TootToken currentToken = TootToken(TootTokenType.replyToot, currentData.toString());
              currentData.clear();
              tokens.add(currentToken);
              break;
          case TootParsingState.spanStart:
              TootToken currentToken = TootToken(TootTokenType.span, currentData.toString());
              currentData.clear();
              curState = TootParsingState.lookingForChars;
              tokens.add(currentToken);
              break;
          case TootParsingState.spanEnd:
              TootToken currentToken = TootToken(TootTokenType.spanEnd, currentData.toString());
              tokens.add(currentToken);
              currentData.clear();
              break;
          case TootParsingState.lookingForChars:
            if(curState == TootParsingState.lookingForChars && bufferValue.substring(1,2)== "a")
            {
              TootToken currentToken = TootToken(TootTokenType.link, currentData.toString());
              currentData.clear();
              tokens.add(currentToken);
            }
            else if(curState == TootParsingState.lookingForChars && bufferValue.substring(1,3) == "/a")
            {
              TootToken currentToken = TootToken(TootTokenType.linkEnd, currentData.toString());
              currentData.clear();
              tokens.add(currentToken);
            }
            else if(curState == TootParsingState.lookingForChars && bufferValue.substring(1,2) == "b")
            {
              TootToken currentToken = TootToken(TootTokenType.lineBreak, currentData.toString());
              currentData.clear();
              tokens.add(currentToken);
            }

            else 
            {
              Exception("Unkown state");
            }
            break;
          default:
            Exception("Unkown state");
            break;
        }

      }
      else
      {
        String curString = currentData.toString();
        if(char == "<" && curString.length == 1 && curString.substring(0,1) == " ")
        {
          currentData.clear();
        }
        currentData.write(char);
      }
    }
  }

  if(currentData.isNotEmpty && curState == TootParsingState.lookingForChars)
  {
      TootToken currentToken = TootToken(TootTokenType.plainText, currentData.toString());
      tokens.add(currentToken);
  }
  
 return tokens; 
}