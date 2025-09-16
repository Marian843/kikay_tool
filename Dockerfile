# Use the official TensorFlow image as base
FROM tensorflow/tensorflow:2.13.0

# Set the working directory
WORKDIR /app

# Copy all files to the container
COPY . .

# Set the entry point to run the conversion script
CMD ["python", "convert_models.py"]