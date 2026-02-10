# Rise Mobile App

## Overview
Rise Mobile App is a Flutter application designed to scan and extract data from receipts using Optical Character Recognition (OCR). The app provides a user-friendly interface for capturing receipt images and retrieving essential information such as the amount, merchant name, and date.

## Project Structure
The project is organized into the following directories and files:

- **android/**: Contains Android-specific configuration and code.
- **ios/**: Contains iOS-specific configuration and code.
- **lib/**: The main directory for the Flutter application code.
  - **main.dart**: Entry point of the application.
  - **src/**: Contains the source code for the application.
    - **app.dart**: Main application widget with routing and theme setup.
    - **models/**: Contains data models.
      - **receipt_data.dart**: Defines the `ReceiptData` class for receipt information.
    - **services/**: Contains service classes for business logic.
      - **ocr_service.dart**: Provides methods for scanning receipts and extracting data.
    - **screens/**: Contains the UI screens of the application.
      - **home_screen.dart**: Main screen of the application.
      - **receipt_scan_screen.dart**: Screen for scanning receipts.
    - **widgets/**: Contains reusable widgets.
      - **common_widgets.dart**: Common widgets used throughout the app.
- **test/**: Contains test files for the application.
  - **widget_test.dart**: Widget tests to ensure UI functionality.
- **pubspec.yaml**: Configuration file for dependencies and assets.
- **analysis_options.yaml**: Configuration for Dart analyzer settings.
- **.gitignore**: Specifies files to be ignored by version control.
- **README.md**: Documentation for the project.

## Setup Instructions
1. Clone the repository:
   ```
   git clone <repository-url>
   ```
2. Navigate to the project directory:
   ```
   cd rise_mobile_app
   ```
3. Install dependencies:
   ```
   flutter pub get
   ```
4. Run the application:
   ```
   flutter run
   ```

## Usage
- Open the app and navigate to the receipt scan screen.
- Capture a photo of the receipt.
- The app will process the image and display the extracted information.

## Contributing
Contributions are welcome! Please submit a pull request or open an issue for any enhancements or bug fixes.

## License
This project is licensed under the MIT License. See the LICENSE file for details.