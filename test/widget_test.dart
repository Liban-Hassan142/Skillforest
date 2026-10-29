import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skillforest/main.dart';

void main() {
  testWidgets('SkillForest app starts with correct configuration', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SkillForestApp());

    expect(find.byType(MaterialApp), findsOneWidget);

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.title, 'SkillForest');
    expect(app.debugShowCheckedModeBanner, isFalse);

    // Dispose of the splash screen before its timer finishes.
    await tester.pumpWidget(const SizedBox.shrink());

    // Allow the pending timer to finish.
    await tester.pump(const Duration(seconds: 9));
  });
}
