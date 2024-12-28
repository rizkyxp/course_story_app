import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:story_app/provider/story_provider.dart';
import 'package:story_app/util/colors.dart';

class StoryScreen extends StatefulWidget {
  const StoryScreen({super.key});

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    final apiProvider = context.read<ListStoryProvider>();

    scrollController.addListener(() async {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent) {
        if (apiProvider.pageItems != null) {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('token');
          if (mounted && token != null) {
            await apiProvider.getListStory(token);
          }
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (mounted && token != null) {
          await apiProvider.getListStory(token);
        }
      },
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Story',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor,
        actions: [
          IconButton(
              onPressed: () async {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Are you sure, do you want to logout?'),
                        actions: [
                          TextButton(
                              onPressed: () {
                                context.pop();
                              },
                              child: const Text('No')),
                          TextButton(
                              onPressed: () async {
                                final SharedPreferences prefs = await SharedPreferences.getInstance();
                                await prefs.remove('token');
                                context.goNamed('welcome');
                              },
                              child: const Text('Yes'))
                        ]);
                  },
                );
              },
              icon: const Icon(
                Icons.logout,
                color: Colors.white,
              ))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.goNamed('newStory'),
        backgroundColor: primaryColor,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: RefreshIndicator(
          onRefresh: () async {
            final prefs = await SharedPreferences.getInstance();
            final token = prefs.getString('token');
            if (token == null) return;
            WidgetsBinding.instance.addPostFrameCallback(
              (timeStamp) {
                context.read<ListStoryProvider>().pageItems = 1;
                context.read<ListStoryProvider>().getListStory(token);
              },
            );
          },
          child: Consumer<ListStoryProvider>(
            builder: (context, value, child) {
              if (value.state == StoryState.initial) {
                return CustomScrollView(
                  slivers: [
                    SliverFillRemaining(
                      child: Container(
                        child: Center(
                          child: Text('Empty List'),
                        ),
                      ),
                    )
                  ],
                );
              } else if (value.state == StoryState.loading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (value.state == StoryState.error) {
                return CustomScrollView(
                  slivers: [
                    SliverFillRemaining(
                      child: Container(
                        child: Center(
                          child: Text(value.message),
                        ),
                      ),
                    )
                  ],
                );
              } else {
                return ListView.builder(
                  controller: scrollController,
                  itemBuilder: (context, index) {
                    if (index == value.listStoryModel.listStory.length && value.pageItems != null) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    final story = value.listStoryModel.listStory[index];
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: StoryCard(
                        name: story.name,
                        imageUrl: story.photoUrl,
                        createdAt: story.createdAt,
                        id: story.id,
                      ),
                    );
                  },
                  itemCount: value.listStoryModel.listStory.length + (value.pageItems != null ? 1 : 0),
                  physics: const AlwaysScrollableScrollPhysics(),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

String formatDate(DateTime dateTime) {
  return DateFormat('dd-MM-yyyy').format(dateTime);
}

class StoryCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final DateTime createdAt;
  final String id;
  const StoryCard({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.createdAt,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        splashColor: secondaryColor.withAlpha(120),
        onTap: () {
          context.goNamed('detailStory', pathParameters: {"id": id});
        },
        child: SizedBox(
          height: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 6,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          formatDate(createdAt),
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
