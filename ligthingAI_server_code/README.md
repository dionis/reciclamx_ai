# Gemma3 LitServe

[Gemma 3](https://huggingface.co/collections/google/gemma-3-release-67c6c6f89c4f76621268bb6d), a multimodal Google AI model, processes text and images, offering capabilities like question answering and summarization. Its open weights, large context window, and multiple sizes enable diverse applications and accessibility. This project shows how to create a self-hosted, private API that deploys [Gemma 3 4B](https://huggingface.co/google/gemma-3-4b-it) model variant with LitServe, an easy-to-use, flexible serving engine for AI models built on FastAPI.

## Project Structure

The project is structured as follows:

- `server.py`: The file containing the main code for the web server.
- `client.py`: The file containing the code for client-side requests.
- `README.md`: The README file that contains information about the project.
- `assets`: The folder containing screenshots for working on the application.
- `images`: The folder containing images for testing purposes.
- `.env.example`: The example file for environment variables.

## Tech Stack

- Python (for the programming language)
- PyTorch (for the deep learning framework)
- Hugging Face Transformers Library (for the model)
- LitServe (for the serving engine)

## Getting Started

To get started with this project, follow the steps below:

1. Run the server: `python server.py`
2. Upon running the server successfully, you will see uvicorn running on port 8000.
3. Open a new terminal window.
4. Run the client: `python client.py --image <image_path> --prompt "<prompt>"`.

Now, you can see the model's output based on the input request. The model will respond to the images in the `images` folder based on the questions you ask in all 140 languages the model supports.

**Note**: You need a Hugging Face access token to run the application. You can get the token by signing up on the Hugging Face website and creating a new token from the settings page. After getting the token, you can set it as an environment variable `ACCESS_TOKEN` in your system by creating a `.env` file in the project's root directory. Check the `.env.example` file for reference.

## Usage

The project can be used to serve the Gemma 3 family of models using LitServe. It allows you to input an image and a prompt (can be multilingual) and get the model's output based on the input. The model can be used for various vision-language tasks such as optical character recognition (OCR), captioning, visual reasoning, summarization, question answering, and others.

## License

This project is licensed under the Apache-2.0 License.

## Contact

If you have any questions or suggestions about the project, feel free to contact me on my [GitHub](https://github.com/sitamgithub-MSIT) profile.

Happy coding! 🚀
