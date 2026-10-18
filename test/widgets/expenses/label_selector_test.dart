import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:split/models/label.dart';
import 'package:split/widgets/expenses/label_selector.dart';

void main() {
  const food = Label(
    id: 'lbl_1',
    groupId: 'grp_1',
    name: 'Food',
    color: Color(0xFF4CB963),
    icon: '🍕',
  );
  const rent = Label(
    id: 'lbl_2',
    groupId: 'grp_1',
    name: 'Rent',
    color: Color(0xFF4A90D9),
  );

  Widget wrap(Widget child) =>
      ProviderScope(child: ShadApp(home: Scaffold(body: child)));

  testWidgets('renders each label and a trailing "+ New" chip', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        LabelSelector(
          labels: const [food, rent],
          selectedLabelId: null,
          onChanged: (_) {},
          onCreateNew: () {},
        ),
      ),
    );

    expect(find.textContaining('Food'), findsOneWidget);
    expect(find.textContaining('Rent'), findsOneWidget);
    expect(find.text('+ Nueva'), findsOneWidget);
  });

  testWidgets('tapping an unselected label selects it', (tester) async {
    String? selected;
    await tester.pumpWidget(
      wrap(
        LabelSelector(
          labels: const [food, rent],
          selectedLabelId: null,
          onChanged: (id) => selected = id,
          onCreateNew: () {},
        ),
      ),
    );

    await tester.tap(find.textContaining('Food'));
    await tester.pumpAndSettle();

    expect(selected, 'lbl_1');
  });

  testWidgets('tapping the already-selected label clears the selection', (
    tester,
  ) async {
    String? selected = 'not-cleared';
    await tester.pumpWidget(
      wrap(
        LabelSelector(
          labels: const [food, rent],
          selectedLabelId: 'lbl_1',
          onChanged: (id) => selected = id,
          onCreateNew: () {},
        ),
      ),
    );

    await tester.tap(find.textContaining('Food'));
    await tester.pumpAndSettle();

    expect(selected, isNull);
  });

  testWidgets('tapping "+ New" invokes onCreateNew', (tester) async {
    var createNewCalled = false;
    await tester.pumpWidget(
      wrap(
        LabelSelector(
          labels: const [],
          selectedLabelId: null,
          onChanged: (_) {},
          onCreateNew: () => createNewCalled = true,
        ),
      ),
    );

    await tester.tap(find.text('+ Nueva'));
    await tester.pumpAndSettle();

    expect(createNewCalled, isTrue);
  });
}
