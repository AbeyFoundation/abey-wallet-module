import 'package:logger/logger.dart';
import 'package:synchronized/synchronized.dart';

class ConsoleUtil {
  static ConsoleUtil? _singleton;
  static Logger? _logger;
  static Lock _lock = Lock();

  static getInstance() async {
    if (_singleton == null) {
      await _lock.synchronized(() async {
        if(_singleton == null) {
          var singleton = ConsoleUtil._();
          await singleton._init();
          _singleton = singleton;
        }
      });
    }
  }

  ConsoleUtil._();

  _init() {
    _logger = Logger(printer: PrettyPrinter());
  }

  void debug(dynamic message) {
    _logger!.d(message);
  }

  void info(dynamic message) {
    _logger!.i(message);
  }

  void warn(dynamic message) {
    _logger!.w(message);
  }

  void error(dynamic message) {
    _logger!.e(message);
  }

  static void d(dynamic message) {
    getInstance();
    _logger!.d(message);
  }

  static void i(dynamic message) {
    getInstance();
    _logger!.i(message);
  }

  static void w(dynamic message) {
    getInstance();
    _logger!.w(message);
  }

  static void e(dynamic message) {
    getInstance();
    _logger!.e(message);
  }

}