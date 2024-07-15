import 'package:abey_wallet/model/serializable_model.dart';

class SolanaException extends Serializable implements Exception {
  final String message;
  final int? code;

  const SolanaException(
    this.message, {
    this.code,
  });

  factory SolanaException.fromJson(final Map<String, dynamic> json) => SolanaException(
    json['message'],
    code: json['code'],
  );

  @override
  Map<String, dynamic> toJson() => { 
    'message': message, 
    'code': code, 
  };

  @override
  String toString() => '[$runtimeType] ${code != null ? '$code : ' : ''}$message';
}
