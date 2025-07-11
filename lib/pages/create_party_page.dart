import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';
class CreatePartyPage extends StatefulWidget {
  const CreatePartyPage({super.key});

  @override
  State<CreatePartyPage> createState() => _CreatePartyPageState();
}

class _CreatePartyPageState extends State<CreatePartyPage> {
  final nameController = TextEditingController();
  final oneLinerController = TextEditingController();
  final categoryController = TextEditingController();

  final ImagePicker picker = ImagePicker();
  XFile? selectedImage;
  final storage = FlutterSecureStorage();

  Future<void> pickImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImage = image;
      });
    }
  }

  Future<void> createParty() async {
    if (selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미지를 선택해주세요')),
      );
      return;
    }

    final token = await storage.read(key: 'access_token');
    final dio = Dio();

    FormData formData = FormData.fromMap({
      'name': nameController.text.trim(),
      'one_liner': oneLinerController.text.trim(),
      'category': categoryController.text.trim(),
      'image': await MultipartFile.fromFile(
        selectedImage!.path,
        filename: selectedImage!.name,
      ),
    });

    try {
      await dio.post(
        'http://10.0.2.2:8000/api/upload-party',
        data: formData,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'multipart/form-data',
        }),
      );
      print("저장된 토큰: $token");
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('파티 생성 실패: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9F9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context,true),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LabelledInputField(label: '파티 이름', controller: nameController),
            _LabelledInputField(label: '한줄 소개', controller: oneLinerController),
            _LabelledInputField(label: '카테고리', controller: categoryController),

            const SizedBox(height: 16),
            const Text("이미지 업로드", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            selectedImage == null
                ? OutlinedButton(
                    onPressed: pickImage,
                    child: const Text("이미지 선택"),
                  )
                : Column(
                    children: [
                      AspectRatio(
                        aspectRatio: 2 / 3,
                        child: Image.file(
                          File(selectedImage!.path),
                          fit: BoxFit.cover,
                        ),
                      ),
                      TextButton(onPressed: pickImage, child: const Text("다시 선택")),
                    ],
                  ),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: createParty,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: const Color(0xFFE66262),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Create', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

class _LabelledInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const _LabelledInputField({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFE8EDF4),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }
}
