import 'package:flutter/material.dart';

class ImageView extends StatelessWidget {
  final url;
  const ImageView({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.network(
        url,
        height: MediaQuery.of(context).size.height / 1.7,
        width: double.maxFinite,
      ),
    );
  }
}
