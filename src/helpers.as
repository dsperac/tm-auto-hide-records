// HUD Picker helpers
Meta::PluginSetting@ FindHudPickerRecordsVisibleSetting(array<Meta::PluginSetting@> settings) {
    for (int i = 0; i < int(settings.Length); i++) {
        if (
            settings[i].VarName == HUDPICKER_RECORD_VISIBLE_VARNAME
            && settings[i].Type == Meta::PluginSettingType::Bool
        ) {
            return settings[i];
        }
    }
    return null;
}

bool IsHudPickerRecordsHidden() {
    if (
        hudPickerPlugin !is null
        && hudPickerPlugin.Enabled
    ) {
        auto settings = hudPickerPlugin.GetSettings();
        auto setting = FindHudPickerRecordsVisibleSetting(settings);
        if (setting !is null) {
            bool settingValue = setting.ReadBool();
            return !settingValue;
        }
    }
    return false;
}
