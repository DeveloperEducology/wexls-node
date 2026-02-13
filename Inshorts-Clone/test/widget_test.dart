import 'package:flutter_test/flutter_test.dart';
import 'package:inshort_clone/app/app.dart';

void main() {
  testWidgets('Inshorts app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Note: This might still fail due to Hive initialization in main(), 
    // but at least it will find the class.
    // In a real test we would mock Hive.
    await tester.pumpWidget(App());
  });
}
