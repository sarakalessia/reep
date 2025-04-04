import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/component/notification/comments/comments_card.dart';
import 'package:repathy/src/controller/comment_controller/comment_controller.dart';
import 'package:repathy/src/model/data_models/comment_model/comment_model.dart';

class CommentsList extends ConsumerStatefulWidget {
  const CommentsList({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommentsListState();
}

class _CommentsListState extends ConsumerState<CommentsList> {
  @override
  Widget build(BuildContext context) {
    final commentsController = ref.watch(getCommentsProvider);

    return commentsController.when(
      data: (final data) {
        final List<CommentModel>? comments = data.data;
        if (comments == null) return Center(child: Text('Non ci sono commenti'));
        return ListView.builder(
          itemCount: comments.length,
          itemBuilder: (context, index) => CommentsCard(comment: comments[index]),
        );
      },
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Text(error.toString()),
    );
  }
}
