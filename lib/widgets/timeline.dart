
import 'package:flutter/material.dart';
import 'package:relic/pleroma/pleroma_post.dart';
import 'package:relic/pleroma/utils/pleroma_restcalls.dart';
import 'package:relic/widgets/toot_card.dart';

class Timeline extends StatefulWidget
{
  //Constructor
  const Timeline({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TimelineState();
}

class _TimelineState extends State<Timeline>
{
  late ScrollController timelineController;
  late Set<String> knownPosts;
  late List<PleromaPost> postsToRender;

  @override
  void initState() 
  {
    knownPosts = {};
    postsToRender = [];
    timelineController = ScrollController();
    super.initState();
  }


  @override
  void dispose()
  {
    timelineController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) 
  {
    return FutureBuilder(
      future: getUsersMostRecentTimeline(),
      builder: (context, snapshot) 
      {
        if(postsToRender.isNotEmpty && snapshot.connectionState != ConnectionState.done)
        {
          return Stack(children: 
          [ 
            const Center(child: CircularProgressIndicator()),
            ListView.separated(
                separatorBuilder: (BuildContext context, int index) 
                {  
                  return const Divider();
                },
                itemCount: postsToRender.length,
                controller: timelineController,
                itemBuilder: (context,index)
                {
                  return TootCard(postInfo: postsToRender[index]);
                }
              )
          ]);
        }

        if(snapshot.connectionState == ConnectionState.done && snapshot.hasData && snapshot.data is List<PleromaPost>)
        {
          postsToRender = snapshot.data as List<PleromaPost>;
          //Add the id for all the posts
          for(int i =0;i<postsToRender.length;i++)
          {
            if(knownPosts.contains(postsToRender[i].getId))
            {
              knownPosts.add(postsToRender[i].getId);
            }
          }
    
          return RefreshIndicator( 
            onRefresh: () {return Future(() { setState(() {}); });},//_getNewPosts,
            child: ListView.separated(
              separatorBuilder: (BuildContext context, int index) 
              {  
                return const Divider();
              },
              itemCount: postsToRender.length,
              controller: timelineController,
              itemBuilder: (context,index)
              {
                return TootCard(postInfo: postsToRender[index]);
              }
            )
        );


        }
        else if(snapshot.connectionState == ConnectionState.done)
        {
          return const Text("Unable to load your timeline");
        }
        else
        {
          return const Center(child: CircularProgressIndicator());
        }
        
      },
    );
  }

  //Update with only the newest non-known posts
  // Future<void> _getNewPosts() async
  // {
  //   List<PleromaPost>? updatedPosts = await getUsersMostRecentTimeline() ?? [];
  //   List<PleromaPost> newPosts = [];
  //   setState(()  
  //   {
  //     for(int i =0;i<updatedPosts.length;i++)
  //     {
  //       if(!knownPosts.contains(updatedPosts[i].getId))
  //       {
  //         knownPosts.add(updatedPosts[i].getId);
  //         newPosts.add(updatedPosts[i]);
  //       }
  //     }
  //     postsToRender = newPosts+postsToRender;
  //   });
  //   return Future.delayed(Duration.zero);
  // }

  

}