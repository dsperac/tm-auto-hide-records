// constants
const float SPEED_THRESHOLD = 1.0f;
const int MOUSE_MOVE_HIDE_DELAY = 3500;

// HUDPicker constants
const string HUDPICKER_ID = "HUDPicker";
const string HUDPICKER_RECORD_VISIBLE_VARNAME = "recordVisible";

// global vars
Meta::Plugin@ hudPickerPlugin = Meta::GetPluginFromID(HUDPICKER_ID);
GameInfo@ gameInfo;
float ticker = 0;

// settings definition
[Setting name="Is Enabled" category="General"]
bool AutoHideRecords = true;

// renders the setting in the plugins dropdown menu
void RenderMenu()
{
    if (UI::MenuItem(Icons::EyeSlash + " " + "Auto-Hide Records", "", AutoHideRecords)) {
        AutoHideRecords = !AutoHideRecords;
    }
}

// HUD Picker helpers
Meta::PluginSetting@ findHudPickerRecordsVisibleSetting(array<Meta::PluginSetting@> settings) {
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
        auto setting = findHudPickerRecordsVisibleSetting(settings);
        if (setting !is null) {
            bool settingValue = setting.ReadBool();
            return !settingValue;
        }
    }
    return false;
}

void UpdateTicker(float dt) {
    ticker -= dt;
    if (ticker < 0) {
        ticker = 0;
    }
}

bool ShouldRunPlugin() {
    return (
        AutoHideRecords // plugin has to be enabled
        && gameInfo.IsPlaying() // should be on a map
        && !IsHudPickerRecordsHidden() // don't do anything if the records element is hidden via HUD Picker
        && gameInfo.LoadProgress.State != NGameLoadProgress_SMgr::EState::Displayed // wait until playground finishes loading
    );
}

void OnMouseMove(int x, int y) {
#if TMNEXT
    if (!ShouldRunPlugin()) {
        return;
    }
    ticker = MOUSE_MOVE_HIDE_DELAY;
#endif
}

// init
void Main() {
#if TMNEXT
    @gameInfo = GameInfo();
#endif
}

void Update(float dt) {
#if TMNEXT
    if (!ShouldRunPlugin()) {
        return;
    }
    // if index not set or out of bounds try to find the record ui element inside the UI layers collection and store the index
    if (recordHud.ModuleIndex == -1 || recordHud.ModuleIndex >= int(gameInfo.UILayers.Length)) {
        recordHud.FindElement(gameInfo.UILayers);
        // if not found return
        if (recordHud.ModuleIndex == -1) {
            return;
        }
    }
    auto gameTerminal = gameInfo.GameTerminal;
    auto uiLayer = gameInfo.UILayers[recordHud.ModuleIndex];
    auto vehicleState = VehicleState::ViewingPlayerState();
    float speed = 0;

    if (vehicleState !is null) {
        speed = vehicleState.FrontSpeed;
    }

    
    bool shouldShowHud = (
        ticker > 0 // if mouse was moved
        || (
            gameTerminal !is null
            && gameTerminal.UISequence_Current != CGamePlaygroundUIConfig::EUISequence::Playing // if the current game state isn't Playing
        ) || speed < SPEED_THRESHOLD // if the speed is less than the threshold set
    );
    
    recordHud.SetVisible(shouldShowHud);
    recordHud.UpdateVisibilty(uiLayer);

    if (ticker > 0) {
        UpdateTicker(dt);
    }
#endif
}
