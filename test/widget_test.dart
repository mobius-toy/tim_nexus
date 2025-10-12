// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:tim_nexus/app.dart';

void main() {
  testWidgets('renders onboarding headline', (tester) async {
    await tester.pumpWidget(const TimNexusApp());
    await tester.pumpAndSettle();

    expect(find.text('TIM Nexus'), findsOneWidget);
    expect(find.textContaining('TIM 集成'), findsOneWidget);
  });
}
