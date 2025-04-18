# Necessary imports
import os
from dotenv import load_dotenv
from PIL import Image
import base64, io
from threading import Thread
import torch
from transformers import (
    AutoProcessor,
    Gemma3ForConditionalGeneration,
    TextIteratorStreamer,
    AutoTokenizer, 
    AutoModelForCausalLM
)

from transformers.image_utils import load_image
# import litserve as ls
from litserve.specs.openai import ChatCompletionRequest
# import logging
# from transformers import pipeline


from transformers import pipeline
import litserve as ls


# Load the Environment Variables from .env file
load_dotenv()

# Access token for using the model
access_token = os.environ.get("ACCESS_TOKEN")

print(f"HF ACCES TOKEN AS: {access_token}")


class Gemma3API(ls.LitAPI):
    """
    Gemma3API is a subclass of ls.LitAPI that provides methods for the Gemma 3 multimodal model for vision-language understanding.

    Methods:
        - setup(device): Called once at startup for the task-specific setup.
        - decode_request(request): Convert the request payload to model input.
        - predict(model_inputs): Uses the model to generate a response for the given input.
    """

    def setup(self, device):
        """
        Sets up the model, processor and a text streamer for the Gemma 3 model.
        """
        model_id = "google/gemma-3-4b-it"
        self.device = device
        self.processor = AutoProcessor.from_pretrained(
            model_id, 
            token= access_token
        )
        self.model = (
            Gemma3ForConditionalGeneration.from_pretrained(
                model_id,
                torch_dtype=torch.bfloat16,
                token=access_token,
            )
            .eval()
            .to(self.device)
        )
        self.streamer = TextIteratorStreamer(
            self.processor.tokenizer,
            skip_prompt=True,
            skip_special_tokens=True,
            clean_up_tokenization_spaces=False,
        )

    def decode_request(self, request: ChatCompletionRequest, context: dict):
        """
        Convert the request payload to model input.
        """

        # Set the generation arguments from the request
        context["generation_args"] = {
            "max_new_tokens": request.max_tokens if request.max_tokens else 300,
        }
        
        # Extract the messages from the request
        messages = []
        for message in request.messages:
            msg_dict = message.model_dump(exclude_none=True)
            if isinstance(msg_dict.get("content"), list):
                msg_dict["content"] = [
                    (
                        {
                            "type": "image",
                            "image": Image.open(io.BytesIO(base64.b64decode(item["image_url"])))          
                        }
                        if item.get("type") == "image_url" and "image_url" in item
                        else item
                    )
                    for item in msg_dict["content"]
                ]
            messages.append(msg_dict)

        # Convert the messages to model input
        return self.processor.apply_chat_template(
            messages,
            add_generation_prompt=True,
            tokenize=True,
            return_dict=True,
            return_tensors="pt",
        ).to(self.model.device, dtype=torch.bfloat16)

    def save_decode_request(self, request: ChatCompletionRequest, context: dict):
        """
        Convert the request payload to model input.
        """

        # Set the generation arguments from the request
        context["generation_args"] = {
            "max_new_tokens": request.max_tokens if request.max_tokens else 300,
        }
        
        # Extract the messages from the request
        messages = []
        for message in request.messages:
            msg_dict = message.model_dump(exclude_none=True)
            if isinstance(msg_dict.get("content"), list):
                msg_dict["content"] = [
                    (
                        {
                            "type": "image",
                            "image": load_image(item["image_url"]["url"]),
                        }
                        if item.get("type") == "image_url" and "image_url" in item
                        else item
                    )
                    for item in msg_dict["content"]
                ]
            messages.append(msg_dict)

        # Convert the messages to model input
        return self.processor.apply_chat_template(
            messages,
            add_generation_prompt=True,
            tokenize=True,
            return_dict=True,
            return_tensors="pt",
        ).to(self.model.device, dtype=torch.bfloat16)

    def predict(self, model_inputs, context: dict):
        """
        Run inference and stream the model output.
        """
        # Generation arguments for the model
        generation_kwargs = dict(
            model_inputs,
            streamer=self.streamer,
            eos_token_id=self.processor.tokenizer.eos_token_id,
            do_sample=False,
            **context["generation_args"],
        )

        # Generate the response in a separate thread
        thread = Thread(target=self.model.generate, kwargs=generation_kwargs)
        thread.start()

        # Stream the response
        for text in self.streamer:
            yield text


if __name__ == "__main__":
    # Create an instance of the Gemma3API class and run the server
    # configure logging at the root level of Lightning
    
    api = Gemma3API()
    server = ls.LitServer(api, spec=ls.OpenAISpec())
    server.run(port=8000)


# import litserve as ls

# class TextAPI(ls.LitAPI):
#     def setup(self, device):
#         self.model = lambda x: len(x)

#     def decode_request(self, request):
#         return request["text_input"]

#     def predict(self, x):
#         return self.model(x)

#     def encode_response(self, output):
#         return {"output": output} 

# if __name__ == "__main__":
#     api = TextAPI()
#     server = ls.LitServer(api)
#     server.run(port=8000)


# from PIL import Image
# import litserve as ls

# class ImageAPI(ls.LitAPI):
#     def setup(self, device):
#         self.model = lambda x: x.size  # Define a dummy model to return image size

#     def decode_request(self, request):
#         # Access additional JSON data sent in the request
#         print(request["model_name"])
        
#         # Open and return the uploaded image file
#         print(request["request"])
        
#         #return ({'size':3445})
        
#         #return request["request"]
        
#         return Image.open(request["request"].file)

#     def predict(self, x):
#         return self.model(x)

#     def encode_response(self, output):
#         return {"output": output}

# if __name__ == "__main__":
#     api = ImageAPI()
#     server = ls.LitServer(api)
#     server.run(port=8000) 


# class GPT2LitAPI(ls.LitAPI):
#     def setup(self, device):
#         #tokenizer = AutoTokenizer.from_pretrained("openai-community/gpt2")
#         #self.tokenizer = AutoTokenizer.from_pretrained("google/gemma-2-2b")
#         #self.generator = pipeline('text-generation', model='openai-community/gpt2', device=device, tokenizer = tokenizer)
#         self.generator = pipeline(task="text-generation", model="google/gemma-2-2b-it", device="cuda",  token = access_token)
        

#     def predict(self, prompt, context):
#         # temperature is retrieved from the context
#         temperature = context["temperature"]
#         #prompt_messages = self.tokenizer.apply_chat_template(prompt, tokenize=False, add_generation_prompt=True)
#         out = self.generator(prompt, do_sample=False, temperature = temperature, max_new_tokens=256)
#         result = out[0]['generated_text']
#         yield result

# if __name__ == '__main__':
#     api = GPT2LitAPI()
#     server = ls.LitServer(api, spec=ls.OpenAISpec())
#     server.run(port=8000)