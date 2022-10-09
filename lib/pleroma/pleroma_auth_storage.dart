import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PleromaAuthenticationStorage
{
  static const _storage = FlutterSecureStorage();
  static const _fediverseNode = "node";
  static const _accessToken = "access_token";
  static const _creationDate = "created_at";
  static const _experationDate = "expires_in";
  static const _id = "id";
  static const _me = "me";
  static const _refreshToken = "refresh_token";
  static const _scope = "scope";
  static const _tokenType = "token_type";

  static void fromJson(Map<String,dynamic> json)
  {
    setAccessToken(json[_accessToken]);
    setCreationDate(json[_creationDate].toString());
    setExperationDate(json[_experationDate].toString());
    setID(json[_id].toString());
    setMe(json[_me]);
    setRefreshToken(json[_refreshToken]);
    setScope(json[_scope]);
    setTokenType(json[_tokenType]);
  }

  //Store
  static Future setFediverseNode(String domain) async => await _storage.write(key:_fediverseNode, value: domain);

  static Future setAccessToken(String token) async => await _storage.write(key: _accessToken, value: token);
  static Future setCreationDate(String date) async => await _storage.write(key: _creationDate, value: date);
  static Future setExperationDate(String date) async => await _storage.write(key: _experationDate, value: date);
  static Future setID(String id) async => await _storage.write(key: _id, value: id);
  static Future setMe(String meUrl) async => await _storage.write(key: _me, value: meUrl);
  static Future setRefreshToken(String token) async => await _storage.write(key: _refreshToken, value: token);
  static Future setScope(String scope) async => await _storage.write(key: _scope, value: scope);
  static Future setTokenType(String type) async => await _storage.write(key: _tokenType, value: type);

  //Read
  static Future<String?> getFediverseNode() async => await _storage.read(key:_fediverseNode);

  static Future<String?> getAccessToken() async => await _storage.read(key: _accessToken);
  static Future<String?> getCreationDate() async => await _storage.read(key: _creationDate);
  static Future<String?> getExperationDate() async => await _storage.read(key: _experationDate);
  static Future<String?> getID() async => await _storage.read(key: _id);
  static Future<String?> getMe() async => await _storage.read(key: _me);
  static Future<String?> getRefreshToken() async => await _storage.read(key: _refreshToken);
  static Future<String?> getScope() async => await _storage.read(key: _scope);
  static Future<String?> getTokenType() async => await _storage.read(key: _tokenType);

  static void clearStorage()
  {
    _storage.deleteAll();
  }
}