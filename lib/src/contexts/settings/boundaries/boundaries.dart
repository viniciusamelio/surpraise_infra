class GetSettingsOutput {
  const GetSettingsOutput({
    required this.pushNotificationsEnabled,
  });

  final bool pushNotificationsEnabled;
}

class SaveSettingsOutput {
  final bool pushNotificationsEnabled;
  const SaveSettingsOutput({
    required this.pushNotificationsEnabled,
  });
}

class SaveSettingsInput {
  final bool pushNotificationsEnabled;
  final String userId;
  const SaveSettingsInput({
    required this.pushNotificationsEnabled,
    required this.userId,
  });
}
