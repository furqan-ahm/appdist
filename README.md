# appdist
.

## Installation

1. Clone this repository or download the source code.

2. Navigate to the project directory: cd path/to/app_dist_tool

3. Activate the package globally: dart pub global activate --source path .

## Configuration

Create a file named `app_dist_config.yaml` in your Flutter project's root directory with the following content:

```yaml
android_app_id: "your_android_app_id_here"
ios_app_id: "your_ios_app_id_here"
release_notes: "Your release notes here"
testers: "tester1@example.com,tester2@example.com"
```

Replace the placeholder values with your actual Firebase app IDs, release notes, and tester email addresses.

## Usage

From your Flutter project directory, run:

For Android: app_dist apk

For iOS: app_dist ios