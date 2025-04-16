import 'package:dio/dio.dart';
import 'dart:io';

class RecyclingWasteAI {
  // This class is a placeholder for the actual implementation
  // You can add methods and properties as needed

  Future<void> sendRequest(String imagePath, String prompt) async {
    final dio = Dio();

    // Define the API endpoint and headers
    const url = 'http://127.0.0.1:8000/v1/chat/completions';
    final headers = {
      'Authorization': 'Bearer gemma3-litserve', // Replace with your API key
      'Content-Type': 'multipart/form-data',
    };

    try {
      // Prepare the image file
      final imageFile = File(imagePath);
      final imageName = imageFile.path.split('/').last;

      // Create the multipart form data
      final formData = FormData.fromMap({
        'model': 'google/gemma-3-4b-it',
        'messages': [
          {
            'role': 'user',
            'content': [
              {'type': 'text', 'text': prompt},
              {
                'type': 'image_url',
                'image_url': {'url': imageName},
              },
            ],
          }
        ],
        'stream': true,
        'max_tokens': 256,
        'image': await MultipartFile.fromFile(imagePath, filename: imageName),
      });

      // Send the POST request
      final response = await dio.post(
        url,
        data: formData,
        options: Options(headers: headers),
      );

      // Handle the response
      if (response.statusCode == 200) {
        print('Response: ${response.data}');
      } else {
        print('Error: ${response.statusCode} - ${response.statusMessage}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // void main() async {
  //   String imagePath =
  //       '/path/to/image.jpg'; // Replace with the actual image path
  //   String prompt = 'Describe this image in detail.';

  //   await sendRequest(imagePath, prompt);
  // }
}
