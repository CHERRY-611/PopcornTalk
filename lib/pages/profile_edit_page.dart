import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  String? profileImageUrl;
  final nicknameController = TextEditingController();
  final ImagePicker picker = ImagePicker();
  XFile? selectedImage;
  final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    loadUserProfile(); // 유저 정보 불러오기
  }

  Future<void> pickImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImage = image;
      });
    }
  }

  Future<void> loadUserProfile() async {
    final token = await storage.read(key: 'access_token');
    final dio = Dio();

    try {
      final response = await dio.get(
        'http://10.0.2.2:8000/api/me',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );

      final data = response.data;
      setState(() {
        nicknameController.text = data['nickname'] ?? '';
        profileImageUrl = data['profile_image'];
      });
    } catch (e) {
      print('유저 정보 불러오기 실패: $e');
    }
  }

 Future<void> updateProfile() async {
  final token = await storage.read(key: 'access_token');
  final dio = Dio();

  if (nicknameController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('닉네임을 입력해주세요')),
    );
    return;
  }

  FormData formData = FormData.fromMap({
    'nickname': nicknameController.text.trim(),
    if (selectedImage != null)
      'profile_image': await MultipartFile.fromFile(
        selectedImage!.path,
        filename: selectedImage!.name,
      ),
  });

  try {
    final response = await dio.post(
      'http://10.0.2.2:8000/api/update-profile',
      data: formData,
      options: Options(headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'multipart/form-data',
      }),
    );

    final profileResponse = await dio.get(
      'http://10.0.2.2:8000/api/me',
      options: Options(headers: {
        'Authorization': 'Bearer $token',
      }),
    );

    final updatedUrl = profileResponse.data['profile_image']; 

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('프로필이 업데이트되었습니다.')),
    );

    Navigator.pop(context, updatedUrl);

  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('업데이트 실패: $e')),
    );
    }
  }

  Widget buildProfileImage() {
    Widget imageWidget;

    if (selectedImage != null) {
      imageWidget = Image.file(
        File(selectedImage!.path),
        width: 120,
        height: 120,
        fit: BoxFit.cover,
      );
    } else if (profileImageUrl != null) {
      imageWidget = Image.network(
        'http://10.0.2.2:8000$profileImageUrl',
        width: 120,
        height: 120,
        fit: BoxFit.cover,
      );
    } else {
      imageWidget = Image.asset(
        'assets/default_white.png',
        width: 120,
        height: 120,
        fit: BoxFit.cover,
      );
    }

    return Column(
      children: [
        ClipOval(child: imageWidget),
        const SizedBox(height: 8),
        TextButton(
          onPressed: pickImage,
          child: const Text("이미지 선택"),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE66161),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context, profileImageUrl),
        ),
        title: const Text('프로필 설정', style: TextStyle(color: Colors.white, fontSize: 20,)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("닉네임", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            TextField(
              controller: nicknameController,
              decoration: InputDecoration(
                hintText: '닉네임을 입력하세요',
                filled: true,
                fillColor: const Color(0xFFE8EDF4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text("프로필 이미지", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            buildProfileImage(),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: updateProfile,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: const Color(0xFFE66262),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '저장하기',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
