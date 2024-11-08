import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:dio/dio.dart';
import 'package:movil_app/models/access.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:movil_app/models/types.dart';
import 'package:movil_app/models/categories.dart';
import 'package:movil_app/models/status.dart';
import 'package:movil_app/models/tickets.dart';


class RestServiceAccess {
  static final Dio _client = Dio(); 
  static final Logger _logger = Logger();

  static const String _mime = 'application/json';
  static const String _baseUrl = 'https://api.sebastian.cl/oirs-utem';

  static Future<List<Access>> access() async {
  List<Access> list = [];
  _client.interceptors.add(LogInterceptor(
    request: true,
    requestBody: true,
    responseBody: true,
    requestHeader: true,
    responseHeader: true,
  ));
  SharedPreferences instance = await SharedPreferences.getInstance();
  final String idToken = instance.getString('idToken') ?? '';

  if (idToken.isNotEmpty) {
    const String url = '$_baseUrl/v1/info/access';
    Map<String, String> headers = {'accept': _mime, 'Authorization': idToken};

    Response<String> response = await _client.get(url, options: Options(headers: headers));
    final int httpCode = response.statusCode ?? 400;

    if (httpCode == 200 && httpCode < 300) {
      final String responseJSON = response.data ?? '';
      list = List<Access>.from(json.decode(responseJSON).map((x) => Access.fromJson(x)));
      for (Access access in list) {
        _logger.i("IP: ${access.ip}, URI: ${access.requestUri}");
      }
    }
  }
  return list;
  }
}


class RestServiceTypes {
  static final Dio _client = Dio();
  static final Logger _logger = Logger();

  static const String _mime = 'application/json';
  static const String _baseUrl = 'https://api.sebastian.cl/oirs-utem';

   static Future<List<String>> access() async {
    List<String> list = [];
    _client.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: true,
    ));
    
    SharedPreferences instance = await SharedPreferences.getInstance();
    String idToken = instance.getString('idToken') ?? '';
    
    if (idToken.isNotEmpty) {
      const String url = '$_baseUrl/v1/info/types';
      Map<String, String> headers = {'accept': _mime, 'Authorization': idToken};

      Response<String> response = await _client.get(url, options: Options(headers: headers));
      final int httpCode = response.statusCode ?? 400;

      if (httpCode == 200 && httpCode < 300) {
        final String responseJSON = response.data ?? '';
        list = typesFromJson(responseJSON);
         for (String type in list) {
          _logger.i("Type: $type");
        
        }
      }
    }
  return list;
}
}
class RestServiceCategories {
  static final Dio _client = Dio(); 
  static final Logger _logger = Logger();

  static const String _mime = 'application/json';
  static const String _baseUrl = 'https://api.sebastian.cl/oirs-utem';
  
  static Future<List<Categories>> access() async {
    List<Categories> list = [];
    
    _client.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: true,
    ));

    SharedPreferences instance = await SharedPreferences.getInstance();
    String idToken = instance.getString('idToken') ?? '';
    
    if (idToken.isNotEmpty) {
      const String url = '$_baseUrl/v1/info/categories';
      Map<String, String> headers = {'accept': _mime, 'Authorization': idToken};

      Response<String> response = await _client.get(url, options: Options(headers: headers));
      final int httpCode = response.statusCode ?? 400;
      
      if (httpCode == 200 && httpCode < 300) {
        final String responseJSON = response.data ?? '';
        list = List<Categories>.from(json.decode(responseJSON).map((x) => Categories.fromJson(x)));

        for (Categories category in list) {
          _logger.i("Category Name: ${category.name}, Description: ${category.description}");
        }
      }
    }
    
    return list;
  }
}
class RestServiceStatus {
  static final Dio _client = Dio();
  static final Logger _logger = Logger();

  static const String _mime = 'application/json';
  static const String _baseUrl = 'https://api.sebastian.cl/oirs-utem';

  static Future<List<String>> access() async {
    List<String> list = [];
    _client.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: true,
    ));

    SharedPreferences instance = await SharedPreferences.getInstance();
    String idToken = instance.getString('idToken') ?? '';

    if (idToken.isNotEmpty) {
      const String url = '$_baseUrl/v1/info/status';
      Map<String, String> headers = {'accept': _mime, 'Authorization': idToken};

      Response<String> response = await _client.get(url, options: Options(headers: headers));
      final int httpCode = response.statusCode ?? 400;

      if (httpCode == 200 && httpCode < 300) {
        final String responseJSON = response.data ?? '';
        list=statusFromJson(responseJSON);
        for (String status in list) {
          _logger.i("Status: $status");
        }
      }
    }
    
    return list;
  }
}
class RestServiceTickets {
  static final Dio _client = Dio();
  static final Logger _logger = Logger();

  static const String _mime = 'application/json';
  static const String _baseUrl = 'https://api.sebastian.cl/oirs-utem';

  static Future<List<Ticket>> getAllTickets() async {
    List<Ticket> allTickets = [];

    SharedPreferences instance = await SharedPreferences.getInstance();
    String idToken = instance.getString('idToken') ?? '';

    if (idToken.isEmpty) {
      _logger.e("No valid ID token found.");
      return allTickets;
    }

    List<Categories> categories = await RestServiceCategories.access();
    List<String> types = await RestServiceTypes.access();
    List<String> statuses = await RestServiceStatus.access();

    for (var category in categories) {
      for (var type in types) {
        for (var status in statuses) {
          _logger.i("Bucando categoria por nombre: ${category.name}, Type: $type, Status: $status");

          List<Ticket> tickets = await getTickets(category.token, type, status);
          allTickets.addAll(tickets);

          for (var ticket in tickets) {
            _logger.i("Ticket Subject: ${ticket.subject}, Status: ${ticket.status}, Type: ${ticket.type}, Category: ${category.name}");
          }
        }
      }
    }

    return allTickets;
  }

  static Future<List<Ticket>> getTickets(String categoryToken, String type, String status) async {
    List<Ticket> list = [];
    
    _client.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: true,
    ));

    SharedPreferences instance = await SharedPreferences.getInstance();
    String idToken = instance.getString('idToken') ?? '';

    if (idToken.isNotEmpty) {
      final String url = '$_baseUrl/v1/icso/$categoryToken/tickets';
      Map<String, String> headers = {'accept': _mime, 'Authorization': idToken};

      try {
        Response<String> response = await _client.get(
          url,
          options: Options(headers: headers),
          queryParameters: {
            'type': type,
            'status': status,
          },
        );

        final int httpCode = response.statusCode ?? 400;

        if (httpCode == 200 && httpCode < 300) {
          final String responseJSON = response.data ?? '';
          list = List<Ticket>.from(json.decode(responseJSON).map((x) => Ticket.fromJson(x)));
        }
      } catch (e) {
        _logger.e("ERROR AL ENCONTRAR EL TICKET: $e");
      }
    }
    
    return list;
  }
}