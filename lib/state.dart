import 'package:sovran/action.dart';
import 'package:sovran/state.dart';
import 'package:uuid/uuid.dart';
import 'configuration.dart';
import 'settings.dart';


// System Actions
class System extends State {
  late final Configuration _configuration;
  late final Map<String, dynamic>? _integrations;
  late final Settings? settings;
  late bool running;

  System(this._configuration, this._integrations, this.settings, this.running);
}

class UpdateSettingsAction implements Action {
  Settings settings;

  UpdateSettingsAction(this.settings);

  @override
  State reduce(State state) {
    if (state is System) {
      var result = System(
          state._configuration, state._integrations, settings, state.running);
      return result;
    } else {
      throw Exception("Could not update settings.");
    }
  }
}

class AddIntegrationAction implements Action {
  String key;

  AddIntegrationAction(this.key);

  @override
  State reduce(State state) {
    if (state is System) {

      // we need to set any destination plugins to false in the
      // integrations payload.  this prevents them from being sent
      // by segment.com once an event reaches segment.
      var integrations = state._integrations;
      if (integrations != null && integrations.isNotEmpty) {
        integrations[key] = false;
        return System(state._configuration, integrations, state.settings, state.running);
      } else {
        return state;
      }
    } else {
      throw Exception("Could not add integration.");
    }
  }
}

class RemoveIntegrationAction implements Action {
  String key;
  RemoveIntegrationAction(this.key);

  @override
  State reduce(State state) {
    if (state is System) {
      var integrations = state._integrations;
      if (integrations != null && integrations.isNotEmpty) {
        integrations.remove(key);
        return System(state._configuration, integrations, state.settings, state.running);
      } else {
        return state;
      }
    } else {
      throw Exception("Could not remove integration.");
    }
  }
}

class ToggleRunningAction implements Action {
  bool running;

  ToggleRunningAction(this.running);

  @override
  State reduce(State state) {
    if (state is System) {
      return System(state._configuration, state._integrations, state.settings, running);
    } else {
      throw Exception("Could not toggle running state.");
    }
  }
}

// UserInfo Actions {
class UserInfo extends State {
  late final String anonymousId;
  late final String? userId;
  late final Map<String, dynamic>? traits;

  UserInfo(this.anonymousId, this.userId, this.traits);
}

class ResetAction implements Action {
  @override
  State reduce(State state) {
    if (state is UserInfo) {
      return UserInfo(Uuid().v1(), null, null);
    } else {
      throw Exception("Could not reset user state.");
    }
  }
}

class SetUserIdAction implements Action {
  String userId;

  SetUserIdAction(this.userId);

  @override
  State reduce(State state) {
    if (state is UserInfo) {
      return UserInfo(state.anonymousId, userId, state.traits);
    } else {
      throw Exception("Could not add userId to user state.");
    }
  }
}

class SetTraitsAction implements Action {
  Map<String, dynamic> traits;

  SetTraitsAction(this.traits);

  @override
  State reduce(State state) {
    if (state is UserInfo) {
      return UserInfo(state.anonymousId, state.userId, traits);
    } else {
      throw Exception("Could not add traits to user state.");
    }
  }
}

class SetUserIdAndTraitsAction implements Action {
  String userId;
  Map<String, dynamic> traits;

  SetUserIdAndTraitsAction(this.userId, this.traits);

  @override
  State reduce(State state) {
    if (state is UserInfo) {
      return UserInfo(state.anonymousId, userId, traits);
    } else {
      throw Exception("Could not add userId and traits to user state.");
    }
  }
}

class SetAnonymousIdAction implements Action {
  String anonymousId;

  SetAnonymousIdAction(this.anonymousId);

  @override
  State reduce(State state) {
    if (state is UserInfo) {
      return UserInfo(anonymousId, state.userId, state.traits);
    } else {
      throw Exception("Could not add anonymousId to user state.");
    }
  }
}

extension DefaultSystem on System {
  static System defaultState(Configuration configuration, Storage storage) {
    Settings? settings = storage.read();
    if (settings == null) {
      Settings? defaults = configuration._values._defaultSettings;
      if (defaults != null) {
        settings = defaults;
      } else {
        settings =
      }
    }
    Map<String, dynamic> integrations = Map<String, dynamic>();
    return System(configuration, integrations, settings, false);
  }
}