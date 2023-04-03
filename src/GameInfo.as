class GameInfo {
    CTrackMania@ app;

    GameInfo() {
        @app = cast<CTrackMania@>(GetApp());
    }

    CTrackManiaNetwork@ Network {
        get const {
            return cast<CTrackManiaNetwork>(this.app.Network);
        }
        // set {}
    }

    CGamePlayground@ CurrentPlayground {
        get const {
            return cast<CGamePlayground>(this.app.CurrentPlayground);
        }
        // set {}
    }

    CGameTerminal@ GameTerminal {
        get {
            if (this.CurrentPlayground is null
                || this.CurrentPlayground.GameTerminals.Length < 1) {
                return null;
            }
            return this.CurrentPlayground.GameTerminals[0];
        }
        // set {}
    }

    NGameLoadProgress_SMgr@ LoadProgress {
        get const {
            return cast<NGameLoadProgress_SMgr>(this.app.LoadProgress);
        }
        // set {}
    }

    MwFastBuffer<CGameUILayer@> UILayers {
        get const {
            return this.Network.ClientManiaAppPlayground.UILayers;
        }
        // set {}
    }

    bool IsPlaying() {
        auto network = Network;
        auto playground = CurrentPlayground;
        return playground !is null &&
               network.ClientManiaAppPlayground !is null &&
               network.ClientManiaAppPlayground.Playground !is null &&
               network.ClientManiaAppPlayground.UILayers.Length > 0;
    }
}