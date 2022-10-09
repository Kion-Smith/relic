String formatTimeDifferance(Duration dif)
{
  if(dif.inSeconds < 60)
  {
    return "${dif.inMilliseconds}s";
  }
  else if(dif.inMinutes <  60)
  {
     return "${dif.inMinutes}m";
  }
  else if(dif.inHours <  24)
  {
    return "${dif.inHours}h";
  }
  else
  {
    return "${dif.inDays}d";
  }
  //Add months and years
}