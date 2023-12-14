import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImgViewer extends StatelessWidget {
  const ImgViewer({super.key, required this.img});

  final String img;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: PhotoView(
        imageProvider: NetworkImage(img),
        loadingBuilder: (context, event) {
          return const CircularProgressIndicator();
        },
      ),
    );
  }
}
