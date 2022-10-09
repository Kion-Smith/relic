
import 'package:flutter/material.dart';
import 'package:relic/pleroma/pleroma_account.dart';
import 'package:relic/pleroma/pleroma_post.dart';
import 'package:relic/pleroma/utils/pleroma_restcalls.dart';
import 'package:relic/widgets/toot_card.dart';

class Timeline extends StatefulWidget
{
  final  PleromaAccount user;
  final List<PleromaPost> posts;

  //Constructor
  Timeline({Key? key, required this.user, required this.posts}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TimelineState();
}

class _TimelineState extends State<Timeline>
{
  static const String _testImage = "https://i.poastcdn.org/20df1b300b784dd0a5e1dbd2033dfea887bbd29d46a501203a52151df7b1a634.png";
  late ScrollController timelineController;
  late Set<String> knownPosts;
  List<PleromaPost> postsToRender = [];
  PleromaAccount? userAccount;

  @override
  void initState() 
  {
    userAccount = widget.user;
    postsToRender = widget.posts;
    knownPosts = <String>{};

    //Add the id for all the posts
    for(int i =0;i<postsToRender.length;i++)
    {
      if(knownPosts.contains(postsToRender[i].id))
      {
        knownPosts.add(postsToRender[i].id);
      }
    }
    
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
    return WillPopScope( 
      onWillPop: () async => false,
      child:Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: false,
          title: _buildAppBarItems(),
        ),
        body: _buildTimelineListView(),
        floatingActionButton: _buildPostButton(),
        bottomNavigationBar: DefaultTabController( 
          length: 4,
          child: _buildBottomTabs()
        ),
      )
    );
  }

  Widget _buildTimelineListView()
  {
    return RefreshIndicator( 
        onRefresh: _getNewPosts,
        child: ListView.separated(
          separatorBuilder: (BuildContext context, int index) 
          {  
            return const Divider();
          },
          itemCount: postsToRender.length,
          controller: timelineController,
          itemBuilder: (context,index)
          {
            //return _buildPostCard(postsToRender[index]); 
            return TootCard(postInfo: postsToRender[index]);
          }
        )
    );
  }

  //Really can't think of a better name
  // Widget _buildPostCard(PleromaPost post)
  // {
  //   Duration timeSincePost = DateTime.now().difference(post.postedAt);
  //   return ListTile(
  //       leading:  CircleAvatar(
  //         backgroundImage: NetworkImage(post.acount.staticAvatar ?? ''),
  //         backgroundColor: const Color.fromARGB(70, 0, 0, 0),
  //         ),
  //       title: Wrap(
  //         runSpacing: 10,
  //         direction: Axis.horizontal,
  //         children: <Widget>
  //         [
  //           Text("${post.acount.displayName} @${post.acount.accountName} \t${formatTimeDifferance(timeSincePost)}"),
  //           Text(post.pleromaData.content['text/plain'] ?? ""),
  //           const SizedBox(height: 15,child:Placeholder(color: Color.fromARGB(0, 0, 0, 0),)),
  //           Wrap(
  //             //mainAxisAlignment: MainAxisAlignment.spaceAround,
  //             spacing: 30,
  //             children: <Widget>
  //             [
  //               _buildIconLabelButton("${post.replyCount}",Icons.chat_bubble_outlined),
  //               _buildIconLabelButton("${post.reblogCount}",Icons.repeat_rounded),
  //               _buildIconLabelButton("${post.favoritedCount}",Icons.thumb_up_alt_rounded),
  //             ],
  //           ),
  //           const Padding(padding: EdgeInsets.only(bottom: 40))
  //         ],
  //       )
  //   );
  // }

  // Widget _buildIconLabelButton(String count, IconData icon)
  // {
  //   return InkWell(
  //     child: Wrap(
  //     spacing: 5,
  //     children: <Widget>
  //     [
  //       Icon(icon,size: 20),
  //       Text(count)
  //     ],
  //   ),
  //     onTap: () 
  //     {

  //     },
  //   );
  // }

  Widget _buildAppBarItems()
  {
    return Wrap(
      spacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children:  <Widget>
      [
        CircleAvatar(
          backgroundImage: NetworkImage(userAccount?.staticAvatar?? _testImage),
          backgroundColor: const Color.fromARGB(70, 0, 0, 0),
        ),
        const Text("Timeline")
      ]
    );
  }

  Widget _buildBottomTabs()
  {
    return TabBar(
          labelColor: Theme.of(context).toggleableActiveColor,
          unselectedLabelColor: Theme.of(context).unselectedWidgetColor,
          indicator: const BoxDecoration(
            color: Color.fromARGB(0, 0, 0, 0)
          ),
          tabs: const <Widget> 
          [
            Tab(icon: Icon(Icons.dashboard,size: 30,)),
            Tab(icon: Icon(Icons.construction,size: 30,)),
            Tab(icon: Icon(Icons.construction,size: 30,)),
            Tab(icon: Icon(Icons.construction,size: 30,)),
          ]
      );
  }

  Widget _buildPostButton()
  {
    return FloatingActionButton(
      child:const Icon(Icons.create_rounded),
      onPressed: () async
      {

      }
    );
  }

  //Update with only the newests non known posts
  Future<void> _getNewPosts() async
  {
    List<PleromaPost>? updatedPosts = await getUsersMostRecentTimeline() ?? [];
    List<PleromaPost> newPosts = [];
    setState(()  
    {
      for(int i =0;i<updatedPosts.length;i++)
      {
        if(!knownPosts.contains(updatedPosts[i].id))
        {
          knownPosts.add(updatedPosts[i].id);
          newPosts.add(updatedPosts[i]);
        }
      }
      postsToRender = newPosts+postsToRender;
    });
    return Future.delayed(Duration.zero);
  }

  

}