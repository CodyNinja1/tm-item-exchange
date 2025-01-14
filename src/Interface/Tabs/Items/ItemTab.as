class ItemTab : Tab {
    IX::Item@ item;
    int ID;
    EGetStatus status = EGetStatus::Downloading;

    ItemTab(int itemID){
        this.ID = itemID;
        downloader.Check('item', ID);
    }

    bool CanClose() override { return true; }
    string GetLabel() override {
        if (status == EGetStatus::Error) 
            return "\\$f00" + Icons::Times + " \\$zError";
        if (status == EGetStatus::Downloading) 
            return Icons::Database + " Loading...";
        return Icons::Tree + " " + item.Name;
    }

    void Render() override {
        if(status != EGetStatus::Available) {
            status = downloader.Check('item', ID);
            if(status == EGetStatus::Error) {
                UI::Text("\\$f00" + Icons::Times + " \\$zItem not found");
                return;
            }
            if(status == EGetStatus::Downloading) {
                UI::Text(IfaceRender::GetHourGlass() + " Loading...");
                return;
            }
            if(status == EGetStatus::Available) {
                @item = downloader.GetItem(ID);
            }
        }

        float width = (UI::GetWindowSize().x * 0.35) * 0.5;
        vec2 posTop = UI::GetCursorPos();

        UI::BeginChild("ItemImage", vec2(width, 0));

        UI::BeginTabBar("ItemImages");
        if(UI::BeginTabItem("Icon")) {
            IfaceRender::Image("https://" + MXURL + "/item/icon/" + item.ID, int(width));
            UI::EndTabItem();
        }
        if(item.HasThumbnail && UI::BeginTabItem("Thumbnail")) {
            IfaceRender::HoverImage("https://" + MXURL + "/item/thumbnail/" + item.ID, int(width));
            UI::EndTabItem();
        }
        UI::EndTabBar();

        UI::EndChild();

        UI::SetCursorPos(posTop + vec2(width + 8, 0));
        UI::BeginChild("ItemHeader");
        UI::SetCursorPos(UI::GetCursorPos() + vec2(8, 8));
        UI::PushStyleColor(UI::Col::ChildBg, vec4(0, 0, 0, 0));
        UI::BeginChild("PaddedItem", UI::GetContentRegionAvail() + vec2(-8, 0));

        UI::PushFont(Fonts::fontTitle);
        UI::Text(item.Name);
        UI::PopFont();

        UI::PushStyleVar(UI::StyleVar::FramePadding, vec2(2, 2));
        UI::AlignTextToFramePadding();
        UI::Text(Icons::Heart + " " + item.LikeCount + " | " + Icons::Bolt + " " + item.Score + " | " + Icons::Download + " " + item.Downloads);
        if(item.SetID != 0){
            UI::SameLine();
            UI::Text("| " + Icons::Folder + " Part of set ");
            
            UI::SameLine();
            auto buttonBg = vec4(0, 0, 0, 0);
            auto hoverBg = vec4(1, 1, 1, 0.1);
            UI::PushStyleColor(UI::Col::Button, buttonBg);
            UI::PushStyleColor(UI::Col::ButtonHovered, hoverBg);
            UI::PushStyleColor(UI::Col::ButtonActive, buttonBg);
            UI::PushStyleColor(UI::Col::Text, GetColor());
            if(UI::Button(item.SetName)) {
                ixMenu.AddTab(ItemSetTab(item.SetID), true);
            }
            UI::PopStyleColor(4);
        }
        UI::PopStyleVar();

        IfaceRender::TabHeader(Icons::InfoCircle + " Information");

        if(UI::BeginTable("InfoColumns", 2)) {
            UI::TableSetupColumn("##infoleft", UI::TableColumnFlags::WidthFixed, 125);
            UI::TableSetupColumn("##inforight", UI::TableColumnFlags::WidthStretch, 1);

            IfaceRender::SimpleTableRow({"Item ID:", tostring(item.ID)});
            IfaceRender::SimpleTableRow({"Uploaded by:", item.Username});
            if(item.AuthorLogin != '') {
                IfaceRender::SimpleTableRow({"Creator Login:", item.AuthorLogin});
            }
            if(item.Updated == item.Uploaded){
                IfaceRender::SimpleTableRow({"Uploaded:", item.Uploaded});
            } else {
                IfaceRender::SimpleTableRow({"Uploaded (Ver.):", item.Uploaded + " (" + item.Updated + ")"});
            }
            IfaceRender::SimpleTableRow({"Item Type:", tostring(item.Type)});
            IfaceRender::SimpleTableRow({"Filesize:", tostring(item.FileSize) + ' KB'});
            
            // tag row
            UI::TableNextRow();
            UI::PushFont(Fonts::fontBold);
            UI::TableSetColumnIndex(0);
            UI::Text("Tags:");
            UI::PopFont();
            UI::TableSetColumnIndex(1);
            IfaceRender::Tags(item.Tags);
            // end tag row

            UI::EndTable();
        }

        if(ixMenu.isInEditor) {
            UI::Separator();
            UI::Dummy(vec2(0, 3));
            IfaceRender::ImportButton(EImportType::Item, item, 'tab' + item.ID, true);
        }

        if(item.Description != "") {
            IfaceRender::TabHeader(Icons::Pencil + " Description");
            IfaceRender::IXComment(item.Description);
        }

        UI::EndChild();
        UI::PopStyleColor(1);
        UI::EndChild();
    }
};