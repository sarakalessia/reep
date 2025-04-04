import 'package:repathy/src/util/enum/invitation_enum.dart';

enum EventType {
  communication,
  attribution,
  invitation,
  transfer,
  license,
  comment,
  modification,
  action,
}

abstract class Event {
  final EventType type;
  final String content;
  final DateTime date;
  final String senderId;

  Event(this.type, this.content, this.date, this.senderId);
}

class AcceptanceEvent extends Event {
  AcceptanceEvent(String content, DateTime date, String senderId, this.status, this.receiverId) : super(EventType.invitation, content, date, senderId);

  final InvitationStatus status;
  final String receiverId;
  // final EventType type = EventType.invitation; // HAS TO BE INVITATION OF TRANSFER I DON'T KNOW HOW TO SET THIS UP, DO I CREATE A SUB ENUM?
}

class ReadOnlyEvent extends Event {
  ReadOnlyEvent(String content, DateTime date, String senderId, this.recipients) : super(EventType.communication, content, date, senderId);

  final List<String> recipients;
  // final EventType type = EventType.communication ||  action || attribution || license || modification || comment;
}
