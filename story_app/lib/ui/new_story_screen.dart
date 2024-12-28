import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:story_app/provider/story_provider.dart';
import 'package:story_app/ui/picker_screen.dart';
import 'package:story_app/util/colors.dart';

final _formkey = GlobalKey<FormState>();

class NewStoryScreen extends StatefulWidget {
  const NewStoryScreen({super.key});

  @override
  State<NewStoryScreen> createState() => _NewStoryScreenState();
}

class _NewStoryScreenState extends State<NewStoryScreen> {
  final TextEditingController _controllerDesription = TextEditingController();
  PickerResponse? location;

  _locationPicker() async {
    final PickerResponse? result = await context.pushNamed<PickerResponse>('pickerScreen');

    if (result != null) {
      setState(() {
        location = result;
      });
    }
  }

  _onGalleryView() async {
    final provider = Provider.of<NewStoryProvider>(context, listen: false);

    final isMacOS = defaultTargetPlatform == TargetPlatform.macOS;
    final isLinux = defaultTargetPlatform == TargetPlatform.linux;
    if (isMacOS || isLinux) return;

    final ImagePicker picker = ImagePicker();

    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      provider.setImageFile(pickedFile);
      provider.setImagePath(pickedFile.path);
    }
  }

  _onCameraView() async {
    final provider = context.read<NewStoryProvider>();

    final isAndroid = defaultTargetPlatform == TargetPlatform.android;
    final isiOS = defaultTargetPlatform == TargetPlatform.iOS;
    final isNotMobile = !(isAndroid || isiOS);
    if (isNotMobile) return;

    final ImagePicker picker = ImagePicker();

    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.camera,
    );

    if (pickedFile != null) {
      provider.setImageFile(pickedFile);
      provider.setImagePath(pickedFile.path);
    }
  }

  Widget _showImage() {
    final imagePath = context.read<NewStoryProvider>().imagePath;
    return kIsWeb
        ? Image.network(
            imagePath.toString(),
            fit: BoxFit.contain,
          )
        : Image.file(
            File(imagePath.toString()),
            fit: BoxFit.contain,
          );
  }

  _onUpload(
    String description,
  ) async {
    final ScaffoldMessengerState scaffoldMessengerState = ScaffoldMessenger.of(context);
    final provider = context.read<NewStoryProvider>();
    final providerListStory = context.read<ListStoryProvider>();
    final imagePath = provider.imagePath;
    final imageFile = provider.imageFile;
    if (imagePath == null || imageFile == null) {
      scaffoldMessengerState.showSnackBar(
        SnackBar(content: Text('Select Images')),
      );
      return;
    }
    if (location == null) {
      scaffoldMessengerState.showSnackBar(
        SnackBar(content: Text('Select Location')),
      );
      return;
    }

    final fileName = imageFile.name;
    final bytes = await imageFile.readAsBytes();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    await provider.upload(bytes, fileName, description, token, location!.latLng.latitude, location!.latLng.longitude);

    if (provider.response != null) {
      provider.setImageFile(null);
      provider.setImagePath(null);
      if (mounted) {
        providerListStory.pageItems = 1;
        providerListStory.getListStory(token);
      }
    }

    scaffoldMessengerState.showSnackBar(
      SnackBar(content: Text(provider.message)),
    );
    _controllerDesription.clear();
    location = null;
  }

  @override
  void dispose() {
    _controllerDesription.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'New Story',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          onPressed: () => context.goNamed('story'),
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 25,
                ),
                SizedBox(
                  height: 250,
                  child: context.watch<NewStoryProvider>().imagePath == null
                      ? const Align(
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.image,
                            size: 100,
                          ),
                        )
                      : _showImage(),
                ),
                const SizedBox(
                  height: 25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        _onCameraView();
                      },
                      splashColor: secondaryColor.withAlpha(120),
                      borderRadius: BorderRadius.circular(10),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt,
                            size: 30,
                          ),
                          Text(
                            'Camera',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 70,
                    ),
                    InkWell(
                      onTap: () {
                        _onGalleryView();
                      },
                      splashColor: secondaryColor.withAlpha(120),
                      borderRadius: BorderRadius.circular(10),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image,
                            size: 30,
                          ),
                          Text(
                            'Gallery',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 40,
                ),
                Form(
                  key: _formkey,
                  child: TextFormField(
                    controller: _controllerDesription,
                    maxLines: 6,
                    keyboardType: TextInputType.multiline,
                    onTapOutside: (_) => FocusManager.instance.primaryFocus!.unfocus(),
                    decoration: InputDecoration(
                      hintText: 'Description',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter a description for the image';
                      } else {
                        return null;
                      }
                    },
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                location == null
                    ? InkWell(
                        onTap: () {
                          _locationPicker();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text('Location'),
                              ],
                            ),
                            Icon(Icons.navigate_next),
                          ],
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        location!.street,
                                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                                      ),
                                      Text(location!.address),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                location = null;
                              });
                            },
                            child: Icon(Icons.close),
                          ),
                        ],
                      ),
                const SizedBox(
                  height: 15,
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formkey.currentState!.validate()) {
                        _onUpload(_controllerDesription.text);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: context.watch<NewStoryProvider>().isUploading
                        ? const CircularProgressIndicator()
                        : const Text('Upload'),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
