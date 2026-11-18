import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import 'user.dart';

class UserRepository {
  UserRepository(this._api);

  final ApiClient _api;

  Future<List<User>> getAll() async {
    final uri = _api.uri('/users');
    final body = await _api.getJson(uri);
    if (body is! List) {
      throw BadResponseException('users: expected a list, got ${body.runtimeType}');
    }
    return _parse('users', () => [
          for (final item in body) User.fromJson(item as Map<String, dynamic>),
        ]);
  }

  Future<User> getById(int id) async {
    final body = await _api.getJson(_api.uri('/users/$id'));
    return _parse('users/$id', () => User.fromJson(body as Map<String, dynamic>));
  }

  Future<User> create(User draft) async {
    final body = await _api.postJson(_api.uri('/users'), draft.toJson());
    return _parse('users (POST)', () => User.fromJson(body as Map<String, dynamic>));
  }

  T _parse<T>(String where, T Function() build) {
    try {
      return build();
    } on TypeError catch (e) {
      throw BadResponseException('$where: $e');
    } on FormatException catch (e) {
      throw BadResponseException('$where: $e');
    }
  }
}
