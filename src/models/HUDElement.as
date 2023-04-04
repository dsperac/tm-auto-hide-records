class HUDElement {
    string Name;
    string ModuleName;
    int ModuleIndex;
    string SubModuleName;
    bool IsVisible = true;
    bool GetVisible() { return this.IsVisible; }
    void SetVisible(bool v) { this.IsVisible = v; }

    HUDElement(const string &in name, const string &in moduleName, const string &in subModuleName = "") {
        this.Name = name;
        this.ModuleName = moduleName;
        this.ModuleIndex = -1;
        this.SubModuleName = subModuleName;
    }

    void ToggleVisible() {
        this.SetVisible(!this.GetVisible());
    }

    void FindElement(MwFastBuffer<CGameUILayer@> &in uilayers) {
        for (uint i = 0; i < uilayers.Length; i++) {
            CGameUILayer@ curLayer = uilayers[i];
            int start = curLayer.ManialinkPageUtf8.IndexOf("<");
            int end = curLayer.ManialinkPageUtf8.IndexOf(">");
            if (start != -1 && end != -1) {
                auto manialinkname = curLayer.ManialinkPageUtf8.SubStr(start, end);
                if (manialinkname.Contains(this.ModuleName)) {
                    this.ModuleIndex = i;
                    return; // we don't need to continue further
                }
            }
        }
        this.ModuleIndex = -1;
    }

    bool Exists(CGameUILayer@ curLayer) {
        int start = curLayer.ManialinkPageUtf8.IndexOf("<");
        int end = curLayer.ManialinkPageUtf8.IndexOf(">");
        if (start != -1 && end != -1) {
            auto manialinkname = curLayer.ManialinkPageUtf8.SubStr(start, end);
            if (manialinkname.Contains(this.ModuleName)) {
                return true;
            }
        }
        this.ModuleIndex = -1;
        return false;
    }

    void UpdateVisibilty(CGameUILayer@ layer) {
        if (this.Exists(layer)) {
            if (this.ModuleName != "" && this.SubModuleName == "") {
                if (this.GetVisible() != layer.IsVisible) {
                    layer.IsVisible = !layer.IsVisible;
                }
            } else if (this.ModuleName != "" && this.SubModuleName != "") {
                CControlFrame@ c = cast<CControlFrame@>(layer.LocalPage.GetFirstChild(this.SubModuleName).Control);
                if (c !is null) {
                    array<CControlFrame@> frames  = { c };
                    while (!frames.IsEmpty()) {
                        auto children = frames[0].Childs;
                        for (uint j = 0; j < children.Length; j++) {
                            if (Reflection::TypeOf(children[j]).Name == "CControlFrame") {
                                frames.InsertLast(cast<CControlFrame@>(children[j]));
                            } else {
                                auto subModule = cast<CControlBase@>(children[j]);
                                if (this.GetVisible() && !subModule.IsVisible) {
                                    subModule.Show();
                                } else if (!this.GetVisible() && subModule.IsVisible) {
                                    subModule.Hide();
                                }
                            }
                        }
                        frames.RemoveAt(0);
                    }
                } else {
                    error("SubModule could not be found");
                }
            }
        }
    }
}
