// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadless/src/providers/google_auth_provider.dart';
import 'package:roadless/src/providers/shared_preferences_provider.dart';
import 'package:roadless/src/providers/theme_provider.dart';
import 'package:roadless/src/providers/tracks_provider.dart';
import 'package:roadless/src/screens/track_details.dart';
import 'package:roadless/src/screens/new_track.dart';
import 'package:roadless/src/utils.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracks = ref.watch(tracksProvider);
    final sharedPreferences = ref.watch(sharedPreferencesProvider);

    final user = ref.watch(googleUserProvider);

    final isGoogleSignIn = ref.watch(isGoogleSignInProvider);

    void signInGoogle() async {
      try {
        final userCredential = await signInWithGoogle();
        final user = userCredential.user;
        if (user != null) {
          sharedPreferences.setBool("is_google_sign_in", true);
          ref.read(googleUserProvider.notifier).update((state) => user);
          ref.read(isGoogleSignInProvider.notifier).update((state) => true);
        }
      } catch (e) {
        print('Error signing in with Google: $e');
      }
    }

    if (isGoogleSignIn && user == null) {
      signInGoogle();
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      appBar: AppBar(
        title: const Text("Roadless"),
        actions: [
          IconButton(
            onPressed: () {
              bool newThemeStyle = !ref.read(isDarkModeProvider);
              sharedPreferences.setBool("is_dark_mode", newThemeStyle);
              ref.read(isDarkModeProvider.notifier).update((state) => newThemeStyle);
            },
            icon: ref.read(isDarkModeProvider) ? const Icon(Icons.light_mode_outlined) : const Icon(Icons.dark_mode_outlined),
          ),
          if (user != null)
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: SizedBox(
                          width: 500,
                          child: Text(user.displayName!),
                        ),
                        content: SingleChildScrollView(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(50.0),
                                    child: Image.network(user.photoURL ?? ""),
                                  ),
                                  const SizedBox(width: 20),
                                  Text(user.email ?? "", style: Theme.of(context).textTheme.bodyLarge),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton(
                                    onPressed: () {
                                      signOutFromGoogle();
                                      ref.read(googleUserProvider.notifier).update((state) => null);
                                      sharedPreferences.setBool("is_google_sign_in", false);
                                      ref.read(isGoogleSignInProvider.notifier).update((state) => false);
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text("Cerrar sesión"),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                child: Text(user.displayName!),
              ),
            ),
          if (user == null)
            IconButton(
              onPressed: () async {
                signInGoogle();
              },
              icon: const Icon(Icons.login_outlined),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: tracks.length,
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(
                    height: 5,
                  );
                },
                itemBuilder: (context, index) {
                  MapController mapController = MapController();
                  return Dismissible(
                    key: Key(tracks[index].id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                      child: const Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                    ),
                    onDismissed: (direction) {
                      ref.read(tracksProvider.notifier).removeTrack(tracks[index]);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("${tracks[index].name} eliminada")),
                      );
                    },
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TrackDetailsScreen(
                              track: tracks[index],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(tracks[index].name),
                                  Text(
                                    "${tracks[index].distance} km",
                                    style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.grey[600]),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              height: 50,
                              child: FlutterMap(
                                mapController: mapController,
                                options: MapOptions(
                                  initialCenter: tracks[index].getBounds().center,
                                  initialZoom: fitBoundsFromTrackData(tracks[index].getBounds(), const Size(80, 180)),
                                  interactionOptions: const InteractionOptions(
                                    flags: InteractiveFlag.none,
                                  ),
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate: Theme.of(context).colorScheme.brightness == Brightness.light
                                        ? 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png'
                                        : 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
                                    maxZoom: 19,
                                  ),
                                  PolylineLayer(
                                    polylines: [
                                      Polyline(
                                        points: tracks[index].points,
                                        strokeWidth: 2,
                                        color: tracks[index].color,
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            )
                          ],
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
      floatingActionButton: FloatingActionButton(
        tooltip: "Añadir track",
        onPressed: () async {
          String? trackData = await loadTrackData();

          if (trackData != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NewTrackScreen(trackData: trackData),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error al cargar el track'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
