import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signup_app/main.dart';

const firstTip = 'Use a long password that you do not use for another account.';
const success = 'Demo signup complete — your form passed validation!';

Future<void> press(WidgetTester tester, String label) async {
  final button = find.text(label);
  await tester.pumpAndSettle();
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pump();
}

Future<void> enterForm(
  WidgetTester tester,
  String email,
  String password,
) async {
  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(0), 'Taylor');
  await tester.enterText(fields.at(1), email);
  await tester.enterText(fields.at(2), password);
}

void main() {
  testWidgets('empty and invalid fields block signup; six characters passes', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await press(tester, 'Sign Up');
    expect(find.text('Please enter your name'), findsOneWidget);
    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter a password'), findsOneWidget);
    expect(find.text(success), findsNothing);

    await enterForm(tester, 'invalid', '12345');
    await press(tester, 'Sign Up');
    expect(find.text('Please enter a valid email'), findsOneWidget);
    expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    expect(find.text(success), findsNothing);

    await enterForm(tester, 'taylor@example.com', 'abc123');
    await press(tester, 'Sign Up');
    await tester.pumpAndSettle();
    expect(find.text(success), findsOneWidget);
    final password = tester.widget<TextFormField>(
      find.byType(TextFormField).at(2),
    );
    expect(password.controller!.text, 'abc123');
    expect(
      tester
          .widgetList<EditableText>(find.byType(EditableText))
          .last
          .obscureText,
      isTrue,
    );
  });

  testWidgets(
    'tips are deterministic, short, independent and disabled while loading',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await press(tester, 'Get a signup tip');
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
        tester
            .widget<OutlinedButton>(
              find.widgetWithText(OutlinedButton, 'Get a signup tip'),
            )
            .onPressed,
        isNull,
      );
      await tester.pump(const Duration(seconds: 1));
      expect(find.text(firstTip), findsOneWidget);
      expect(find.text(success), findsNothing);

      await enterForm(tester, 'private@example.com', 'secret123');
      final seen = <String>[firstTip];
      for (var i = 0; i < 2; i++) {
        await press(tester, 'Get a signup tip');
        await tester.pump(const Duration(seconds: 1));
        final tip = tester.widget<Text>(find.byKey(const Key('tipText'))).data!;
        expect(tip.length, lessThanOrEqualTo(240));
        expect(tip, isNot(contains('private@example.com')));
        expect(tip, isNot(contains('secret123')));
        expect(tip, isNot(contains('Taylor')));
        seen.add(tip);
      }
      expect(seen.toSet().length, 3);
      await press(tester, 'Get a signup tip');
      await tester.pump(const Duration(seconds: 1));
      expect(find.text(firstTip), findsOneWidget);
    },
  );

  testWidgets('local failure has a working retry without validating the form', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await press(tester, 'Test tip error');
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    expect(
      find.text('Demo tip could not load. Tap Retry to try again.'),
      findsOneWidget,
    );
    await press(tester, 'Retry');
    await tester.pump(const Duration(seconds: 1));
    expect(find.text(firstTip), findsOneWidget);
    expect(find.text('Retry'), findsNothing);
    await press(tester, 'Sign Up');
    expect(find.text('Please enter your name'), findsOneWidget);
    expect(find.text(success), findsNothing);
  });

  testWidgets('leaving during loading does not update disposed state', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await press(tester, 'Get a signup tip');
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('small screen and keyboard keep actions scrollable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpWidget(const MyApp());
    await press(tester, 'Sign Up');
    await press(tester, 'Test tip error');
    await tester.pump(const Duration(seconds: 1));
    await press(tester, 'Retry');
    await tester.pump(const Duration(seconds: 1));
    expect(find.text(firstTip), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
