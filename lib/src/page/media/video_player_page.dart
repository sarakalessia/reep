import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/route/route.dart';
import 'package:repathy/src/controller/media_interaction_controller/media_interaction_controller.dart';
import 'package:repathy/src/controller/video_player_controller/video_player_controller.dart';
import 'package:repathy/src/model/data_models/media_model_group/media_interaction_model/media_interaction_model.dart';
import 'package:repathy/src/model/data_models/media_model_group/media_model/media_model.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';
import 'package:repathy/src/util/enum/role_enum.dart';
import 'package:repathy/src/theme/styles.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerPage extends ConsumerStatefulWidget {
  const VideoPlayerPage({super.key, required this.mediaModel, required this.mediaInteractionList, required this.currentUser});

  final MediaModel mediaModel;
  final List<MediaInteractionModel>? mediaInteractionList;
  final UserModel? currentUser;

  @override
  ConsumerState<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends ConsumerState<VideoPlayerPage> {
  String? assetPath;

  @override
  void initState() {
    initializeDependencies();
    super.initState();
  }

  Future<void> initializeDependencies() async {
    debugPrint(
      'View: about to initialize video player with video ${widget.mediaModel},'
      'and media interaction list ${widget.mediaInteractionList}'
      'and current user ${widget.currentUser}',
    );
    assetPath = widget.mediaModel.mediaPath;
    await ref.read(videoPlayerServiceProvider(assetPath!).notifier).initializeControllerAndProvider();
    final RoleEnum currentUserRole = widget.currentUser!.role;
    bool firstInteractionIsSaved = false;
    if (widget.mediaInteractionList != null) {
      for (final interaction in widget.mediaInteractionList!) {
        if (interaction.patientId == widget.currentUser!.id) {
          firstInteractionIsSaved = true;
          break;
        }
      }
    }
    if (!firstInteractionIsSaved && currentUserRole == RoleEnum.patient) {
      debugPrint('View: about to save the first interaction with video ${widget.mediaModel.id}');
      ref.read(mediaInteractionControllerProvider.notifier).saveMediaInteractionToFirestore(widget.mediaModel);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final videoPlayerService = ref.watch(videoPlayerServiceProvider(assetPath!));

    return Stack(
      children: [
        Positioned.fill(
          child: videoPlayerService.value.isInitialized
              ? AspectRatio(
                  aspectRatio: videoPlayerService.value.aspectRatio,
                  child: VideoPlayer(videoPlayerService),
                )
              : Center(child: CircularProgressIndicator()),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 60, 24, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FloatingActionButton(
                      backgroundColor: RepathyStyle.backgroundColor,
                      onPressed: () => ref.read(goRouterProvider).go('/'),
                      child: Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton(
                    backgroundColor: RepathyStyle.backgroundColor,
                    onPressed: () => videoPlayerService.seekTo(videoPlayerService.value.position - Duration(seconds: 5)),
                    child: Icon(Icons.replay_10),
                  ),
                  FloatingActionButton(
                    backgroundColor: RepathyStyle.backgroundColor,
                    onPressed: () async {
                      if (videoPlayerService.value.isPlaying) {
                        await videoPlayerService.pause();
                      } else {
                        await videoPlayerService.play();
                      }
                      setState(() {});
                    },
                    child: Icon(videoPlayerService.value.isPlaying ? Icons.pause : Icons.play_arrow),
                  ),
                  FloatingActionButton(
                    backgroundColor: RepathyStyle.backgroundColor,
                    onPressed: () => videoPlayerService.seekTo(videoPlayerService.value.position + Duration(seconds: 5)),
                    child: Icon(Icons.forward_10),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
