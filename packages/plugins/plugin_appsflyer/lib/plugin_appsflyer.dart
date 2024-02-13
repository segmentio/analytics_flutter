library analytics_plugin_appsflyer;

import 'dart:convert';

import 'package:segment_analytics/analytics.dart';
import 'package:segment_analytics/plugin.dart';
import 'package:segment_analytics_plugin_appsflyer/types.dart';
import 'package:segment_analytics_plugin_appsflyer/utils.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';

class AppsFlyerDestination extends DestinationPlugin {
  AppsFlyerDestination() : super("AppsFlyer");

  AppsFlyerSettings? appsFlyerSettings;
  bool hasRegisteredInstallCallback = false;
  bool hasRegisteredDeepLinkCallback = false;
  bool hasInitialized = false;
  AppsflyerSdk? appsFlyer;

  @override
  void update(Map<String, dynamic> settings, ContextUpdateType type) {
    final appsflyerSettingsJson = settings["AppsFlyer"];

    if (appsflyerSettingsJson == null) {
      return;
    }
    final clientConfig = analytics!.state.configuration.state;

    appsFlyerSettings = AppsFlyerSettings.fromJson(appsflyerSettingsJson);

    if (!hasInitialized) {
      AppsFlyerOptions appsFlyerOptions = AppsFlyerOptions(
          afDevKey: appsFlyerSettings!.appsFlyerDevKey,
          appId: appsFlyerSettings!.appleAppID ?? "",
          showDebug: Analytics.debug,
          timeToWaitForATTUserAuthorization: 50); // for iOS 14.5
      appsFlyer = AppsflyerSdk(appsFlyerOptions);
      appsFlyer!.initSdk(
          registerConversionDataCallback:
              appsFlyerSettings!.trackAttributionData,
          registerOnDeepLinkingCallback: clientConfig.trackDeeplinks == true);
      hasInitialized = true;
    }

    if (appsFlyerSettings!.trackAttributionData &&
        !hasRegisteredInstallCallback) {
      registerConversionCallback();
      hasRegisteredInstallCallback = true;
    }

    if (clientConfig.trackDeeplinks == true && !hasRegisteredDeepLinkCallback) {
      registerDeepLinkCallback();
      hasRegisteredDeepLinkCallback = true;
    }
  }

  @override
  identify(event) async {
    final userId = event.userId;
    if (userId != null && userId.isNotEmpty) {
      appsFlyer!.setCustomerUserId(userId);
    }

    final traits = event.traits;
    if (traits != null) {
      final Map<String, dynamic> aFTraits = {};

      if (traits.email != null) {
        aFTraits["email"] = traits.email;
      }

      if (traits.firstName != null) {
        aFTraits["firstName"] = traits.firstName;
      }

      if (traits.lastName != null) {
        aFTraits["lastName"] = traits.lastName;
      }

      if (traits.custom["currencyCode"] != null) {
        appsFlyer!.setCurrencyCode(traits.custom["currencyCode"].toString());
      }

      appsFlyer!.setAdditionalData(aFTraits);
    }
    return event;
  }

  @override
  track(event) async {
    final properties = event.properties ?? {};

    final revenue = extractRevenue('revenue', properties);
    final currency = extractCurrency('currency', properties, 'USD');

    if (revenue != null && currency != null) {
      final Map<String, dynamic> otherProperties = {};
      for (final entry in properties.entries) {
        if (entry.key != 'revenue' && entry.key != 'currency') {
          otherProperties[entry.key] = entry.value;
        }
      }

      await appsFlyer!.logEvent(event.event, {
        ...otherProperties,
        "af_revenue": revenue,
        "af_currency": currency,
      });
    } else {
      await appsFlyer!.logEvent(event.event, properties);
    }
    return event;
  }

  void registerConversionCallback() {
    appsFlyer!.onInstallConversionData((res) {
      final properties = {
        "provider": "AppsFlyer",
        "campaign": {
          "source": res?.data["media_source"],
          "name": res?.data["campaign"],
        },
      };

      if (res?.data["is_first_launch"] != null &&
          jsonDecode(res?.data["is_first_launch"]) == true) {
        if (res?.data["af_status"] == 'Non-organic') {
          analytics?.track('Install Attributed', properties: properties);
        } else {
          analytics
              ?.track('Organic Install', properties: {"provider": "AppsFlyer"});
        }
      }
    });
  }

  void registerDeepLinkCallback() {
    appsFlyer!.onAppOpenAttribution((res) {
      if (res?.status == 'success') {
        final properties = {
          "provider": "AppsFlyer",
          "campaign": {
            "name": res?.data["campaign"],
            "source": res?.data["media_source"],
          },
        };
        analytics?.track('Deep Link Opened', properties: properties);
      }
    });
  }
}
