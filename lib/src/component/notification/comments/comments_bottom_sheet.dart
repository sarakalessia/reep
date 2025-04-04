import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/component/button/primary_button.dart';
import 'package:repathy/src/component/input/input_field.dart';
import 'package:repathy/src/component/notification/comments/comments_card.dart';
import 'package:repathy/src/controller/comment_controller/comment_controller.dart';
import 'package:repathy/src/controller/form_controller/form_controller.dart';
import 'package:repathy/src/controller/media_controller/media_controller.dart';
import 'package:repathy/src/controller/user_controller/user_controller.dart';
import 'package:repathy/src/model/data_models/comment_model/comment_model.dart';
import 'package:repathy/src/util/key/keys.dart';
import 'package:repathy/src/util/enum/role_enum.dart';
import 'package:repathy/src/theme/styles.dart';

class CommentsBottomSheet extends ConsumerStatefulWidget {
  const CommentsBottomSheet({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends ConsumerState<CommentsBottomSheet> {
  final TextEditingController _contentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => focusNodeListener());
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _contentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void focusNodeListener() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final commentsController = ref.watch(getCommentsProvider);
    final currentMedia = ref.watch(mediaControllerProvider);
    final currentUser = ref.watch(userControllerProvider);

    return Container(
      width: MediaQuery.sizeOf(context).width,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: RepathyStyle.backgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(RepathyStyle.roundedRadius),
          topRight: Radius.circular(RepathyStyle.roundedRadius),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: RepathyStyle.primaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 32, 8, 16),
            child: Text(
              'Commenti',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: RepathyStyle.standardTextSize,
                fontWeight: RepathyStyle.standardFontWeight,
                color: RepathyStyle.defaultTextColor,
              ),
            ),
          ),
          SizedBox(
            height: _focusNode.hasFocus ? 130 : 350,
            child: commentsController.when(
              data: (final data) {
                final List<CommentModel>? comments = data.data;
                if (comments == null) return SizedBox(child: Text('Non ci sono commenti'));
                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) => CommentsCard(comment: comments[index]),
                );
              },
              loading: () => Center(child: (CircularProgressIndicator())),
              error: (error, stackTrace) => Center(child: Text(error.toString())),
            ),
          ),
          if (currentUser!.role == RoleEnum.patient) ...[
            SizedBox(
              height: 200,
              child: Form(
                key: commentKey,
                child: Column(
                  children: [
                    InputFormField(
                      controller: _contentController,
                      focusNode: _focusNode,
                      name: 'Contenuto',
                      validator: (value) => ref.read(formControllerProvider.notifier).validateEmptyOrNull(value, context),
                    ),
                    PrimaryButton(
                      text: 'Salva',
                      onPressed: () async {
                        ref.read(formControllerProvider.notifier).handleForm(
                          route: null,
                          globalKey: commentKey,
                          context: context,
                          actions: [
                            () async => await ref
                                .read(commentControllerProvider.notifier)
                                .createComment(mediaModel: currentMedia!, content: _contentController.text),
                          ],
                          onEnd: [
                            () => ref.refresh(getCommentsProvider),
                            () => _contentController.clear(),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
