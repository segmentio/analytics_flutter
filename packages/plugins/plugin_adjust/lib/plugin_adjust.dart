library analytics_plugin_adjust;

import 'package:adjust_sdk/adjust.dart';
import 'package:adjust_sdk/adjust_config.dart';
import 'package:adjust_sdk/adjust_event.dart';
import 'package:segment_analytics/errors.dart';
import 'package:segment_analytics/plugin.dart';
import 'package:segment_analytics_plugin_adjust/types.dart';
import 'package:segment_analytics_plugin_adjust/utils.dart';

class AdjustDestination extends DestinationPlugin {
  AdjustDestination() : super("Adjust");

  AdjustSettings? adjustSettings;
  bool hasRegisteredCallback = false;

  @override
  void update(Map<String, dynamic> settings, ContextUpdateType type) {
    final adjustSettingsJson = settings["Adjust"];

    if (adjustSettingsJson == null) {
      return;
    }

    try {
      adjustSettings = AdjustSettings.fromJson(adjustSettingsJson);
    } catch (e) {
      analytics?.error(PluginError("Error couldn't parse Adjust settings", e));
    }

    if (adjustSettings == null) {
      return;
    }

    final environment = adjustSettings!.setEnvironmentProduction == true
        ? AdjustEnvironment.production
        : AdjustEnvironment.sandbox;

    final adjustConfig = AdjustConfig(adjustSettings!.appToken, environment);

    if (hasRegisteredCallback == false) {
      adjustConfig.attributionCallback = (attribution) {
        final trackPayload = {
          "provider": "Adjust",
          "trackerToken": attribution.trackerToken,
          "trackerName": attribution.trackerName,
          "campaign": {
            "source": attribution.network,
            "name": attribution.campaign,
            "content": attribution.clickLabel,
            "adCreative": attribution.creative,
            "adGroup": attribution.adgroup,
          },
        };
        analytics?.track("Install Attributed", properties: trackPayload);
      };
      hasRegisteredCallback = true;
    }

    Adjust.initSdk(adjustConfig);
  }

  @override
  identify(event) async {
    final userId = event.userId;
    if (userId != null && userId.isNotEmpty) {
      Adjust.addGlobalPartnerParameter('user_id', userId);
    }

    final anonId = event.anonymousId;
    if (anonId != null && anonId.isNotEmpty) {
      Adjust.addGlobalPartnerParameter('anonymous_id', anonId);
    }
    return event;
  }

  @override
  track(event) async {
    final anonId = event.anonymousId;
    if (anonId != null && anonId.isNotEmpty) {
      Adjust.addGlobalPartnerParameter('anonymous_id', anonId);
    }

    if (adjustSettings == null) {
      return event;
    }

    final token = mappedCustomEventToken(event.event, adjustSettings!);
    if (token != null) {
      final adjEvent = AdjustEvent(token);

      final properties = event.properties;
      if (properties != null) {
        for (final entry in properties.entries) {
          adjEvent.addCallbackParameter(entry.key, entry.value.toString());
        }

        final revenue = extract<double>('revenue', properties);
        final currency =
            extract<String>('currency', properties, defaultValue: 'USD');
        final orderId = extract<String>('orderId', properties);

        if (revenue != null && currency != null) {
          adjEvent.setRevenue(revenue, currency);
        }

        if (orderId != null) {
          adjEvent.transactionId = orderId;
        }
      }

      Adjust.trackEvent(adjEvent);
    }
    return event;
  }

  @override
  reset() {
    Adjust.removeGlobalPartnerParameters();
  }
}
