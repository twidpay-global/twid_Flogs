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
      output = _formatJson(log, config.fieldOrderFormatCustom);
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
    List<FieldName> fieldOrder,
  ) {
    var outerMapFields = <String, dynamic>{};
    var innerMessageFields = <String, dynamic>{};

    if (fieldOrder.isNotEmpty) {
      for (var fieldName in fieldOrder) {
        if (fieldName == FieldName.CLASSNAME) {
          innerMessageFields.addAll({fieldName.name: log.className});
        }
        if (fieldName == FieldName.METHOD_NAME) {
          innerMessageFields.addAll({fieldName.name: log.methodName ?? ""});
        }
        if (fieldName == FieldName.TEXT) {
          innerMessageFields.addAll({fieldName.name: log.text ?? ""});
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
        }
        if (fieldName == FieldName.TIMESTAMP) {
          outerMapFields.addAll({'datetime': log.timestamp.toString()});
        }
      }

      final finalOutputMap = {"message": innerMessageFields, ...outerMapFields};
      return jsonEncode(finalOutputMap);
    }

    return "";
  }
}
