import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindflow_workday/core/di/service_locator.dart';
import 'package:mindflow_workday/main.dart';

void main() {
  setupDependencies();

  testWidgets('App boots and shows a loading state while resolving the session',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MindFlowApp());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
