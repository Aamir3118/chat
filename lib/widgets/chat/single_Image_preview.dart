import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class SingleImagePreview extends StatefulWidget {
  var imagePreview;
  String formattedDateTime;
  SingleImagePreview(this.imagePreview, this.formattedDateTime);

  @override
  State<SingleImagePreview> createState() => _SingleImagePreviewState();
}

class _SingleImagePreviewState extends State<SingleImagePreview> {
  bool _showAppBar = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _showAppBar
          ? AppBar(
              leadingWidth: 25,
              title: Text(widget.formattedDateTime),
              iconTheme: IconThemeData(color: Colors.white),
              backgroundColor: _showAppBar
                  ? Colors.black.withOpacity(0.3)
                  : Colors.transparent,
              elevation: 0,
            )
          : null,
      body: GestureDetector(
        onTap: () {
          setState(() {
            _showAppBar = !_showAppBar;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Container(
              width: double.infinity,
              height: double.infinity,
              child: PhotoView(
                imageProvider: NetworkImage(
                  widget.imagePreview,
                ),
              )
              //Image(
              //  image: NetworkImage(widget.imagePreview), fit: BoxFit.cover),
              ),
        ),
      ),
    );
  }
}
