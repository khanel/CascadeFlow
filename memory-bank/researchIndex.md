### Topic: Linux Speech-to-Text Solutions for Flutter Applications
- Feature / Area: Ingest › Presentation Layer › CaptureQuickAddSheet
- Last Updated: 2025-10-27
- References:
  - Cite this entry in phase notes as "researchIndex.md › Linux Speech-to-Text Solutions for Flutter Applications"

#### RED Guidance
- Summary:
  - Focus tests on verifying that sherpa_onnx integration works on Linux, including model loading, audio recording, and text transcription.
  - Plan for platform-specific initialization and error handling.
- Key Practices:
  - Use widget tests to simulate voice capture button taps and verify transcription results.
  - Test platform detection to ensure sherpa_onnx is used on Linux while speech_to_text remains on supported platforms.
  - Mock audio input for consistent testing across environments.
- Source Index:
  - [sherpa_onnx | Flutter package - Pub.dev](https://pub.dev/packages/sherpa_onnx) — Official package documentation with Linux support and streaming ASR examples.
  - [Voice Control in Flutter: How to Add Local Speech Recognition to Your App](https://medium.com/@khlebobul/voice-control-in-flutter-how-to-add-local-speech-recognition-to-your-app-4bcd96bfd896) — Comprehensive guide on implementing sherpa_onnx for local speech recognition with model setup.
  - [speech_to_text | Flutter package - Pub.dev](https://pub.dev/packages/speech_to_text) — Confirms Linux is not supported (marked with ✘ in platform table).
- Reuse Notes:
  - Revisit when implementing voice features on other platforms or when sherpa_onnx adds new language models.

#### GREEN Guidance
- Summary:
  - Implement sherpa_onnx integration with platform detection to use appropriate speech library per platform.
  - Keep implementation minimal to pass tests, focusing on basic transcription functionality.
- Key Practices:
  - Detect platform using Platform.isLinux to conditionally use sherpa_onnx.
  - Initialize sherpa_onnx with pre-trained English model for streaming recognition.
  - Handle audio recording with record package and feed to sherpa_onnx for transcription.
- Source Index:
  - [sherpa_onnx | Flutter package - Pub.dev](https://pub.dev/packages/sherpa_onnx) — Code examples for OnlineRecognizer setup and audio processing.
  - [Voice Control in Flutter: How to Add Local Speech Recognition to Your App](https://medium.com/@khlebobul/voice-control-in-flutter-how-to-add-local-speech-recognition-to-your-app-4bcd96bfd896) — Step-by-step implementation with model loading and audio stream processing.
  - [record | Flutter package - Pub.dev](https://pub.dev/packages/record) — Audio recording package compatible with sherpa_onnx.
- Reuse Notes:
  - Apply when adding voice input to other text fields or implementing continuous speech recognition.

#### BLUE Guidance
- Summary:
  - Refactor voice capture implementation for better error handling, platform abstraction, and code organization.
  - Ensure consistent behavior across platforms and clean up any platform-specific code.
- Key Practices:
  - Create a platform-agnostic voice capture service interface.
  - Add proper error handling for model loading failures and audio permission issues.
  - Extract voice capture logic into reusable components.
- Source Index:
  - [Effective Dart: Design](https://dart.dev/effective-dart/design) — Guidelines for platform abstraction and service interfaces.
  - [Flutter Platform Detection](https://docs.flutter.dev/platform-integration/platform-adaptations) — Official docs on platform-specific implementations.
  - [Refactoring.Guru](https://refactoring.guru/refactoring/what-is-refactoring) — Principles for improving code structure without changing behavior.
- Reuse Notes:
  - Use during future refactors of voice input features or when adding advanced speech processing.

#### Implementation Notes
- **Platform Detection**: Used `Platform.isLinux` to conditionally initialize sherpa_onnx on Linux platforms.
- **Fallback Logic**: Implemented fallback to speech_to_text when sherpa_onnx initialization fails.
- **Audio Recording**: Integrated `record` package for audio capture with sherpa_onnx workflow.
- **Error Handling**: Added try-catch blocks with graceful fallback to ensure voice capture always works.
- **Testing**: Updated widget tests to verify platform-specific behavior and button state management.
- **Dependencies**: Added `sherpa_onnx` and `record` packages to pubspec.yaml for Linux speech recognition support.
