import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialapp/features/auth/data/firebase_auth_repo.dart';
import 'package:socialapp/features/home/presentation/pages/home_page.dart';
import 'package:socialapp/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:socialapp/features/auth/presentation/cubits/auth_states.dart';
import 'package:socialapp/features/auth/presentation/pages/auth_page.dart';
import 'package:socialapp/features/profile/data/firebase_profile_repo.dart';
import 'package:socialapp/features/profile/presentation/cubits/profile_cubit.dart';
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
  final authRepo = FirebaseAuthRepo();

  // profile repo
  final profileRepo = FirebaseProfileRepo();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // provide cubits to app
    return MultiBlocProvider(providers: [
      // auth cubit
      BlocProvider<AuthCubit>(
        create: (context) => AuthCubit(authRepo: authRepo)..checkAuth(),
      ),

      // profile cubit
      BlocProvider<ProfileCubit>(create: (context) => ProfileCubit(profileRepo: profileRepo),),

    ], 
    child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: lightMode,
        home: BlocConsumer<AuthCubit, AuthState>(
          builder: (context, authState) {
            print(authState);

            // unauthenticated -> Auth Page (login/register)
            if (authState is Unauthenticated) {
              return const AuthPage();
            }

            // authenticated -> Home Page
            if (authState is Authenticated) {
              return const HomePage();
            }
            // loading...
            else {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
          },

          // listen for errors..
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.errorMessage)));
            }
          },
        ),
      ),
    );  
  }
}
