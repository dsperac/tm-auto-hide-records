// constants
const int MOUSE_MOVE_HIDE_DELAY = 5000;

// HUDPicker constants
const string HUDPICKER_ID = "HUDPicker";
const string HUDPICKER_RECORD_VISIBLE_VARNAME = "recordVisible";

// global vars
Meta::Plugin@ hudPickerPlugin = Meta::GetPluginFromID(HUDPICKER_ID);
GameInfo@ gameInfo;
uint64 mouseLastMovedTime;

// renders the setting in the plugins dropdown menu
void RenderMenu()
{
    if (UI::MenuItem(Icons::EyeSlash + " " + "Auto-Hide Records", "", AutoHideRecords)) {
        AutoHideRecords = !AutoHideRecords;
    }
}

bool ShouldRunPlugin() {
    return ((
        AutoHideRecords // plugin has to be enabled
        && gameInfo.IsPlaying() // should be on a map
        && !IsHudPickerRecordsHidden() // don't do anything if the records element is hidden via HUD Picker
        && gameInfo.LoadProgress.State != NGameLoadProgress::EState::Displayed // wait until playground finishes loading
    ) || (
        // handle case when element hidden and plugin gets turned off
        !recordHud.GetVisible() && !AutoHideRecords
    ));
}

void OnMouseMove(int x, int y) {
#if TMNEXT
    if (!ShouldRunPlugin()) {
        return;
    }
    mouseLastMovedTime = Time::Now;
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
        speed = Math::Abs(Math::Round(vehicleState.FrontSpeed * 3.6f));
    }

    bool shouldShowHud = (
        (Time::Now - mouseLastMovedTime) < MOUSE_MOVE_HIDE_DELAY // if mouse was moved recently
        || (!recordHud.GetVisible() && !AutoHideRecords) // plugin gets turned off
        || (
            gameTerminal !is null
            && gameTerminal.UISequence_Current != CGamePlaygroundUIConfig::EUISequence::Playing // if the current game state isn't Playing
        ) || speed < SpeedThreshold // if the speed is less than the threshold set
    );
    
    recordHud.SetVisible(shouldShowHud);
    recordHud.UpdateVisibilty(uiLayer);
#endif
}
