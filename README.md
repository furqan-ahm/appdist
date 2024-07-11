# appdist
probably works

## Installation

1. Ensure that firebase cli is setup and logged in on your system

2. Run the following command

```yaml
dart pub global activate --source git https://github.com/furqan-ahm/appdist
```


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

For Android: 
```yaml
appdist apk
```
For iOS: 
```yaml
appdist ios
```