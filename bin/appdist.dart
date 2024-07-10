import 'dart:io';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as path;

Future<String> findIpaFile() async {
  final directory = Directory(path.join('build', 'ios', 'ipa'));
  if (!await directory.exists()) {
    throw Exception('IPA directory not found');
  }

  final files = await directory.list().toList();
  final ipaFile = files.firstWhere(
    (file) => file.path.endsWith('.ipa'),
    orElse: () => throw Exception('No IPA file found'),
  );

  return ipaFile.path;
}

Future<void> ensureConfigExists() async {
  final configFile = File('app_dist_config.yaml');
  if (!await configFile.exists()) {
    print('app_dist_config.yaml not found. Generating a dummy file...');
    await configFile.writeAsString('''
android_app_id: "your_android_app_id_here"
ios_app_id: "your_ios_app_id_here"
release_notes: "Your release notes here"
testers: "tester1@example.com,tester2@example.com"
''');
    print(
        'Dummy app_dist_config.yaml generated. Please edit it with your actual app IDs and other details.');
    exit(1);
  }
}

void main(List<String> arguments) async {
  if (arguments.isEmpty) {
    print('Please specify a target: ios or apk');
    exit(1);
  }

  final target = arguments[0].toLowerCase();
  if (target != 'ios' && target != 'apk') {
    print('Invalid target. Please use either ios or apk');
    exit(1);
  }

  await ensureConfigExists();

  final configPath = 'app_dist_config.yaml';

  try {
    // Read and parse the YAML file
    final file = File(configPath);
    if (!await file.exists()) {
      print('Error: $configPath not found in the current directory.');
      exit(1);
    }
    final yamlString = await file.readAsString();
    final config = loadYaml(yamlString);

    // Extract values from the YAML
    final androidAppId = config['android_app_id'];
    final iosAppId = config['ios_app_id'];
    final releaseNotes = config['release_notes'];
    final testers = config['testers'];

    // Build the app
    print('Building ${target.toUpperCase()}...');
    final buildResult = await Process.run(
      'flutter',
      target == 'ios'
          ? ['build', 'ipa', '--release', '--export-method=ad-hoc']
          : ['build', 'apk', '--release'],
      runInShell: Platform.isWindows,
    );

    print(buildResult.stdout);
    if (buildResult.exitCode != 0) {
      print('Error building ${target.toUpperCase()}:');
      print(buildResult.stderr);
      exit(1);
    }

    String appPath;
    if (target == 'ios') {
      appPath = await findIpaFile();
    } else {
      appPath = path.join(
          'build', 'app', 'outputs', 'flutter-apk', 'app-release.apk');
    }

    // Distribute the app
    print('Distributing ${target.toUpperCase()}...');
    final distributeResult = await Process.run(
      'firebase',
      [
        'appdistribution:distribute',
        appPath,
        '--app',
        target == 'ios' ? iosAppId : androidAppId,
        '--release-notes',
        '"$releaseNotes"',
        '--testers',
        testers,
      ],
      runInShell: Platform.isWindows,
    );

    print(distributeResult.stdout);
    if (distributeResult.exitCode != 0) {
      print('Error distributing ${target.toUpperCase()}:');
      print(distributeResult.stderr);
      exit(1);
    }

    print('${target.toUpperCase()} built and distributed successfully!');
  } catch (e) {
    print('An error occurred: $e');
    exit(1);
  }
}