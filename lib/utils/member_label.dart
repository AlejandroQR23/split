import 'package:split/models/member.dart';

/// How to refer to [member] relative to [currentUser] in subject/nominative
/// position — e.g. before a verb, as in "Tú pagaste", or as a neutral label
/// (avatar initials, a list row) where grammatical case doesn't apply.
String subjectLabel(Member member, {required Member currentUser}) =>
    member.id == currentUser.id ? 'Tú' : member.name;

/// How to refer to [member] relative to [currentUser] in object/
/// prepositional position — e.g. after "a"/"por", as in "a ti"/"por ti".
/// Spanish has no prepositional "tú"; reusing [subjectLabel] here is the
/// mistake this function exists to prevent.
String objectLabel(Member member, {required Member currentUser}) =>
    member.id == currentUser.id ? 'ti' : member.name;
