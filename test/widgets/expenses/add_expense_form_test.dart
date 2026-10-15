import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:split/widgets/expenses/add_expense_form.dart';

void main() {
  Widget buildForm({
    required GlobalKey<ShadFormState> formKey,
    required bool repeatMonthly,
    required ValueChanged<bool> onRepeatMonthlyChanged,
  }) {
    return ShadApp(
      home: Scaffold(
        body: AddExpenseForm(
          groups: const [],
          groupId: null,
          selectedGroupId: null,
          payerId: null,
          splitMemberIds: const {},
          submitted: false,
          isSubmitting: false,
          formKey: formKey,
          findGroup: (groups, id) => null,
          onGroupChanged: (_) {},
          onPayerChanged: (_) {},
          onSplitMemberIdsChanged: (_) {},
          onLabelChanged: (_) {},
          repeatMonthly: repeatMonthly,
          onRepeatMonthlyChanged: onRepeatMonthlyChanged,
          onSubmit: () {},
        ),
      ),
    );
  }

  testWidgets('shows a "Repeat monthly" switch that reports toggles', (
    tester,
  ) async {
    final formKey = GlobalKey<ShadFormState>();
    bool? reportedValue;

    await tester.pumpWidget(
      buildForm(
        formKey: formKey,
        repeatMonthly: false,
        onRepeatMonthlyChanged: (value) => reportedValue = value,
      ),
    );

    expect(find.text('Repeat monthly'), findsOneWidget);

    await tester.tap(find.byType(ShadSwitch));
    await tester.pump();

    expect(reportedValue, isTrue);
  });

  testWidgets('reflects an already-true repeatMonthly value', (tester) async {
    final formKey = GlobalKey<ShadFormState>();

    await tester.pumpWidget(
      buildForm(
        formKey: formKey,
        repeatMonthly: true,
        onRepeatMonthlyChanged: (_) {},
      ),
    );

    final switchWidget = tester.widget<ShadSwitch>(find.byType(ShadSwitch));
    expect(switchWidget.value, isTrue);
  });
}
