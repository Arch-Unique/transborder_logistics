import 'package:transborder_logistics/src/utils/utils_barrel.dart';
import 'package:get/get.dart';

abstract class ErrorService extends GetxService {
  Rx<ErrorTypes> currentErrorType = ErrorTypes.noInternet.obs;

  setError(ErrorTypes et) {
    currentErrorType.value = et;
  }
}
