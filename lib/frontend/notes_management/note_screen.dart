import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:my_note/backend/notes_management_methods.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:my_note/frontend/notes_management/image_view.dart';

class NoteScreen extends StatefulWidget {
  final String lastTitle;
  final String lastNoteContent;
  final String? lastImageUrl;
  final int noteIndex;
  NoteScreen(
      {Key? key,
      required this.lastTitle,
      required this.lastNoteContent,
      required this.lastImageUrl,
      required this.noteIndex})
      : super(key: key);

  @override
  _NoteScreenState createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  bool _isLoaderVisible = false;
  String imageUrl = '';
  ImagePicker imagePicker = ImagePicker();
  TextEditingController _titleText = TextEditingController();
  TextEditingController _noteText = TextEditingController();

  @override
  void initState() {
    imageUrl = widget.lastImageUrl!;
    _titleText.text = widget.lastTitle;
    _noteText.text = widget.lastNoteContent;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              actions: [
                IconButton(
                    highlightColor: Colors.teal,
                    iconSize: 40,
                    onPressed: () async {
                      context.loaderOverlay.show();
                      setState(() {
                        _isLoaderVisible = context.loaderOverlay.visible;
                      });
                      bool result = await addOrEditNote(
                          noteTitle: _titleText.text,
                          noteContent: _noteText.text,
                          imageUrl: imageUrl,
                          index: widget.noteIndex);
                      if (_isLoaderVisible) {
                        context.loaderOverlay.hide();
                      }

                      setState(() {
                        _isLoaderVisible = context.loaderOverlay.visible;
                      });

                      if (result) {
                        Navigator.of(context).pushReplacementNamed('HomePage');
                        Navigator.of(context).pop();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error happened'),
                            behavior: SnackBarBehavior.floating,
                            margin: EdgeInsets.all(10),
                          ),
                        );
                      }
                    },
                    icon: Icon(
                      Icons.done,
                      color: Colors.black,
                    ))
              ],
              backgroundColor: Colors.tealAccent,
              expandedHeight: MediaQuery.of(context).size.height / 3.5,
              flexibleSpace: FlexibleSpaceBar(
                background: _backgroundImage(),
              ),
            ),
            Form(
              child: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    _titleTextField(),
                    _noteTextField(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _titleTextField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: _titleText,
        maxLength: 25,
        style: TextStyle(color: Colors.black),
        maxLines: null,
        decoration: InputDecoration(
          hintText: 'Title',
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _noteTextField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: _noteText,
        style: TextStyle(color: Colors.black),
        maxLines: null,
        decoration: InputDecoration(
          hintText: 'Start writing...',
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _backgroundImage() {
    if (imageUrl == '') {
      return ElevatedButton(
          onPressed: () {
            showModalBottomSheet(
                context: context,
                builder: (context) {
                  return Container(
                    height: MediaQuery.of(context).size.height / 4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          'Take image form:',
                          style: TextStyle(color: Colors.black, fontSize: 18),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            takeImageButton(
                              imageSource: ImageSource.camera,
                              buttonName: 'Camera',
                            ),
                            takeImageButton(
                              imageSource: ImageSource.gallery,
                              buttonName: 'Gallery',
                            )
                          ],
                        ),
                      ],
                    ),
                  );
                });
          },
          child: Text('Add image'));
    } else {
      return OpenContainer(
          transitionDuration: Duration(milliseconds: 500),
          transitionType: ContainerTransitionType.fadeThrough,
          openColor: Colors.transparent,
          closedBuilder: (context, closeBuilder) {
            return Image.network(
              imageUrl,
              fit: BoxFit.fill,
            );
          },
          openBuilder: (context, openBuilder) {
            return ImageView(
              url: imageUrl,
            );
          });
    }
  }

  Widget takeImageButton({
    required ImageSource imageSource,
    required String buttonName,
  }) {
    return ElevatedButton(
        onPressed: () async {
          XFile? pickedImage = await imagePicker.pickImage(source: imageSource);
          if (pickedImage != null) {
            Navigator.pop(context);
            context.loaderOverlay.show();
            setState(() {
              _isLoaderVisible = context.loaderOverlay.visible;
            });

            imageUrl = await addImage(imagePath: pickedImage.path);

            if (_isLoaderVisible) {
              context.loaderOverlay.hide();
            }
            setState(() {
              _isLoaderVisible = context.loaderOverlay.visible;
            });
          }
        },
        child: Text(buttonName));
  }
}
