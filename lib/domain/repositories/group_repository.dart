import 'package:vclane_client/domain/entities/group.dart';

abstract class GroupRepository {
  Stream<List<Group>> watchGroups();
  Stream<Group?> watchGroup(String id);
}
