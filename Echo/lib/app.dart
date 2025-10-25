import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/features/auth/data/backend_auth_repo.dart';
import 'package:socialapp/features/auth/data/firebase_auth_repo.dart';
import 'package:socialapp/features/home/presentation/pages/home_page.dart';
import 'package:socialapp/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:socialapp/features/auth/presentation/cubits/auth_states.dart';
import 'package:socialapp/features/auth/presentation/pages/auth_page.dart';
import 'package:socialapp/features/post/data/firebase_post_repo.dart';
import 'package:socialapp/features/post/presentation/cubits/posts_cubit.dart';
import 'package:socialapp/features/profile/data/firebase_profile_repo.dart';
import 'package:socialapp/features/profile/data/backend_profile_repo.dart';
import 'package:socialapp/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:socialapp/features/storage/data/firebase_storage_repo.dart';
import 'package:socialapp/features/storage/data/backend_storage_repo.dart';
import 'package:socialapp/themes/light_mode.dart';

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
              postRepo: firebasePostRepo,
              storageRepo: backendStorageRepo,
            ),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: lightMode,
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
                print("App - Authentication state changed to Authenticated");
                print(
                  "App - Backend auth token present: ${backendAuthRepo.token != null}",
                );
                if (backendAuthRepo.token != null) {
                  print(
                    "App - Setting token in repos: ${backendAuthRepo.token}",
                  );
                  backendProfileRepo.setToken(backendAuthRepo.token!);
                  backendStorageRepo.setToken(backendAuthRepo.token!);
                } else {
                  print(
                    "App - Warning: No token available after authentication",
                  );
                }
              }
            },
          ),
        ),
      ),
    );
  }
}
