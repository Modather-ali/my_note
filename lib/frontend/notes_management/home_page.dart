import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/src/overlay_controller_widget_extension.dart';
import 'package:my_note/backend/auth_methods.dart';
import 'package:my_note/backend/notes_management_methods.dart';
import 'package:my_note/frontend/notes_management/note_screen.dart';
import 'package:animations/animations.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePage();
  }
}

class _HomePage extends State<HomePage> {
  bool _isLoaderVisible = false;
  List notesData = [];
  Future getNotesData() async {
    Stream<QuerySnapshot<Map<String, dynamic>>> stream =
        FirebaseFirestore.instance.collection('users').snapshots();
    stream.forEach((querySnapshot) {
      querySnapshot.docs.forEach((queryDocumentSnapshot) {
        if (queryDocumentSnapshot.id ==
            FirebaseAuth.instance.currentUser!.email) {
          setState(() {
            notesData.clear();
            notesData.addAll(queryDocumentSnapshot.data()['the_notes']);
          });
        }
      });
    });
  }

  @override
  void initState() {
    getNotesData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                  color: Colors.black,
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text(
                              'Sign Out?',
                              style: TextStyle(color: Colors.black),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(color: Colors.green),
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  context.loaderOverlay.show();
                                  setState(() {
                                    _isLoaderVisible =
                                        context.loaderOverlay.visible;
                                  });
                                  final bool googleResponse = await logOut();
                                  if (!googleResponse) {
                                    await FirebaseAuth.instance.signOut();
                                  }

                                  if (_isLoaderVisible) {
                                    context.loaderOverlay.hide();
                                  }
                                  setState(() {
                                    _isLoaderVisible =
                                        context.loaderOverlay.visible;
                                  });
                                  Navigator.of(context).pop();
                                  Navigator.of(context)
                                      .pushReplacementNamed('WelcomeScreen');
                                },
                                child: Text(
                                  'sign out',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          );
                        });
                  },
                  icon: Icon(Icons.logout)),
            ],
            backgroundColor: Colors.tealAccent,
            centerTitle: true,
            title: Text(
              "All notes",
              style: TextStyle(color: Colors.black54),
            ),
          ),
          body: ListView.builder(
              padding: const EdgeInsets.only(bottom: 50.0),
              itemCount: notesData.length,
              itemBuilder: (context, index) {
                return _noteCard(index);
              }),
          bottomSheet: _bottonSheet()),
    );
  }

  Widget _noteCard(int index) {
    return Dismissible(
      key: UniqueKey(),
      background: Container(
        padding: EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        color: Colors.grey,
        child: Icon(
          Icons.delete_forever,
          color: Colors.red,
          size: 40,
        ),
      ),
      onDismissed: (value) async {
        context.loaderOverlay.show();
        setState(() {
          _isLoaderVisible = context.loaderOverlay.visible;
        });

        bool result = await removeNote(index);

        if (_isLoaderVisible) {
          context.loaderOverlay.hide();
        }
        setState(() {
          _isLoaderVisible = context.loaderOverlay.visible;
        });
        if (result) {
          await getNotesData();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text(
                'Item has been removed',
              ),
              backgroundColor: Colors.red,
              margin: EdgeInsets.all(10),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text(
                'ُError happened! check online',
              ),
              margin: EdgeInsets.all(10),
            ),
          );
        }
      },
      child: OpenContainer(
        closedElevation: 0.0,
        transitionDuration: Duration(milliseconds: 500),
        transitionType: ContainerTransitionType.fadeThrough,
        closedBuilder: (context, closeBuilder) {
          return Card(
            child: Row(
              children: [
                notesData[index]['image_url'] != ''
                    ? Expanded(
                        flex: 2,
                        child: Image.network(
                          notesData[index]['image_url'],
                          fit: BoxFit.fill,
                          height: MediaQuery.of(context).size.height / 10,
                        ),
                      )
                    : Text(''),
                Expanded(
                  flex: 5,
                  child: ListTile(
                    title: Text(
                      notesData[index]['note_title'],
                      style: TextStyle(color: Colors.black),
                    ),
                    subtitle: Text(
                      notesData[index]['note_content'],
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    trailing: Text(
                      notesData[index]['edit_time'],
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        openBuilder: (context, openBuilder) {
          return NoteScreen(
            lastImageUrl: notesData[index]['image_url'],
            lastTitle: notesData[index]['note_title'],
            lastNoteContent: notesData[index]['note_content'],
            noteIndex: index,
          );
        },
      ),
    );
  }

  Widget _bottonSheet() {
    return Container(
      alignment: Alignment.topCenter,
      width: double.infinity,
      height: 60,
      color: Colors.teal,
      child: OpenContainer(
        closedShape: CircleBorder(),
        transitionDuration: Duration(milliseconds: 500),
        transitionType: ContainerTransitionType.fadeThrough,
        closedBuilder: (context, closewidget) {
          return CircleAvatar(
            radius: 40.0,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 25,
              child: Icon(Icons.add),
            ),
          );
        },
        openBuilder: (context, openWidget) {
          return NoteScreen(
            lastImageUrl: '',
            lastTitle: '',
            lastNoteContent: '',
            noteIndex: -1,
          );
        },
      ),
    );
  }
}
