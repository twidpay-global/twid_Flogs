import 'dart:convert';

import 'package:f_logs/f_logs.dart';
import 'package:flutter/foundation.dart';

class Formatter {
  static String format(Log log, LogsConfig config) {
    String? output;

    if (config.formatType.toString() == FormatType.FORMAT_CURLY.toString()) {
      output = _formatCurly(log, config.isDevelopmentDebuggingEnabled);
    } else if (config.formatType.toString() ==
        FormatType.FORMAT_SQUARE.toString()) {
      output = _formatSquare(log, config.isDevelopmentDebuggingEnabled);
    } else if (config.formatType.toString() ==
        FormatType.FORMAT_CSV.toString()) {
      output = _formatCsv(
          log, config.csvDelimiter, config.isDevelopmentDebuggingEnabled);
    } else if (config.formatType.toString() ==
        FormatType.FORMAT_JSON.toString()) {
      output = _formatJson(log, config);
    } else if (config.formatType.toString() ==
        FormatType.FORMAT_CUSTOM.toString()) {
      output = _formatCustom(
          log,
          config.customOpeningDivider,
          config.customClosingDivider,
          config.isDevelopmentDebuggingEnabled,
          config.fieldOrderFormatCustom);
    } else {
      output = _formatCurly(log, config.isDevelopmentDebuggingEnabled);
    }

    return "$output\n";
  }

  static String? _formatCurly(Log log, bool isDevelopmentDebuggingEnabled) {
    String? output;

    output = "{${log.className}} ";
    output += "{${log.methodName}} ";
    output += "{${log.text}} ";
    output += log.exception != 'null' ? "{${log.exception}} " : "";
    output += "{${log.logLevel.toString()}} ";
    output += "{${log.timestamp}} ";
    output += log.stacktrace != 'null' ? "{${log.stacktrace}} " : "";

    if (isDevelopmentDebuggingEnabled) {
      output += !kReleaseMode ? "{${log.dataLogType}} " : "";
      output += !kReleaseMode ? "{${log.timeInMillis}}" : "";
    }

    return output;
  }

  static String? _formatSquare(Log log, bool isDevelopmentDebuggingEnabled) {
    String? output;

    output = "[${log.className}] ";
    output += "[${log.methodName}] ";
    output += "[${log.text}] ";
    output += log.exception != 'null' ? "[${log.exception}] " : "";
    output += "[${log.logLevel.toString()}] ";
    output += "[${log.timestamp}] ";
    output += log.stacktrace != 'null' ? "[${log.stacktrace}] " : "";

    if (isDevelopmentDebuggingEnabled) {
      output += !kReleaseMode ? "[${log.dataLogType}] " : "";
      output += !kReleaseMode ? "[${log.timeInMillis}]" : "";
    }

    return output;
  }

  static String? _formatCsv(
      Log log, String deliminator, bool isDevelopmentDebuggingEnabled) {
    String? output;

    output = "${log.className}$deliminator ";
    output += "${log.methodName}$deliminator ";
    output += "${log.text}$deliminator ";
    output += log.exception != 'null' ? "${log.exception}$deliminator " : "";
    output += "${log.logLevel.toString()}$deliminator ";
    output += "${log.timestamp} ";
    output += log.stacktrace != 'null' ? "${log.stacktrace}$deliminator " : "";

    if (isDevelopmentDebuggingEnabled) {
      output += !kReleaseMode ? "${log.dataLogType} " : "";
      output += !kReleaseMode ? "${log.timeInMillis}" : "";
    }

    return output;
  }

  static String _formatCustom(
    Log log,
    String openingDivider,
    String closingDivider,
    bool isDevelopmentDebuggingEnabled,
    List<FieldName> fieldOrder,
  ) {
    var output = "";

    if (fieldOrder.isNotEmpty) {
      fieldOrder.forEach((fieldName) {
        if (fieldName == FieldName.CLASSNAME) {
          output += "$openingDivider${log.className}$closingDivider ";
        }
        if (fieldName == FieldName.METHOD_NAME) {
          output += "$openingDivider${log.methodName}$closingDivider ";
        }
        if (fieldName == FieldName.TEXT) {
          output += "$openingDivider${log.text}$closingDivider ";
        }
        if (fieldName == FieldName.EXCEPTION) {
          output += log.exception != 'null'
              ? "$openingDivider${log.exception}$closingDivider "
              : "";
        }
        if (fieldName == FieldName.LOG_LEVEL) {
          output += "$openingDivider${log.logLevel.toString()}$closingDivider ";
        }
        if (fieldName == FieldName.TIMESTAMP) {
          output += "$openingDivider${log.timestamp}$closingDivider ";
        }
        if (fieldName == FieldName.STACKTRACE) {
          output += log.stacktrace != 'null'
              ? "$openingDivider${log.stacktrace}$closingDivider "
              : "";
        }
      });

      if (isDevelopmentDebuggingEnabled) {
        output += !kReleaseMode
            ? "$openingDivider${log.dataLogType}$closingDivider "
            : "";
        output += !kReleaseMode
            ? "$openingDivider${log.timeInMillis}$closingDivider"
            : "";
      }
    }

    return output;
  }

  static String _formatJson(
    Log log,
    LogsConfig config,
  ) {
    return jsonEncode(formatJson(log, config));
  }

  static Map<String, dynamic> formatJson(Log log, LogsConfig config) {
    var outerMapFields = <String, dynamic>{};
    var innerMessageFields = <String, dynamic>{};

    if (config.fieldOrderFormatCustom.isNotEmpty) {
      // Split the combined data into encoded original text and encoded serialized map
      List<String> parts = log.text!.split('||');
      String encodedOriginalText = parts[0];
      String? encodedMap;
      try {
        encodedMap = parts[1];
      } catch (e, s) {
        if (kDebugMode) {
          print(s);
        }
      }

      // Decode the original text and serialized map
      String originalText;
      try {
        originalText = utf8.decode(base64Decode(encodedOriginalText));
      } catch (e) {
        //If base64Decode throws an error, It means that the original text was not encoded.
        originalText = encodedOriginalText;
      }
      Map<String, dynamic> mapArguments = {};
      if (encodedMap != null) {
        try {
          mapArguments = jsonDecode(utf8.decode(base64Decode(encodedMap)));
        } catch (e) {
          //If base64Decode throws an error, it means that the map was not encoded.
          mapArguments = jsonDecode(encodedMap);
        }
      }

      for (var fieldName in config.fieldOrderFormatCustom) {
        if (fieldName == FieldName.CLASSNAME) {
          innerMessageFields.addAll({fieldName.name: log.className});
        }
        if (fieldName == FieldName.METHOD_NAME) {
          innerMessageFields.addAll({fieldName.name: log.methodName ?? ""});
        }
        if (fieldName == FieldName.TEXT) {
          innerMessageFields.addAll({fieldName.name: originalText});
        }
        if (fieldName == FieldName.EXCEPTION) {
          innerMessageFields.addAll({fieldName.name: log.exception ?? ""});
        }
        if (fieldName == FieldName.STACKTRACE) {
          innerMessageFields.addAll({fieldName.name: log.stacktrace ?? ""});
        }

        if (fieldName == FieldName.LOG_LEVEL) {
          outerMapFields.addAll({'level_name': log.logLevel?.name ?? ""});
          outerMapFields
              .addAll({'channel': log.logLevel?.name.toLowerCase() ?? ""});
          outerMapFields.addAll({'extra': mapArguments});
        }
        if (fieldName == FieldName.TIMESTAMP) {
          outerMapFields.addAll({'datetime': log.timestamp.toString()});
        }
      }

      final finalOutputMap = {"message": innerMessageFields, ...outerMapFields};
      return finalOutputMap;
    }
    return {};
  }
}
