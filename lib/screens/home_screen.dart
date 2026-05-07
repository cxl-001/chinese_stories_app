import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/story_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();
  String _activeTab = '全部';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().init();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF8E1), Color(0xFFFFFDE7)],
          ),
        ),
        child: SafeArea(
          child: Consumer<AppProvider>(
            builder: (context, provider, _) {
              if (provider.loading) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Color(0xFFFF9800)),
                      SizedBox(height: 16),
                      Text('正在加载故事...',
                          style: TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                  ),
                );
              }

              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    floating: true,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    title: Row(
                      children: [
                        const Icon(Icons.menu_book,
                            color: Color(0xFFFF9800), size: 28),
                        const SizedBox(width: 8),
                        const Text(
                          '小故事',
                          style: TextStyle(
                            color: Color(0xFF333333),
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Hi, ${provider.childName}',
                          style: const TextStyle(
                            color: Color(0xFF999999),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(100),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            TextField(
                              controller: _searchCtrl,
                              onChanged: provider.searchStories,
                              decoration: InputDecoration(
                                hintText: '搜索故事...',
                                prefixIcon: const Icon(Icons.search,
                                    color: Colors.grey),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 0),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 36,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: provider.categories.length,
                                itemBuilder: (ctx, i) {
                                  final cat = provider.categories[i];
                                  final isActive = cat == _activeTab;
                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(right: 8),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(
                                            () => _activeTab = cat);
                                        provider.filterByCategory(cat);
                                      },
                                      child: Container(
                                        padding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 16),
                                        decoration: BoxDecoration(
                                          color: isActive
                                              ? const Color(0xFFFF9800)
                                              : Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(18),
                                          boxShadow: isActive
                                              ? [
                                                  BoxShadow(
                                                    color: const Color(
                                                            0xFFFF9800)
                                                        .withOpacity(0.4),
                                                    blurRadius: 6,
                                                  )
                                                ]
                                              : null,
                                        ),
                                        child: Center(
                                          child: Text(
                                            cat,
                                            style: TextStyle(
                                              color: isActive
                                                  ? Colors.white
                                                  : const Color(0xFF666666),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: provider.stories.isEmpty
                        ? SliverFillRemaining(
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.search_off,
                                      size: 64, color: Colors.grey[300]),
                                  const SizedBox(height: 16),
                                  Text('没有找到故事',
                                      style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 16)),
                                ],
                              ),
                            ),
                          )
                        : SliverGrid(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.85,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (ctx, i) {
                                final story = provider.stories[i];
                                return StoryCard(
                                  story: story,
                                  isFavorite:
                                      provider.isFavorite(story.id),
                                  onFavorite: () =>
                                      provider.toggleFavorite(story.id),
                                  onTap: () {
                                    provider.setLastStory(story.id);
                                    Navigator.of(context).pushNamed(
                                      '/player',
                                      arguments: story,
                                    );
                                  },
                                );
                              },
                              childCount: provider.stories.length,
                            ),
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
