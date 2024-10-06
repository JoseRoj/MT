import 'dart:convert';
import 'dart:typed_data';

import 'package:clubconnect/helpers/transformation.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

class ImagePickerWidget extends StatefulWidget {
  File? initialImage; // Imagen inicial (puede ser null)
  String imageBase64;
  Uint8List? memoryImage;
  bool? readOnly;

  final void Function(File?, String)
      onImageSelected; // Callback para cuando se selecciona una imagen

  ImagePickerWidget({
    Key? key,
    required this.initialImage,
    this.memoryImage,
    required this.imageBase64,
    required this.onImageSelected,
    this.readOnly,
  }) : super(key: key);

  @override
  ImagePickerWidgetState createState() => ImagePickerWidgetState();
}

class ImagePickerWidgetState extends State<ImagePickerWidget> {
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Asigna la imagen inicial si está disponible
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      widget.initialImage = File(pickedFile.path);
      widget.imageBase64 = await toBase64C(pickedFile.path);
    }
    widget.onImageSelected(widget.initialImage, widget.imageBase64);
  }

  Future<void> _pickImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      widget.initialImage = File(pickedFile.path);
      widget.imageBase64 = await toBase64C(pickedFile.path);
    }
    widget.onImageSelected(widget.initialImage, widget.imageBase64);
  }

  void deleteImage() {
    widget.onImageSelected(null, "");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipOval(
          child: InkWell(
            child: widget.imageBase64 == null || widget.imageBase64 == ""
                ? ClipOval(
                    child: Container(
                      color: Colors.black54,
                      width: 100,
                      height: 100,
                      child: const Icon(
                        Icons.photo,
                        size: 25,
                        color: Colors.white,
                      ),
                    ),
                  )
                : widget.memoryImage == null
                    ? ClipOval(
                        child: Image.file(
                          widget.initialImage!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.memory(
                        widget.memoryImage!,
                        fit: BoxFit.cover,
                        width: 100,
                        height: 100,
                      ),
          ),
        ),
        widget.readOnly == true
            ? SizedBox.shrink()
            : TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Selecciona una imagen'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ListTile(
                              leading: const Icon(Icons.photo),
                              title: const Text('Galería'),
                              onTap: () async {
                                await _pickImageFromGallery();
                                Navigator.of(context)
                                    .pop(); // Cierra el diálogo
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.camera),
                              title: const Text('Cámara'),
                              onTap: () async {
                                await _pickImageFromCamera();
                                Navigator.of(context)
                                    .pop(); // Cierra el diálogo
                              },
                            ),
                            (widget.initialImage != null ||
                                    widget.memoryImage != null)
                                ? ListTile(
                                    leading: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    title: const Text(
                                      'Eliminar Foto',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    onTap: () {
                                      deleteImage();
                                      Navigator.of(context)
                                          .pop(); // Cierra el diálogo
                                    },
                                  )
                                : const SizedBox.shrink(),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Text(
                  widget.imageBase64 != null ? "Editar" : "Agregar",
                  style: TextStyle(fontSize: 14),
                ))
        /*GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Selecciona una imagen'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        leading: const Icon(Icons.photo),
                        title: const Text('Galería'),
                        onTap: () async {
                          await _pickImageFromGallery();
                          Navigator.of(context).pop(); // Cierra el diálogo
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.camera),
                        title: const Text('Cámara'),
                        onTap: () async {
                          await _pickImageFromCamera();
                          Navigator.of(context).pop(); // Cierra el diálogo
                        },
                      ),
                      widget.initialImage != null
                          ? ListTile(
                              leading: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              title: const Text(
                                'Eliminar Foto',
                                style: TextStyle(color: Colors.red),
                              ),
                              onTap: () {
                                deleteImage();
                                Navigator.of(context)
                                    .pop(); // Cierra el diálogo
                              },
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
                );
              },
            );
          },
        ),*/
      ],
    );
  }
}
