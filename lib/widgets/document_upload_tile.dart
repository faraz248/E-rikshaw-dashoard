import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/storage_service.dart';

class DocumentUploadTile extends StatefulWidget {
  final String title;
  final String initialUrl;
  final String storagePath;
  final Function(String url) onUploaded;

  const DocumentUploadTile({
    super.key,
    required this.title,
    required this.initialUrl,
    required this.storagePath,
    required this.onUploaded,
  });

  @override
  State<DocumentUploadTile> createState() => _DocumentUploadTileState();
}

class _DocumentUploadTileState extends State<DocumentUploadTile> {
  final StorageService _storageService = StorageService();
  String? _currentUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.initialUrl.isNotEmpty ? widget.initialUrl : null;
  }

  Future<void> _handleUpload(ImageSource source) async {
    final file = await _storageService.pickImage(source);
    if (file == null) return;

    setState(() => _isUploading = true);
    try {
      final downloadUrl = await _storageService.uploadFile(
        file: file,
        path:
            '${widget.storagePath}_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      setState(() {
        _currentUrl = downloadUrl;
      });
      widget.onUploaded(downloadUrl);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(
            _currentUrl != null ? Icons.check_circle : Icons.upload_file,
            color: _currentUrl != null ? Colors.green : Colors.grey,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.title,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  _currentUrl != null
                      ? 'Document Uploaded'
                      : 'Not attached yet',
                  style: TextStyle(
                      fontSize: 12,
                      color: _currentUrl != null ? Colors.green : Colors.grey),
                ),
              ],
            ),
          ),
          if (_isUploading)
            const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2))
          else
            IconButton(
              icon: const Icon(Icons.camera_alt, color: Colors.blueGrey),
              onPressed: () => _handleUpload(ImageSource.camera),
            ),
        ],
      ),
    );
  }
}
