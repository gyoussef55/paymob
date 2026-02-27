# Changelog

All notable changes to this project will be documented in this file.

## [1.1.0]

### Changed
- **Android:** Updated native Paymob SDK to 1.7.3
- **iOS:** Updated native Paymob SDK to 1.2.2

## [1.0.1]

### Fixed
- Fixed image URLs in README.md to use absolute GitHub raw URLs for pub.dev compatibility

## [1.0.0]

### Added
- Initial release of Paymob Flutter plugin
- Support for iOS Paymob SDK integration (version 1.2.0)
- Support for Android Paymob SDK integration (version 1.6.12)
- Payment flow implementation with `Paymob.pay()` method
- Support for UI customization:
  - Custom app name
  - Button background and text colors
  - Save card checkbox configuration
- Transaction status handling:
  - Successful payments
  - Rejected payments
  - Pending payments
  - Error handling
- Platform interface architecture for extensibility
- Method channel implementation for native communication
- Comprehensive documentation and setup guides
- Example project demonstrating usage

### Features
- Easy integration with Paymob payment SDKs
- Cross-platform support (iOS and Android)
- Flexible UI customization options
- Robust error handling and status reporting
- Type-safe API with Dart enums and classes
