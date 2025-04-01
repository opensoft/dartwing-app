import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:mime/mime.dart';

import 'dart_wing/gui/dialogs.dart';
import 'dart_wing/gui/notification.dart';
import 'dart_wing/gui/widgets/base_scaffold.dart';
import 'dart_wing/network/network_clients.dart';

class DocumentPickerPage extends StatefulWidget {
  const DocumentPickerPage({super.key});

  final String? title = "Document Picker";

  @override
  State<DocumentPickerPage> createState() => _DocumentPickerPageState();
}

class _DocumentPickerPageState extends State<DocumentPickerPage> {
  bool _loadingOverlayEnabled = false;
  List<XFile> _mediaFileList = [];
  final int _imagesLimit = 5;
  static const String _emptyFilesText =
      'You have not yet picked an image or a document';

  void _uploadFiles() {
    setState(() {
      _loadingOverlayEnabled = true;
    });
    List<Future> futures = [];
    for (var file in _mediaFileList) {
      futures.add(file.readAsBytes().then((bytes) {
        return NetworkClients.dartWingApi
            .uploadFile("Company1", bytes, filename: file.name);
      }));
    }
    Future.wait(futures).then((value) {
      setState(() {
        _loadingOverlayEnabled = false;
      });
      showInfoNotification(context, "Uploaded successfully");
      //Navigator.of(context).popAndPushNamed(DartWingAppsRouters.documentsListPage);
    }).catchError((e) {
      showWarningNotification(context, e.toString());
      setState(() {
        _loadingOverlayEnabled = false;
      });
    });
  }

  void _setFilesToMediaList(List<XFile?> files) {
    if (files.isEmpty) {
      return;
    }

    List<XFile> mediaFileList = [];
    for (var file in files) {
      if (file != null) {
        mediaFileList.add(file);
      }
    }
    if (mediaFileList.isNotEmpty) {
      setState(() {
        _mediaFileList = mediaFileList;
      });
      _uploadFilesDialog();
    }
  }

  void _uploadFilesDialog() {
    Dialogs.showInfoDialog(
            context,
            "doYouWantToUploadFile ${_mediaFileList.map((file) {
              return file.name;
            }).join(', ')}",
            titleText: "Upload",
            okButtonText: "Upload",
            cancelButtonText: "Cancel")
        .then((result) {
      if (result != null) {
        _uploadFiles();
      }
    });
  }

  dynamic _pickImageError;
  String? _retrieveDataError;

  final ImagePicker _picker = ImagePicker();

  Future<void> _onImageButtonPressed(
    ImageSource source, {
    required BuildContext context,
    bool isMultiImage = false,
    bool isMedia = false,
  }) async {
    if (context.mounted) {
      if (isMultiImage) {
        try {
          final List<XFile> pickedFileList = isMedia
              ? await _picker.pickMultipleMedia(
                  limit: _imagesLimit,
                )
              : await _picker.pickMultiImage(
                  limit: _imagesLimit,
                );
          _setFilesToMediaList(pickedFileList);
        } catch (e) {
          setState(() {
            _pickImageError = e;
          });
        }
      } else if (isMedia) {
        try {
          final XFile? media = await _picker.pickMedia(
            imageQuality: _imagesLimit,
          );
          _setFilesToMediaList([media]);
        } catch (e) {
          setState(() {
            _pickImageError = e;
          });
        }
      } else {
        try {
          final XFile? pickedFile = await _picker.pickImage(
            source: source,
          );
          _setFilesToMediaList([pickedFile]);
        } catch (e) {
          setState(() {
            _pickImageError = e;
          });
        }
      }
    }
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  Widget _previewImages() {
    final Text? retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_mediaFileList.isNotEmpty) {
      return Column(children: [
        Expanded(
            child: Semantics(
          label: 'image_picker_example_picked_images',
          child: ListView.builder(
            key: UniqueKey(),
            itemBuilder: (BuildContext context, int index) {
              final String? mime = lookupMimeType(_mediaFileList[index].path);

              // Why network for web?
              // See https://pub.dev/packages/image_picker_for_web#limitations-on-the-web-platform
              return Semantics(
                label: 'image_picker_example_picked_image',
                child: kIsWeb
                    ? Image.network(_mediaFileList[index].path)
                    : Image.file(
                        File(_mediaFileList[index].path),
                        errorBuilder: (BuildContext context, Object error,
                            StackTrace? stackTrace) {
                          return const Center(
                              child: Text('This image type is not supported',
                                  style: TextStyle(color: Colors.white)));
                        },
                      ),
              );
            },
            itemCount: _mediaFileList.length,
          ),
        )),
      ]);
    } else if (_pickImageError != null) {
      return Text(
        'Pick image error: $_pickImageError',
        textAlign: TextAlign.center,
      );
    } else {
      return const Text(
        _emptyFilesText,
        style: TextStyle(color: Colors.white),
        textAlign: TextAlign.center,
      );
    }
  }

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await _picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        if (response.files == null) {
          _setFilesToMediaList([response.file]);
        } else {
          _setFilesToMediaList(response.files!);
        }
      });
    } else {
      _retrieveDataError = response.exception!.code;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      loadingOverlayEnabled: _loadingOverlayEnabled,
      appBar: null,
      body: Center(
        child: !kIsWeb && defaultTargetPlatform == TargetPlatform.android
            ? FutureBuilder<void>(
                future: retrieveLostData(),
                builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return const Text(_emptyFilesText,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white));
                    case ConnectionState.done:
                      return _previewImages();
                    case ConnectionState.active:
                      if (snapshot.hasError) {
                        return Text(
                          'Pick image/video error: ${snapshot.error}}',
                          textAlign: TextAlign.center,
                        );
                      } else {
                        return const Text(
                          _emptyFilesText,
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        );
                      }
                  }
                },
              )
            : _previewImages(),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Semantics(
            label: 'image_picker_example_from_gallery',
            child: FloatingActionButton(
              onPressed: () {
                _onImageButtonPressed(ImageSource.gallery,
                    context: context, isMultiImage: true);
              },
              heroTag: 'image0',
              tooltip: 'Pick images from gallery',
              child: const Icon(Icons.photo),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: FloatingActionButton(
              onPressed: () {
                _onImageButtonPressed(ImageSource.gallery,
                    context: context, isMedia: true, isMultiImage: true);
              },
              heroTag: 'image1',
              tooltip: 'Pick files from gallery',
              child: const Icon(Icons.file_open),
            ),
          ),
          if (_picker.supportsImageSource(ImageSource.camera))
            Visibility(
                visible: !kIsWeb,
                child: Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: FloatingActionButton(
                    backgroundColor: Colors.red,
                    onPressed: () {
                      _onImageButtonPressed(ImageSource.camera,
                          context: context);
                    },
                    heroTag: 'image2',
                    tooltip: 'Take a Photo',
                    child: const Icon(Icons.camera_alt),
                  ),
                )),
          Visibility(
              visible: _mediaFileList.isNotEmpty,
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: FloatingActionButton(
                  onPressed: () {
                    _uploadFilesDialog();
                  },
                  heroTag: 'upload',
                  tooltip: 'Upload file',
                  child: const Icon(Icons.upload),
                ),
              )),
        ],
      ),
    );
  }

  Text? _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError!);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }
}

typedef OnPickImageCallback = void Function(
    double? maxWidth, double? maxHeight, int? quality, int? limit);
