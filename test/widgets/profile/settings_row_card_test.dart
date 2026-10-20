import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:split/widgets/profile/settings_row_card.dart';

void main() {
  testWidgets('renders title/subtitle and calls onTap', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      ShadApp(
        home: Scaffold(
          body: SettingsRowCard(
            title: 'Notificaciones',
            subtitle: 'Gestiona tus avisos.',
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Notificaciones'), findsOneWidget);
    expect(find.text('Gestiona tus avisos.'), findsOneWidget);

    await tester.tap(find.byType(SettingsRowCard));

    expect(tapped, true);
  });
}
