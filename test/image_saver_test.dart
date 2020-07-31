import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_saver/image_saver.dart';

void main() {
  const MethodChannel channel = MethodChannel('image_saver');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await ImageSaver.platformVersion, '42');
  });
}
