import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:repathy/src/controller/user_controller/user_controller.dart';
import 'package:repathy/src/model/data_models/comment_model/comment_model.dart';
import 'package:repathy/src/theme/styles.dart';

class CommentsCard extends ConsumerStatefulWidget {
  const CommentsCard({super.key, required this.comment});

  final CommentModel comment;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommentsCardState();
}

class _CommentsCardState extends ConsumerState<CommentsCard> {
  @override
  Widget build(BuildContext context) {
    final author = ref.watch(getUserModelByIdProvider(widget.comment.authorId));
    final DateFormat dateFormatter = DateFormat('dd/MM/yyyy');
    final String date = dateFormatter.format(widget.comment.createdAt!);

    return author.when(
      data: (final data) {
        final syncAuthor = data.data;
        if (syncAuthor == null) return Text('Autore non trovato');
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8),
          child: ListTile(
            tileColor: RepathyStyle.backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(RepathyStyle.standardRadius),
              side: BorderSide(color: RepathyStyle.borderColor, width: 1.5),
            ),
            title: Padding(padding: const EdgeInsets.only(left: 8), child: Text('${syncAuthor.name} ${syncAuthor.lastName}')),
            subtitle: Padding(padding: const EdgeInsets.only(left: 8), child: Text(widget.comment.content ?? '')),
            trailing: Text(date),
          ),
        );
      },
      loading: () => SizedBox(
        height: 8.0,
        width: 8.0,
        child: Transform.scale(scale: 0.5, child: CircularProgressIndicator(color: RepathyStyle.primaryColor, strokeWidth: 4.0)),
      ),
      error: (error, _) => Text(error.toString()),
    );
  }
}
