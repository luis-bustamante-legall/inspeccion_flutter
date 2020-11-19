import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

const _linkPrefix = 'https://www.mydeeplink.com/link?token=';

bool validateLink(String link) {
  return (link?.startsWith(_linkPrefix) ?? false);
}

String getToken(String link) {
  return link?.substring(_linkPrefix.length);
}

void copyCollection(String collection) async {
  var coll = await FirebaseFirestore.instance.collection(collection).get();
  /*var firebaseSecondary = await Firebase.initializeApp(name:'secondary',options: FirebaseOptions(
    apiKey: 'AIzaSyAPaE_Bj6nmAMND7yFFGnuFvv83b4hvCGk',
    appId: '1:1007521182877:android:801bce02127be835525074',
    projectId: 'inspeccion-virtual-5f607',
    databaseURL: 'https://inspeccion-virtual-5f607.firebaseio.com',
    storageBucket: 'inspeccion-virtual-5f607.appspot.com',
    messagingSenderId: '1007521182877-ej594pmc56ievdkpe2auinrkm8epj290.apps.googleusercontent.com'
  ));*/
  var firebaseSecondary = await Firebase.app('secondary');
  var secondaryInstance = await FirebaseFirestore.instanceFor(app: firebaseSecondary);
  var secondaryColl = secondaryInstance.collection(collection);
  for(var doc in coll.docs) {
    await secondaryColl.doc(doc.id).set(doc.data());
  }
}

TypeEnum enumFromMap<TypeEnum>(List<TypeEnum> values,String value) {
  for(TypeEnum e in values) {
    if (enumToMap(e) == value)
      return e;
  }
  return null;
}

String enumToMap<TypeEnum>(TypeEnum value) => value.toString().split('.').last;

List<TypeElement> typedList<TypeElement>(List<dynamic> list ) {
  return list?.map((e) => e as TypeElement)?.toList();
}

double doubleOrZero(dynamic value) {
  if (value is double) {
    return value??0;
  } else if (value is int) {
    return value?.toDouble()??0;
  } else if (value is String) {
    return double.tryParse(value)??0;
  } else {
    return 0;
  }
}

int intOrZero(dynamic value) {
  if (value is int) {
    return value??0;
  } else if (value is double) {
    return value?.toInt()??0;
  } else if (value is String) {
    return int.tryParse(value)??0;
  } else {
    return 0;
  }
}

DateTime dateTimeOrNull(dynamic value) {
  print(value);
  if (value is DateTime) {
    return value;
  } else if (value is String) {
    return DateTime.tryParse(value);
  } else if (value is int) {
    return DateTime.fromMicrosecondsSinceEpoch(value??0);
  } else if (value is Timestamp) {
    return value.toDate();
  } else {
    return null;
  }
}