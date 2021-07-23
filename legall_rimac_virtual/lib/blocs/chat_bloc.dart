import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';

class ChatsBloc
    extends Bloc<ChatsEvent, ChatsState> {
  final ChatsRepository _chatsRepository;
  StreamSubscription _chatsSubscription;

  ChatsBloc({@required ChatsRepository repository})
      : assert(repository != null),
        _chatsRepository = repository;

  @override
  ChatsState get initialState => ChatsLoading();

  @override
  Stream<ChatsState> mapEventToState(
      ChatsEvent event) async* {
    if (event is LoadChats) {
      yield* _loadChats(event);
    } else if (event is ReceiveChat) {
      yield* _receiveChat(event);
    } else if (event is SendChat) {
      yield* _sendChat(event);
    } else if (event is ReadAllChats) {
      yield* _readAllChats(event);
    }
  }

  Stream<ChatsState> _loadChats(LoadChats loadChats) async*{
    await _chatsSubscription?.cancel();
    try {
      _chatsSubscription = _chatsRepository
          .get(loadChats.inspectionId)
          .listen((event) {
              add(ReceiveChat(event)
            );
      });
    } catch (e, stackTrace) {
      yield ChatsLoaded.withError(e.toString(), stackTrace: stackTrace);
    }
  }

  Stream<ChatsState> _receiveChat(ReceiveChat receiveChat) async*{
    yield ChatsIncoming();
    yield ChatsLoaded.successfully(receiveChat.chats);
  }

  Stream<ChatsState> _readAllChats(ReadAllChats readAllChats) async*{
    try {
      await _chatsRepository.readAll(readAllChats.inspectionId);
    }
    catch(e,stackTrace) {
      // FirebaseCrashlytics.instance.recordError(e, stackTrace,
      //   reason: 'ReadAllChats');
    }
  }

  Stream<ChatsState> _sendChat(SendChat sendChat) async* {
    try {
      await _chatsRepository.addChat(ChatModel(
          inspectionId: sendChat.inspectionId,
          source: sendChat.source ?? ChatSource.insured,
          dateTime: DateTime.now(),
          body: sendChat.body,
          read: sendChat.read
      ));
    }
    catch(e,stackTrace) {
      // FirebaseCrashlytics.instance.recordError(e, stackTrace,
      //     reason: 'SendChat');
    }
  }

  @override
  Future<void> close() {
    _chatsSubscription?.cancel();
    return super.close();
  }
}

abstract class ChatsEvent extends Equatable {
  const ChatsEvent();

  @override
  List<Object> get props => [];
}

abstract class ChatsState extends Equatable {
  const ChatsState();

  @override
  List<Object> get props => [];
}

class LoadChats extends ChatsEvent {
   final String inspectionId;

   LoadChats(this.inspectionId);

   @override
   List<Object> get props => [inspectionId];
}

class ReadAllChats extends ChatsEvent {
  final String inspectionId;

  ReadAllChats(this.inspectionId);

  @override
  List<Object> get props => [inspectionId];
}

class SendChat extends ChatsEvent {
  final String inspectionId;
  final ChatSource source;
  final bool read;
  final String body;

  SendChat(this.inspectionId,{this.source,this.body,this.read});

  @override
  List<Object> get props => [inspectionId,source,body];
}

class ReceiveChat extends ChatsEvent {
  final List<ChatModel> chats;

  ReceiveChat(this.chats);

  @override
  List<Object> get props => [chats];
}

class ChatsLoading extends ChatsState {}
class ChatsIncoming extends ChatsState {}
class ChatsLoaded extends ChatsState {
  final bool success;
  final String errorMessage;
  final StackTrace stackTrace;
  final List<ChatModel> chats;

  ChatsLoaded(this.success, this.chats, this.errorMessage, this.stackTrace);

  factory ChatsLoaded.successfully(
      List<ChatModel> chats) {
    assert(chats != null);
    return ChatsLoaded(true, chats, null, null);
  }

  factory ChatsLoaded.withError(final String errorMessage,
      {final StackTrace stackTrace}) {
    assert(errorMessage != null);
    return ChatsLoaded(false, null, errorMessage, stackTrace);
  }

  @override
  List<Object> get props => [chats];
}