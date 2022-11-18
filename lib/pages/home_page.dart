import 'package:flutter/material.dart';
import 'package:relic/pages/search_page.dart';
import 'package:relic/widgets/timeline.dart';
import 'package:relic/pleroma/pleroma_account.dart';
import 'package:relic/pleroma/pleroma_post.dart';

class HomePage extends StatefulWidget
{
  final  PleromaAccount user;
  final List<PleromaPost> posts;

  //Constructor
  const HomePage({Key? key, required this.user, required this.posts}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
{
  static const String _testImage = "https://i.poastcdn.org/20df1b300b784dd0a5e1dbd2033dfea887bbd29d46a501203a52151df7b1a634.png";
  late ScrollController timelineController;
  late Set<String> knownPosts;
  late String tabTitle = "Timeline";
  List<PleromaPost> postsToRender = [];
  PleromaAccount? userAccount;
  TextEditingController searchFediverseController = TextEditingController();
  String domainName = "";

  int currentTab = 0;

  @override
  void initState() 
  {
    userAccount = widget.user;
    postsToRender = widget.posts;
    knownPosts = <String>{};

    //Add the id for all the posts
    for(int i =0;i<postsToRender.length;i++)
    {
      if(knownPosts.contains(postsToRender[i].getId))
      {
        knownPosts.add(postsToRender[i].getId);
      }
    }
    
    timelineController = ScrollController();
    super.initState();
  }


  @override
  void dispose()
  {
    timelineController.dispose();
    searchFediverseController.dispose();
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
          actions: currentTab == 1 ? [IconButton(icon: const Icon(Icons.search), onPressed: () { _showMyDialog(); },)] : [],
        ),
        body: _buildCurrentView(),
        floatingActionButton: currentTab == 0 ? _buildPostButton() : null,
        bottomNavigationBar: DefaultTabController( 
          length: 4,
          child: _buildBottomTabs()
        ),
      )
    );
  }

  Widget _buildCurrentView()
  {
    switch(currentTab)
    {
      case 0:
        return const Timeline();//Timeline(posts: widget.posts);
      case 1:
        return SearchFediverseNode(domainName: domainName);//Text("Search some location");
      default:
        return const Text("Not implemented yet");
    }
  }


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
        Text(tabTitle)
      ]
    );
  }

  Widget _buildBottomTabs()
  {
    return TabBar(
        onTap: (value) 
        {
          setState(() 
          {
            currentTab = value;
              switch(currentTab)
              {
                case 0:
                  tabTitle = "Timeline";
                  break;
                case 1:
                  tabTitle = "Search Fediverse $domainName";
                  break;
                default:
                  tabTitle = "Unknown";
                  break;
              }
          });
        },
        labelColor: Theme.of(context).toggleableActiveColor,
        unselectedLabelColor: Theme.of(context).unselectedWidgetColor,
        indicator: const BoxDecoration(
          color: Color.fromARGB(0, 0, 0, 0)
        ),
        tabs: const <Widget> 
        [
          Tab(icon: Icon(Icons.dashboard,size: 30,)),
          Tab(icon: Icon(Icons.search,size: 30,)),
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

  Future<void> _showMyDialog() async 
  {
    double itemWidth = MediaQuery.of(context).size.width*.2;
    double itemHeight = MediaQuery.of(context).size.height*.05;
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) 
      {
        return AlertDialog(
          title: const Text('Enter A Node'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: searchFediverseController,     
                  decoration: InputDecoration(
                    labelText: "Fediverse Domain Name",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(35))
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>
          [
            _buildSearchButton(itemWidth, itemHeight),
            _buildCancelButton(itemWidth,itemHeight)

          ],
        );
      },
    );
  }

  Widget _buildSearchButton(double width,double height)
  {
    return SizedBox(
      width: width,
      height: height,
      child:ElevatedButton(
        child: const Text("Search"),
        style: ButtonStyle(
          shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(35))),
          backgroundColor: MaterialStateProperty.all(Theme.of(context).toggleableActiveColor)
          
        ),
        onPressed: ()
        {
          setState(() 
          {
            domainName = searchFediverseController.text;
            print(domainName);
          });
          Navigator.of(context).pop();
        }, 
      )
    );
  }

  Widget _buildCancelButton(double width,double height)
  {
    return SizedBox(
      width: width,
      height: height,
      child:ElevatedButton(
      child: const Text("Cancel"),
      style: ButtonStyle(
        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(35))),
        backgroundColor: MaterialStateProperty.all(Theme.of(context).errorColor)
         
      ),
      onPressed: ()
      {
        Navigator.of(context).pop();
      }, 
      )
    );
  }

  // SnackBar _buildErrorSnackBar(String errorMsg)
  // {
  //   return SnackBar(
  //     content: Text(errorMsg),
  //     backgroundColor: Colors.red,
  //     );
  // }
}