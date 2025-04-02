# Cryptor
Cryptor is a simple Flutter application that provides text encryption and decryption. It utilizes AES-256 encryption along with GZip compression, allowing users to encrypt messages with a user-supplied (or auto-generated) key and initialization vector (IV), and decrypt ciphertext back to the original message.

# Features
Text Encryption: Convert plain text into a Base64-encoded encrypted string.

Text Decryption: Revert the encrypted text back to the original plain text using the provided key and IV.

Automatic Key/IV Generation: If no key or IV is provided, the app automatically generates secure random values.

GZip Compression: Compresses the input before encryption to enhance data handling.

# Requirements
Flutter SDK installed.

Dart SDK (included with Flutter).

Dependencies defined in pubspec.yaml, including the encrypt package.

# Installation
Clone the Repository

flutter pub get

# Usage
Run the Application:

flutter run

## Encrypting Text:

Enter the plain text you want to encrypt in the text field.

(Optional) Provide a Base64-encoded key and IV. If left blank, these will be auto-generated.

Tap the Encrypt button. The encrypted text, along with the key and IV, will be displayed.

## Decrypting Text:

Enter the encrypted Base64 string, key, and IV in the respective fields.

Tap the Decrypt button to retrieve the original text.

If any field is missing or incorrect, the app will display an error message.

# Code Structure
main.dart: Contains the entire application code:

Basepage: The root widget which sets up the Material app.

Home: A stateful widget managing the UI with text input fields and buttons.

Cryptor: A helper class encapsulating encryption and decryption logic using the encrypt package and GZip compression.

Contributing
Contributions and suggestions are welcome. Please feel free to open issues or pull requests to improve Cryptor.

License
This project is licensed under the MIT License.