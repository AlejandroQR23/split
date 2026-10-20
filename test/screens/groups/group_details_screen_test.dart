import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:split/models/expense.dart';
import 'package:split/models/group.dart';
import 'package:split/models/member.dart';
import 'package:split/models/transfer.dart';
import 'package:split/providers/current_member_provider.dart';
import 'package:split/providers/expenses_provider.dart';
import 'package:split/providers/groups_provider.dart';
import 'package:split/providers/transfer_provider.dart';
import 'package:split/repositories/expense_repository.dart';
import 'package:split/repositories/group_repository.dart';
import 'package:split/repositories/transfer_repository.dart';
import 'package:split/screens/groups/group_details_screen.dart';

class _FakeGroupRepository implements GroupRepository {
  _FakeGroupRepository(this.groups);
  final List<Group> groups;

  @override
  Future<List<Group>> fetchGroups() async => groups;
  @override
  Future<List<Group>> fetchRecentGroups({required int limit}) =>
      throw UnimplementedError();
  @override
  Future<void> addGroup(CreateGroupInput group) => throw UnimplementedError();
  @override
  Future<void> removeGroup(String groupId) => throw UnimplementedError();
  @override
  Future<void> updateGroup(Group updatedGroup) => throw UnimplementedError();
  @override
  Future<void> addMemberToGroup(String groupId, String memberId) =>
      throw UnimplementedError();
}

class _FakeExpenseRepository implements ExpenseRepository {
  @override
  Future<List<Expense>> fetchExpenses({int? limit}) async => const [];
  @override
  Future<List<Expense>> fetchExpensesForGroup(String groupId) async =>
      const [];
  @override
  Future<void> addExpense(CreateExpenseInput expense, String groupId) =>
      throw UnimplementedError();
  @override
  Future<void> addPayment(CreatePaymentInput payment, String groupId) =>
      throw UnimplementedError();
  @override
  Future<void> removeExpense(String expenseId) => throw UnimplementedError();
  @override
  Future<void> updateExpense(Expense updatedExpense) =>
      throw UnimplementedError();
}

class _FakeTransferRepository implements TransferRepository {
  @override
  Future<List<Transfer>> fetchTransfers(String groupId) async => const [];
}

void main() {
  testWidgets(
    'renders a not-found state for a groupId that is not in the list',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentMemberProvider.overrideWith(
              (ref) async =>
                  const Member(id: 'mem_01h', name: 'Ana', isGhost: false),
            ),
            groupRepositoryProvider.overrideWithValue(
              _FakeGroupRepository(const [
                Group(id: 'grp_other', name: 'Otro grupo', members: []),
              ]),
            ),
            expenseRepositoryProvider.overrideWithValue(
              _FakeExpenseRepository(),
            ),
            transferRepositoryProvider.overrideWithValue(
              _FakeTransferRepository(),
            ),
          ],
          child: ShadApp.router(
            routerConfig: GoRouter(
              initialLocation: '/',
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) =>
                      const GroupDetailsScreen(groupId: 'does-not-exist'),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Este grupo ya no existe.'), findsOneWidget);
    },
  );
}
