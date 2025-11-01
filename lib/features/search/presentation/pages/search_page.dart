import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialapp/features/profile/presentation/components/user_tile.dart';
import 'package:socialapp/features/profile/presentation/pages/profile_page.dart';
import 'package:socialapp/features/search/presentation/cubits/search_cubit.dart';
import 'package:socialapp/features/search/presentation/cubits/search_states.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  late final SearchCubit _searchCubit;

  @override
  void initState() {
    super.initState();
    _searchCubit = context.read<SearchCubit>();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    _searchCubit.searchUsers(_searchController.text);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
              hintText: "Search users...",
              border: InputBorder.none,
              hintStyle:
                  TextStyle(color: Theme.of(context).colorScheme.primary)),
        ),
      ),
      body: BlocBuilder<SearchCubit, SearchState>(builder: (context, state) {
        if (state is SearchLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is SearchError) {
          return Center(child: Text(state.message));
        }
        if (state is SearchLoaded) {
          if (state.users.isEmpty) {
            return const Center(child: Text("No users found."));
          }
          return ListView.builder(
            itemCount: state.users.length,
            itemBuilder: (context, index) {
              final user = state.users[index];
              if (user == null) return const SizedBox.shrink();
              return UserTile(
                user: user,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(uid: user.uid),
                  ),
                ),
              );
            },
          );
        }
        return const Center(child: Text("Start searching for users..."));
      }),
    );
  }
}
