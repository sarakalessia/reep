import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/component/media/media_card.dart';
import 'package:repathy/src/model/data_models/media_model_group/media_model/media_model.dart';

class MediaLibraryBody extends ConsumerStatefulWidget {
  const MediaLibraryBody({super.key, required this.mediaModelList});

  final List<MediaModel> mediaModelList;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MediaLibraryBodyState();
}

class _MediaLibraryBodyState extends ConsumerState<MediaLibraryBody> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 370,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
        child: SingleChildScrollView(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: widget.mediaModelList.map((mediaModel) {
                return SizedBox(
                  width: 110,
                  child: MediaCard(mediaModel: mediaModel),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
