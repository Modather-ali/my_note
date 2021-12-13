import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

String _collectionName = 'users';

final CollectionReference<Map<String, dynamic>> collectionReference =
    FirebaseFirestore.instance.collection(_collectionName);

final String? currentUserEmail = FirebaseAuth.instance.currentUser!.email;

final DocumentReference<Map<String, dynamic>> currentUserDocument =
    collectionReference.doc("$currentUserEmail");

Future<bool> addOrEditNote({
  required String noteTitle,
  required String noteContent,
  required String imageUrl,
  required int index,
}) async {
  try {
    List oldNotes = [];
    String editTime = '${DateTime.now().month}/${DateTime.now().day}';
    Map newNote = {
      'note_title': noteTitle,
      'note_content': noteContent,
      'image_url': imageUrl,
      'edit_time': editTime
    };

    final DocumentSnapshot<Map<String, dynamic>> getCurrentUserData =
        await currentUserDocument.get();

    final Map<String, dynamic>? currentUserData = getCurrentUserData.data();
    if (currentUserData!['the_notes'].isNotEmpty) {
      oldNotes = currentUserData['the_notes'];
    }

    if (index >= 0) {
      // just will edit a note
      oldNotes[index] = newNote;
    } else {
      // will add new note
      oldNotes.add(newNote);
    }
    await currentUserDocument.update({
      'the_notes': oldNotes,
    });
    return true;
  } catch (e) {
    print('Error : $e');
    return false;
  }
}

Future addImage({
  required String imagePath,
}) async {
  try {
    File file = File(imagePath);
    String imageName = basename(imagePath);
    int random = Random().nextInt(10000);
    Reference storageRef =
        FirebaseStorage.instance.ref('images').child('$random$imageName');
    await storageRef.putFile(file);
    String imageUrl = await storageRef.getDownloadURL();
    return imageUrl;
  } catch (e) {
    print('Error : %e');
    return null;
  }
}

Future<bool> removeNote(int index) async {
  try {
    List oldNotes = [];

    final DocumentSnapshot<Map<String, dynamic>> getCurrentUserData =
        await currentUserDocument.get();

    final Map<String, dynamic>? currentUserData = getCurrentUserData.data();
    if (currentUserData!['the_notes'].isNotEmpty) {
      oldNotes = currentUserData['the_notes'];
    }

    oldNotes.removeAt(index);
    await currentUserDocument.update({
      'the_notes': oldNotes,
    });
    return true;
  } catch (e) {
    print('Error : $e');
    return false;
  }
}
