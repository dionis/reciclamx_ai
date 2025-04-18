import "dart:io";

import "package:flutter/material.dart";
import "package:image_picker/image_picker.dart";
import 'dart:convert';
import 'package:http/http.dart' as http;
import "package:reciclamx_ai/src/repositories/RecyclingWasteAI.dart";

class PickupWastePhoto extends StatefulWidget {
  const PickupWastePhoto({super.key});

  @override
  State<PickupWastePhoto> createState() => _PickupWastePhotoState();
}

class _PickupWastePhotoState extends State<PickupWastePhoto> {
  String pickerGALLERY = 'Pick from Gallery';
  String pickerCAMERA = 'Pick from Camera';
  XFile? photo;
  String serviceResponse = '';
  String webServiceResponse = "Waiting for response...";

  bool sendRequest = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        children: [
          ElevatedButton(
              onPressed: () => _showPicker(context),
              child: const Text("Pick Photo Options")),
          const SizedBox(height: 50),
          ElevatedButton(
              onPressed: () {
                sendRequest = true;
                _imgFromCamera();
              },
              child: Text(pickerCAMERA)),
          ElevatedButton(
              onPressed: () {
                sendRequest = true;
                _imgFromGallery();
              },
              child: Text(pickerGALLERY)),
          const SizedBox(height: 50),
          photo == null
              ? const Icon(Icons.image, size: 100)
              : Image.file(File(photo!.path), width: 100, height: 100),
          const SizedBox(height: 50),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                webServiceResponse,
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    ));
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: Text(pickerGALLERY),
                  onTap: () {
                    _imgFromGallery();
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: Text(pickerCAMERA),
                  onTap: () {
                    _imgFromCamera();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        });
  }

  Future _imgFromCamera() async {
    photo = await ImagePicker().pickImage(source: ImageSource.camera);
    setState(() {
      fetchWebServiceResponse();
    });
  }

  void _imgFromGallery() async {
    photo = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      fetchWebServiceResponse();
    });
  }

  // Example function to simulate web service call
  void fetchWebServiceResponse() async {
    // Simulate a delay for the web service call
    String message = "Web service response not received!";

    if (sendRequest) {
      await Future.delayed(const Duration(seconds: 2));
      sendRequest = !sendRequest;
      message = "Web service response received!";
      message = await RecyclingWasteAI()
          .sendRequest(photo!.path, "Describe this image in detail.");
    }
    // Update the response
    setState(() {
      webServiceResponse = message;
    });
  }

  /**
  //
  //import 'dart:convert';
import 'package:http/http.dart' as http;

void fetchWebServiceResponse() async {
  final url = Uri.parse('https://example.com/api/endpoint'); // Replace with your web service URL

  try {
    // Make the HTTP GET request
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // Parse the response body
      final data = json.decode(response.body);

      // Update the response in the UI
      setState(() {
        webServiceResponse = data.toString(); // Update this to format the data as needed
      });
    } else {
      // Handle non-200 status codes
      setState(() {
        webServiceResponse = 'Error: ${response.statusCode}';
      });
    }
  } catch (e) {
    // Handle errors
    setState(() {
      webServiceResponse = 'Error: $e';
    });
  }
}
  //Explanation:
    http.get: Sends a GET request to the specified URL.
    response.statusCode: Checks the HTTP status code to ensure the request was successful.
    json.decode: Parses the JSON response body into a Dart object.
    Error Handling: Catches exceptions and updates the UI with an error message.
  
  Notes:
    Replace https://example.com/api/endpoint with the actual URL of your web service.
    If your web service requires headers or authentication, you can pass them as a second argument to http.get:

  //
  //
  // */

  //Send Images and Texto to request to web service
  /**
   * 
   * Steps:
      Add the http package to your pubspec.yaml file if not already added:

      Import the http and dart:io packages:

      Use the http.MultipartRequest to send text and image data.
   * 
   * 
   * Example Code:
   * 
   * import 'dart:convert';
        import 'dart:io';
        import 'package:http/http.dart' as http;

        Future<void> sendTextAndImage(String text, File imageFile) async {
          final url = Uri.parse('https://example.com/api/upload'); // Replace with your web service URL

          try {
            // Create a multipart request
            var request = http.MultipartRequest('POST', url);

            // Add text as a field
            request.fields['text'] = text;

            // Add the image as a file
            var imageStream = http.ByteStream(imageFile.openRead());
            var imageLength = await imageFile.length();
            var multipartFile = http.MultipartFile(
              'image', // Field name for the image
              imageStream,
              imageLength,
              filename: imageFile.path.split('/').last,
            );
            request.files.add(multipartFile);

            // Send the request
            var response = await request.send();

            // Handle the response
            if (response.statusCode == 200) {
              var responseBody = await response.stream.bytesToString();
              print('Response: $responseBody');
            } else {
              print('Error: ${response.statusCode}');
            }
          } catch (e) {
            print('Error: $e');
          }
}
   * 
   * Explanation:
      http.MultipartRequest:

      Used to create a POST request with multipart/form-data content type.
      Allows you to send both text and files in the same request.
      request.fields:

      Adds text data to the request.
      http.MultipartFile:

      Represents the image file to be uploaded.
      Uses a ByteStream to read the file and includes its length and filename.
      request.send():

      Sends the request to the server.
      Response Handling:

      Reads the response stream and handles success or error cases.

        Usage:

        Call the sendTextAndImage function with the text and image file:

        File imageFile = File('/path/to/image.jpg'); // Replace with the actual image file path
            String text = "Sample text to send";

              sendTextAndImage(text, imageFile);

      Notes:
          Replace https://example.com/api/upload with your actual web service URL.
          Ensure the server is configured to handle multipart/form-data requests.
          If authentication is required, you can add headers to the request

      request.headers['Authorization'] = 'Bearer YOUR_TOKEN';
      

        
          
   */
}
