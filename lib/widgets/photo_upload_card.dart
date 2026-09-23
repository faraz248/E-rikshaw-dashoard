import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class PhotoUploadCard extends StatefulWidget {
  final String title;
  final String docKey;
  final String? url;
  final bool canUpload;
  final String customerId;

  const PhotoUploadCard(
      {super.key,
      required this.title,
      required this.docKey,
      required this.url,
      required this.canUpload,
      required this.customerId});

  @override
  State<PhotoUploadCard> createState() => _PhotoUploadCardState();
}

class _PhotoUploadCardState extends State<PhotoUploadCard> {
  bool processing = false;

  // TERI IMGBB API KEY YAHAN SET HAI
  final String imgbbApiKey = 'df9cc8a402cdc3b397f324cfc343ebae';

  Future<void> uploadImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile == null) return;

    setState(() => processing = true);

    try {
      final bytes = await pickedFile.readAsBytes();

      // ImgBB API Request
      final uri = Uri.parse('https://api.imgbb.com/1/upload');
      final request = http.MultipartRequest('POST', uri)
        ..fields['key'] = imgbbApiKey
        ..files.add(http.MultipartFile.fromBytes('image', bytes,
            filename: '${widget.docKey}.jpg'));

      final response = await request.send();

      if (response.statusCode == 200) {
        final resData = await response.stream.bytesToString();
        final jsonMap = jsonDecode(resData);
        final downloadUrl =
            jsonMap['data']['url']; // Direct Image URL from ImgBB

        // Firestore database mein URL save kar rahe hain
        await FirebaseFirestore.instance
            .collection('customers')
            .doc(widget.customerId)
            .update({
          'documents.${widget.docKey}': downloadUrl,
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Upload Success!'), backgroundColor: Colors.green));
      } else {
        throw Exception('ImgBB Upload Failed');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => processing = false);
    }
  }

  Future<void> deleteImage() async {
    if (widget.url == null) return;
    setState(() => processing = true);

    try {
      // Database se link delete kar rahe hain (ImgBB free plan me direct delete nahi hota)
      await FirebaseFirestore.instance
          .collection('customers')
          .doc(widget.customerId)
          .update({
        'documents.${widget.docKey}': FieldValue.delete(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Deleted from database'),
          backgroundColor: Colors.orange));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Delete Error: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = widget.url != null && widget.url!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
              image: hasImage
                  ? DecorationImage(
                      image: NetworkImage(widget.url!), fit: BoxFit.cover)
                  : null,
            ),
            child: !hasImage
                ? const Icon(Icons.image_not_supported, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.title,
                    style: const TextStyle(
                        color: Colors.black87, fontWeight: FontWeight.bold)),
                Text(hasImage ? 'Uploaded' : 'Not uploaded',
                    style: TextStyle(
                        color: hasImage ? Colors.green : Colors.orange,
                        fontSize: 12)),
              ],
            ),
          ),
          if (widget.canUpload)
            processing
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.teal))
                : Row(
                    children: [
                      if (hasImage)
                        IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.redAccent),
                            onPressed: deleteImage),
                      if (!hasImage)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12)),
                          onPressed: uploadImage,
                          child: const Text('Upload',
                              style: TextStyle(color: Colors.white)),
                        ),
                    ],
                  ),
        ],
      ),
    );
  }
}
