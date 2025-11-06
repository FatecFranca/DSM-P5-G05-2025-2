import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/features/auth/data/backend_auth_repo.dart';
import 'package:socialapp/features/auth/data/firebase_auth_repo.dart';
import 'package:socialapp/features/home/presentation/pages/home_page.dart';
import 'package:socialapp/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:socialapp/features/auth/presentation/cubits/auth_states.dart';
import 'package:socialapp/features/auth/presentation/pages/auth_page.dart';
import 'package:socialapp/features/post/data/backend_post_repo.dart';
import 'package:socialapp/features/post/data/firebase_post_repo.dart';
import 'package:socialapp/features/post/presentation/cubits/posts_cubit.dart';
import 'package:socialapp/features/profile/data/firebase_profile_repo.dart';
import 'package:socialapp/features/profile/data/backend_profile_repo.dart';
import 'package:socialapp/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:socialapp/features/search/data/firebase_search_repo.dart';
import 'package:socialapp/features/search/data/backend_search_repo.dart';
import 'package:socialapp/features/search/presentation/cubits/search_cubits.dart';
import 'package:socialapp/features/storage/data/firebase_storage_repo.dart';
import 'package:socialapp/features/storage/data/backend_storage_repo.dart';
import 'package:socialapp/themes/theme_cubit.dart';

/*

APP - Root Level

Repositories: for the database
  - firebase

Bloc Providers: for state management
  - auth
  - profile
  - posts
  - search
  - theme

Check Auth State
  - unauthenticated -> Auth Page (login/register)
  - authenticated -> Home Page
*/

class MyApp extends StatelessWidget {
  // auth repo
  final firebaseAuthRepo = FirebaseAuthRepo();
  final backendAuthRepo = BackendAuthRepo();

  // profile repo
  final firebaseProfileRepo = FirebaseProfileRepo();
  final backendProfileRepo = BackendProfileRepo();

  // storage repo
  final firebaseStorageRepo = FirebaseStorageRepo();
  final backendStorageRepo = BackendStorageRepo();

  // post repo
  final firebasePostRepo = FirebasePostRepo();
  final BackendPostRepo backendPostRepo = BackendPostRepo();

  // search repo
  final firebaseSearchRepo = FirebaseSearchRepo();
  final backendSearchRepo = BackendSearchRepo();
  // conexao com o back-end //

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: backendAuthRepo,
      child: MultiBlocProvider(
        providers: [
          // auth cubit usando backendAuthRepo ou firebaseAuthRepo
          BlocProvider<AuthCubit>(
            create: (context) =>
                AuthCubit(authRepo: backendAuthRepo)..checkAuth(),
          ),

          // profile cubit
          BlocProvider<ProfileCubit>(
            create: (context) => ProfileCubit(
              profileRepo: backendProfileRepo,
              storageRepo: backendStorageRepo,
            ),
          ),

          // post cubit
          BlocProvider<PostCubit>(
            create: (context) => PostCubit(
              postRepo: backendPostRepo,
              storageRepo: backendStorageRepo,
            ),
          ),

          // search cubit
          BlocProvider<SearchCubit>(
            create: (context) => SearchCubit(searchRepo: backendSearchRepo),
          ),

          // theme cubit
          BlocProvider<ThemeCubit>(create: (context) => ThemeCubit()),
        ],

        // bloc builder: themes
        child: BlocBuilder<ThemeCubit, ThemeData>(
          builder: (context, currentTheme) => MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: currentTheme,

            // bloc builder: check current auth state
            home: BlocConsumer<AuthCubit, AuthState>(
              builder: (context, authState) {
                if (authState is Unauthenticated) {
                  return const AuthPage();
                }
                if (authState is Authenticated) {
                  return const HomePage();
                }
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              },
              listener: (context, state) {
                if (state is AuthError) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.errorMessage)));
                }

                if (state is Authenticated) {
                  if (backendAuthRepo.token != null) {
                    backendProfileRepo.setToken(backendAuthRepo.token!);
                    backendStorageRepo.setToken(backendAuthRepo.token!);
                    backendPostRepo.setToken(backendAuthRepo.token!);
                    backendSearchRepo.setToken(backendAuthRepo.token!);
                  }
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
