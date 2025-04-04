import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/component/notification/announcements/announcements_list.dart';
import 'package:repathy/src/component/notification/comments/comments_list.dart';
import 'package:repathy/src/component/notification/events/transfer_list.dart';
import 'package:repathy/src/component/notification/invites/invites_list.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:repathy/src/component/text/page_title_text.dart';
import 'package:repathy/src/theme/styles.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key, this.initialIndex});

  final int? initialIndex;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: widget.initialIndex ?? 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PageTitleText(title: 'Notifiche'),
                Icon(
                  Icons.mark_email_read_rounded,
                  color: RepathyStyle.primaryColor,
                  size: RepathyStyle.standardIconSize,
                ),
              ],
            ),
          ),
          TabBar(
            tabAlignment: TabAlignment.center,
            labelPadding: EdgeInsets.fromLTRB(8, 16, 8, 0),
            isScrollable: true,
            indicatorColor: RepathyStyle.primaryColor,
            indicatorWeight: 4,
            controller: _tabController,
            onTap: (index) => _tabController.animateTo(index),
            tabs: [
              Tab(text: 'Generali'),
              Tab(text: 'Comunicazioni'),
              Tab(text: AppLocalizations.of(context)!.invites),
              Tab(text: AppLocalizations.of(context)!.comments),
            ],
          ),
          SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                TransferList(),
                AnnouncementsList(),
                InvitesList(),
                CommentsList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
