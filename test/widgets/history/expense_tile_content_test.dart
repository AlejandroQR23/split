import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:split/models/expense.dart';
import 'package:split/models/member.dart';
import 'package:split/widgets/history/expense_tile_content.dart';

const _payer = Member(id: 'mem_01h', name: 'Alice');

Expense _expense({String? recurringExpenseId}) => Expense(
  id: 'exp_01h',
  groupId: 'grp_01h',
  concept: 'Rent',
  amount: 1000,
  paidBy: _payer,
  shares: [const ExpenseShare(member: _payer, amount: 1000)],
  date: DateTime.utc(2026, 9, 1),
  recurringExpenseId: recurringExpenseId,
);

void main() {
  testWidgets('shows no recurring icon for a non-recurring expense', (
    tester,
  ) async {
    await tester.pumpWidget(
      ShadApp(
        home: Scaffold(
          body: ExpenseTileContent(
            expense: _expense(),
            currentUser: _payer,
            subtitleDetail: 'Sep 1',
          ),
        ),
      ),
    );

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is HugeIcon &&
            widget.icon == HugeIcons.strokeRoundedRepeat,
      ),
      findsNothing,
    );
  });

  testWidgets(
    'shows a non-interactive recurring icon for a recurring expense',
    (tester) async {
      await tester.pumpWidget(
        ShadApp(
          home: Scaffold(
            body: ExpenseTileContent(
              expense: _expense(recurringExpenseId: 'rec_01h'),
              currentUser: _payer,
              subtitleDetail: 'Sep 1',
            ),
          ),
        ),
      );

      final recurringIconFinder = find.byWidgetPredicate(
        (widget) =>
            widget is HugeIcon && widget.icon == HugeIcons.strokeRoundedRepeat,
      );
      expect(recurringIconFinder, findsOneWidget);
      // The icon is a plain visual indicator now — the whole tile (owned by
      // the caller) is the tap target for expense details, not this icon.
      expect(
        find.ancestor(
          of: recurringIconFinder,
          matching: find.byType(GestureDetector),
        ),
        findsNothing,
      );
    },
  );
}
