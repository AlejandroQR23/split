import '../models/expense.dart';
import 'current_user.dart';
import 'mock_groups.dart';

/// Hardcoded, in-memory expenses — mirrors [mockGroups] for Phase 2's mock
/// repository layer.
final mockExpenses = <Expense>[
  // g1 (Trip to Lisbon): a mixed balance — Mateo covered the hotel for
  // everyone, you covered dinner for everyone.
  Expense(
    id: 'e1',
    groupId: 'g1',
    concept: 'Hotel',
    amount: 400,
    paidBy: mockGroups[0].members[0], // Mateo
    shares: [
      ExpenseShare(member: mockGroups[0].members[1], amount: 100), // Sara
      ExpenseShare(member: mockGroups[0].members[2], amount: 100), // Diego
      ExpenseShare(member: mockGroups[0].members[3], amount: 100), // Nadia
      ExpenseShare(member: currentUser, amount: 100),
    ],
    date: DateTime(2026, 6, 10),
  ),
  Expense(
    id: 'e2',
    groupId: 'g1',
    concept: 'Dinner',
    amount: 96,
    paidBy: currentUser,
    shares: [
      ExpenseShare(member: mockGroups[0].members[0], amount: 24), // Mateo
      ExpenseShare(member: mockGroups[0].members[1], amount: 24), // Sara
      ExpenseShare(member: mockGroups[0].members[2], amount: 24), // Diego
      ExpenseShare(member: mockGroups[0].members[3], amount: 24), // Nadia
    ],
    date: DateTime(2026, 6, 11),
  ),

  // g2 (Apartment 4B): a single expense — you owe Marcus for groceries.
  Expense(
    id: 'e3',
    groupId: 'g2',
    concept: 'Groceries',
    amount: 45,
    paidBy: mockGroups[1].members[0], // Marcus
    shares: [ExpenseShare(member: currentUser, amount: 22.5)],
    date: DateTime(2026, 7, 1),
  ),

  // g3 (Weekend Ski Trip): two expenses between you and Elena that net to
  // zero — demonstrates the "all settled up" state with real data.
  Expense(
    id: 'e4',
    groupId: 'g3',
    concept: 'Lift Tickets',
    amount: 100,
    paidBy: currentUser,
    shares: [ExpenseShare(member: mockGroups[2].members[0], amount: 50)],
    date: DateTime(2026, 1, 15),
  ),
  Expense(
    id: 'e5',
    groupId: 'g3',
    concept: 'Ski Rental',
    amount: 100,
    paidBy: mockGroups[2].members[0], // Elena
    shares: [ExpenseShare(member: currentUser, amount: 50)],
    date: DateTime(2026, 1, 16),
  ),
];
