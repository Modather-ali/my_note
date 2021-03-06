import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<bool> isUserRegistered() async {
  List docsId = [];

  QuerySnapshot result =
      await FirebaseFirestore.instance.collection("Users").get();

  for (var queryDocumentSnapshot in result.docs) {
    docsId.add(queryDocumentSnapshot.id);
  }

  print('$docsId');

  return docsId.contains(FirebaseAuth.instance.currentUser!.email);
}

Future registerNewUser({required String userEmail}) async {
  if (await isUserRegistered()) {
    print("this user already registered");
  } else {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc('$userEmail')
          .set(
        {
          'the_notes': [],
        },
      );
    } catch (e) {
      print("Error in register: $e");
    }
  }
}

Future<bool> signInWithGoogle() async {
  try {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);
    return true;
  } catch (e) {
    print("Error : $e");
    return false;
  }
}

Future<bool> logOut() async {
  try {
    print('Google Log out');

    await GoogleSignIn().disconnect();
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
    return true;
  } catch (e) {
    print('Error in Google Log Out: ${e.toString()}');
    return false;
  }
}
