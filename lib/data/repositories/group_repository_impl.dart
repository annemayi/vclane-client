import 'package:vclane_client/domain/entities/group.dart';
import 'package:vclane_client/domain/repositories/group_repository.dart';
import 'package:vclane_client/data/datasources/group_remote_datasource.dart';

class GroupRepositoryImpl implements GroupRepository {
  final GroupRemoteDataSource _remoteDataSource;

  GroupRepositoryImpl(this._remoteDataSource);

  @override
  Stream<List<Group>> watchGroups() => _remoteDataSource.watchGroups();

  @override
  Stream<Group?> watchGroup(String id) => _remoteDataSource.watchGroup(id);
}
