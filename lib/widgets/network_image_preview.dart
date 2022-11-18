import 'package:flutter/material.dart';

class NetworkImagePreview extends StatefulWidget
{
  final String previewImage, actualImage;

  const NetworkImagePreview({Key? key, required this.previewImage, required this.actualImage}) : super(key: key);

  @override
  State<NetworkImagePreview> createState() => _NetworkImagePreviewCardState();
}

class _NetworkImagePreviewCardState extends State<NetworkImagePreview> 
{
  @override
  Widget build(BuildContext context) 
  {
    //Want to use this instead at some point
    return InkWell(
        child: Image(
          image:NetworkImage(widget.previewImage),
        )
    );
  }

}