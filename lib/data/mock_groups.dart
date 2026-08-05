import '../models/group.dart';
import '../models/member.dart';

/// Hardcoded, in-memory groups for Phase 1 — no repository, no persistence.
const mockGroups = <Group>[
  Group(
    id: 'g1',
    name: 'Trip to Lisbon',
    members: [
      Member(id: 'm1', name: 'Alejandro'),
      Member(id: 'm2', name: 'Sara'),
      Member(id: 'm3', name: 'Diego'),
      Member(id: 'm4', name: 'Nadia'),
    ],
  ),
  Group(
    id: 'g2',
    name: 'Apartment 4B',
    members: [
      Member(id: 'm5', name: 'Marcus'),
      Member(id: 'm6', name: 'Priya'),
    ],
  ),
  Group(
    id: 'g3',
    name: 'Weekend Ski Trip',
    members: [
      Member(id: 'm7', name: 'Elena'),
      Member(id: 'm8', name: 'Tomás'),
      Member(id: 'm9', name: 'Yuki'),
      Member(id: 'm10', name: 'Ben'),
      Member(id: 'm11', name: 'Carla'),
    ],
  ),
];
