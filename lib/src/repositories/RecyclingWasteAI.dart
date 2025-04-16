import 'package:dart_openai/dart_openai.dart';
import 'package:dio/dio.dart';
import 'dart:io';

class RecyclingWasteAI {
  // This class is a placeholder for the actual implementation
  // You can add methods and properties as needed

  Future<String> sendRequest(String imagePath, String prompt) async {
    //final dio = Dio();

    // Define the API endpoint and headers
    //const url = 'http://127.0.0.1:8000/v1/chat/completions';

    //Bibliografy
    //https://pub.dev/packages/dart_openai
    //https://lightning.ai/docs/litserve/features/request-response-format
    //
    //https://lightning.ai/docs/litserve/features/full-control
    //
    //
    //https://lightning.ai/docs/litserve/features/open-ai-spec
    //
    //https://huggingface.co/docs/transformers/main/en/pipeline_tutorial

    // const url =
    //     'https://8000-01jrn1kck8v7xj4pqn2bzg3504.cloudspaces.litng.ai/predict';

    // final headers = {
    //   'Authorization': 'Bearer gemma3-litserve', // Replace with your API key
    //   'Content-Type': 'multipart/form-data',
    // };

    try {
      OpenAI.requestsTimeOut = Duration(seconds: 60); // 60 seconds.
      OpenAI.baseUrl =
          "https://8000-01jrn1kck8v7xj4pqn2bzg3504.cloudspaces.litng.ai"; // the default one.
      OpenAI.showLogs = true;
      OpenAI.showResponsesLogs = true;
      OpenAI.apiKey = '';
      // OpenAICompletionModel completion =
      //     await OpenAI.instance.completion.create(
      //   model: "text-davinci-003",
      //   prompt: "Dart is a program",
      //   maxTokens: 20,
      //   temperature: 0.5,
      //   n: 1,
      //   stop: ["\n"],
      //   echo: true,
      //   seed: 42,
      //   bestOf: 2,
      // );

      // the user message that will be sent to the request.
      final userMessage = OpenAIChatCompletionChoiceMessageModel(
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            "Hello, I am a chatbot created by OpenAI. How are you today?",
          ),

          // //! image url contents are allowed only for models with image support such gpt-4.
          // OpenAIChatCompletionChoiceMessageContentItemModel.imageUrl(
          //   "https://placehold.co/600x400",
          // ),
        ],
        role: OpenAIChatMessageRole.user,
      );
      // all messages to be sent.
      final requestMessages = [
        userMessage,
      ];

      OpenAIChatCompletionModel chatCompletion =
          await OpenAI.instance.chat.create(
        model: "gpt-3.5-turbo-1106",
        responseFormat: {"type": "json_object"},
        seed: 6,
        messages: requestMessages,
        temperature: 0.2,
        maxTokens: 500,
      );

      return chatCompletion.choices.first.message.content?.first.text ?? "";
    } catch (e) {
      print('Error: $e');
      throw Exception('Error: $e');
    }
  }

  //   try {
  //     // Prepare the image file
  //     final imageFile = File(imagePath);
  //     final imageName = imageFile.path.split('/').last;

  //     // Create the multipart form data
  //     final formData = FormData.fromMap({
  //       'model': 'google/gemma-3-4b-it',
  //       'messages': [
  //         {
  //           'role': 'user',
  //           'content': [
  //             {'type': 'text', 'text': prompt},
  //             {
  //               'type': 'image_url',
  //               'image_url': {'url': imageName},
  //             },
  //           ],
  //         }
  //       ],
  //       'stream': true,
  //       'max_tokens': 256,
  //       'image': await MultipartFile.fromFile(imagePath, filename: imageName),
  //     });

  //     // Send the POST request
  //     final response = await dio.post(
  //       url,
  //       data: formData,
  //       options: Options(headers: headers),
  //     );

  //     // Handle the response
  //     if (response.statusCode == 200) {
  //       print('Response: ${response.data}');
  //       return response.data;
  //     } else {
  //       print('Error: ${response.statusCode} - ${response.statusMessage}');
  //       throw Exception(
  //           'Error: ${response.statusCode} - ${response.statusMessage}');
  //     }
  //   } catch (e) {
  //     print('Error: $e');
  //     throw Exception('Error: $e');
  //   }
  // }

  // void main() async {
  //   String imagePath =
  //       '/path/to/image.jpg'; // Replace with the actual image path
  //   String prompt = 'Describe this image in detail.';

  //   await sendRequest(imagePath, prompt);
  // }
}
