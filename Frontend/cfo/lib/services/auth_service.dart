import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../core/constants/api_constants.dart';
import '../models/user.dart';
import '../core/storage/token_storage.dart';

class AuthService {
  final ApiClient _client;
  final TokenStorage _tokenStorage;
  AuthService(this._client, this._tokenStorage);

  Future<Map<String, dynamic>> signup(String name, String email, String password, String role) async {
    try {
      final data = await _client.post(ApiConstants.signup, body: {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      }, auth: false);
      await _tokenStorage.saveToken(data['token']);
      await _tokenStorage.saveUserData(Map<String, dynamic>.from(data['user']));
      await _tokenStorage.saveRole(role);
      return data;
    } on ApiException catch (e) {
      if (e.statusCode == 409) {
        final loginData = await login(email, password);
        return loginData;
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final data = await _client.post(ApiConstants.login, body: {
      'email': email,
      'password': password,
    }, auth: false);
    await _tokenStorage.saveToken(data['token']);
    final user = Map<String, dynamic>.from(data['user']);
    await _tokenStorage.saveUserData(user);
    if (user.containsKey('role')) await _tokenStorage.saveRole(user['role']);
    return data;
  }

  Future<void> logout() async {
    await _tokenStorage.clearToken();
  }

  Future<Map<String, dynamic>> onboarding({
    required String companyName,
    required String industry,
    double monthlyRevenue = 0,
    double monthlyExpenses = 0,
    int employees = 0,
  }) async {
    return await _client.post(ApiConstants.onboarding, body: {
      'companyName': companyName,
      'industry': industry,
      'monthlyRevenue': monthlyRevenue,
      'monthlyExpenses': monthlyExpenses,
      'employees': employees,
    });
  }

  bool isLoggedIn() {
    return _tokenStorage.getToken() != null;
  }

  String? getRole() => _tokenStorage.getRole();

  String? getStoredToken() => _tokenStorage.getToken();

  String? getStoredRole() => _tokenStorage.getRole();
}