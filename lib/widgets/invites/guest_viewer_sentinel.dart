import '../../models/member.dart';

/// A read-only browser that never matches any real member — used as the
/// `currentUser` passed to reused presentational widgets so nothing renders
/// a "Settle up" tap target or a false "You paid" label for a guest. See
/// [InviteGroupSection]'s doc notes for why this beats trying to resolve
/// which roster entry is "the ghost" (the invite preview only has a name,
/// not an id).
const guestViewerSentinel = Member(id: '', name: '');
