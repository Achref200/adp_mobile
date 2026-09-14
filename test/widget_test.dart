import 'package:adp_mobile/core/design/adp_components.dart';
import 'package:adp_mobile/core/design/adp_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ADP primary action uses its supplied label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: adpTheme(),
        home: Scaffold(
          body: AdpPrimaryButton(label: 'Discover ADP', onPressed: () {}),
        ),
      ),
    );

    expect(find.text('Discover ADP'), findsOneWidget);
  });
}
