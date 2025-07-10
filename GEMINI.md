# GEMINI.md: Project Guidelines for AI Assistants

This document provides essential guidelines and context for AI assistants (like Gemini) working on this Flutter project. It aims to ensure consistent development practices, high code quality, and efficient collaboration.

# Project Overview

This is a Flutter project for a custom launcher application designed to offer a highly personalized, efficient, and feature-rich experience for managing and launching applications. Its primary goal is to provide a superior alternative to existing launcher solutions by focusing on enhanced user experience, extensive customization, and robust functionality. Key features likely include:

- **Comprehensive Application Management**: Efficiently listing, organizing, categorizing, and managing installed applications with advanced search and filtering capabilities.
- **Extensive Customization and Theming**: Allowing users to arrange applications and widgets with highly customizable layouts, themes, and visual personalization options.
- **Optimized Quick Launch**: Providing fast and intuitive access to frequently used applications and custom shortcuts.
- **Seamless System Integration**: Deep interaction with underlying operating system services, including system tray management, window control, and native notifications.
- **Performance and Responsiveness**: Engineered for fast launch times, low resource consumption, and a fluid user interface across all supported platforms.
- **Cross-Platform Consistency**: Delivering a unified and consistent user experience across Windows, macOS, Linux, Android, and iOS.
- **Extensibility (Future)**: Designed with an architecture that supports future expansion through plugins or extensions for additional functionalities.

# Technology Stack

- **Framework**: Flutter (Dart)
- **State Management**: Riverpod is currently being considered. (Analyze `lib/features` for existing patterns if any.)
- **Platform-Specific Features**: Utilizes Flutter's platform channels for deep integration with Windows, macOS, Linux, Android, and iOS.

# Code Style/Conventions

- Follow standard Dart/Flutter conventions as outlined in the [Dart Style Guide](https://dart.dev/guides/language/effective-dart), including Flutter's recommended formatting settings.
- Ensure code quality and adherence to standards by regularly running `dart analyze`.
- Analyze existing code within `lib/` for specific formatting, naming patterns, and architectural principles (e.g., Clean Architecture, MVVM, etc.).
- **Directory Structure**:
  - `lib/core/`: Contains core services, utilities, and infrastructure components (e.g., `system_tray_service.dart`, `window_service.dart`). These are generally cross-cutting concerns.
  - `lib/features/`: Organized by distinct application features. Each feature (e.g., `launcher`) typically follows a layered structure:
    - `data/`: Data sources, repositories, and models for data persistence/retrieval.
    - `domain/`: Business logic, entities, use cases, and interfaces.
    - `presentation/`: UI components, widgets, and view models/controllers.

# Development Principles

- **Thorough Understanding**: Before starting any task, ensure a complete and detailed understanding of the requirements. Ambiguities will be clarified through direct questions.
- **Clear Direction**: A clear plan for the task will be established and communicated, outlining the steps to be taken.
- **High-Quality Code**: All code will be written with a focus on:
  - **Stability**: Robust and bug-free.
  - **Scalability**: Designed to accommodate future growth and changes.
  - **Readability**: Easy to understand and maintain.
- **Convention Adherence**: Strict adherence to existing project code conventions, style guides, and architectural patterns (including formatting, naming conventions, and structural choices).
- **Modern Practices**: Avoid deprecated code and ensure compatibility with current dependencies and best practices.
- **Dependency Management**: When considering new packages:
  - Prioritize using existing functionalities within the project or Flutter SDK.
  - Prefer official Flutter/Dart packages where applicable.
  - Avoid unnecessarily large or complex libraries if a simpler alternative exists.
  - Always evaluate the package's maintenance status, community support, and potential impact on performance and build size.

# Testing

- **Unit Tests**: For individual functions, classes, and business logic.
- **Widget Tests**: For testing UI components in isolation.
- **Integration Tests**: For testing entire flows or interactions between multiple components.
- **Command**: To run all tests, use `flutter test`.

# Building/Running

- **Run Development Build**: `flutter run`
- **Build for Specific Platform**: `flutter build <platform>` (e.g., `flutter build windows`, `flutter build android`, `flutter build web`).
- **Clean Project**: `flutter clean` (useful for resolving build issues).
- **Get Dependencies**: `flutter pub get` (automatically run on `flutter run` or `flutter build` but good to know).

# Important Files/Directories

- `lib/`: Main application source code, organized by core services and features.
- `assets/`: Application assets.
  - `assets/config/`: Configuration files (e.g., `app_assets.json`, `app_settings.json`, `layout_config.json`).
  - `assets/icons/`: Application icons and images used within the UI.
  - `assets/images/`: Larger images or background assets.
- `pubspec.yaml`: Project dependencies, metadata, and asset declarations.
- `pubspec.lock`: Records the specific versions of dependencies used.
- `android/`, `ios/`, `linux/`, `macos/`, `windows/`, `web/`: Platform-specific project files and configurations. Changes here are typically only needed for platform-specific integrations or build settings.
- `.github/`: Contains GitHub Actions workflows or other repository-specific configurations.
- `.vscode/`: VS Code specific settings and configurations.

# AI Assistant Usage Guidelines

When utilizing AI assistants like Gemini or Copilot, adhere to the following guidelines to maximize efficiency, maintain code quality, and ensure security:

1. **Understand Before Accepting**: Always review and understand the AI-generated code before accepting it. Do not blindly paste code without comprehending its functionality, potential side effects, and adherence to project conventions.
2. **Verify for Correctness and Security**: AI models can sometimes generate incorrect, inefficient, or insecure code.
    - **Correctness**: Manually verify the logic and ensure it solves the problem accurately.
    - **Security**: Be vigilant for potential security vulnerabilities (e.g., injection flaws, improper error handling, exposed sensitive data). Never commit sensitive information (API keys, passwords) even if generated by an AI.
3. **Adhere to Project Conventions**: Ensure AI-generated code strictly follows the project's established code style, naming conventions, architectural patterns, and existing dependencies. Adjust as necessary.
4. **Refactor and Integrate**: Treat AI-generated code as a starting point. Integrate it seamlessly into the existing codebase, refactor for clarity, and ensure it aligns with the overall design.
5. **Test Thoroughly**: AI-generated code is not exempt from testing. Write or ensure existing tests cover the functionality provided by AI-generated code.
6. **Avoid Over-Reliance**: Use AI as a productivity tool, not a replacement for critical thinking or problem-solving. Develop a strong understanding of the underlying concepts.
7. **Privacy and Confidentiality**: Be cautious when providing proprietary or sensitive project information to public AI models. Understand the privacy policies of the AI tools you are using. Avoid pasting confidential code snippets into general-purpose AI chat interfaces.
8. **Context is Key**: Provide clear and concise prompts to the AI, including relevant context (e.g., surrounding code, desired output format, specific libraries to use).
9. **Action Completion Check**: After any code or configuration change, always run `flutter analyze` before considering the task complete. If any errors or warnings are reported, they must be fixed before the action is finalized and merged.

# Future Enhancements / Roadmap

The project aims for continuous improvement in user freedom and ease of use. Key future directions include:

- **GUI-based UI Configuration**: Transitioning from direct JSON modification to a graphical user interface (GUI) for UI composition. This will enable users to easily design and arrange layouts through intuitive drag-and-drop operations.
- **Dynamic Widget Declaration via JSON**: Expanding the current UI structure to allow for the declaration and use of custom widgets directly through JSON configurations. This will significantly increase the flexibility and extensibility of the UI, moving beyond a fixed set of predefined UI elements.
- **User-Generated Content Marketplace (창작마당)**: Implementing a system (potentially utilizing a database) for users to save, manage, and share their custom-designed widgets and screen configurations. This will foster a community-driven ecosystem and further enhance customization possibilities.

These enhancements are focused on providing a more intuitive and powerful user experience, offering greater flexibility in UI design and customization, and fostering a community around user-generated content.
