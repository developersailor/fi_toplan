#!/bin/bash

# Set the required environment variable for Flutter to work with custom build configurations
export FLUTTER_BUILD_MODE=debug

# Run the development version of the app
flutter run -t lib/main.dart "$@"