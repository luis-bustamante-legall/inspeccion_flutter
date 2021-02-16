import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:legall_rimac_virtual/models/models.dart';

class ChatsRepository {
  final _chatsCollection = FirebaseFirestore.instance.collection('chats');

  Stream<List<ChatModel>> get(String inspectionId) {
    return _chatsCollection
        .where('inspection_id',isEqualTo: inspectionId)
        .orderBy('datetime')
        .snapshots()
        .map((docs) => docs
        .docs
        .map((doc) => ChatModel.fromJSON(doc.data())).toList());
  }

  Future<String> addChat(ChatModel chat) async {
    return (await _chatsCollection.add(chat.toJSON())).id;
  }

  Future<void> readAll(String inspectionId) async {
    var chats = await _chatsCollection
      .where('inspection_id',isEqualTo: inspectionId)
      .where('read',isEqualTo: false)
      .where('source',whereIn:['inspector','system'])
      .get();
    return FirebaseFirestore.instance.runTransaction((transaction) async {
      for(var chat in chats.docs) {
        transaction.update(chat.reference, {
          'read': true
        });
      }
    });
  }
}