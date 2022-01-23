namespace IfaceRender {
    void ItemSetBlock(IX::ItemSet@ itemSet) {
        UI::Separator();
        if(UI::BeginTable("ItemSetBlock", 3)){
            UI::TableSetupColumn("", UI::TableColumnFlags::WidthFixed, 100);
            UI::TableSetupColumn("", UI::TableColumnFlags::WidthStretch, 1);
            UI::TableSetupColumn("", UI::TableColumnFlags::WidthFixed, 75);

            UI::TableNextRow();
            UI::TableSetColumnIndex(0);
            if(itemSet.ImageCount > 0)
                IfaceRender::HoverImage("https://" + MXURL + "/set/image/" + itemSet.ID + "/1", 100);
            UI::TableSetColumnIndex(1);
            UI::PushStyleVar(UI::StyleVar::ItemSpacing, vec2(0, 20));
            UI::Text(Icons::FolderOpen);
            UI::SameLine();
            UI::PushFont(ixMenu.g_fontHeader2);
            UI::Text(itemSet.Name);
            UI::PopFont();
            UI::PopStyleVar();
            UI::Text("By " + Icons::User + " " + itemSet.Username + " | " + Icons::Heart + " " + itemSet.LikeCount + " | " + Icons::Bolt + " " + itemSet.Score + " | " + Icons::Download + " " + itemSet.Downloads);
            UI::TableSetColumnIndex(2);
            
            if (UI::GreenButton(Icons::InfoCircle)) {
                ixMenu.AddTab(ItemSetTab(itemSet.ID), true);
            }

            UI::EndTable();
        }
        UI::Separator();
    }

    void ItemBlock(IX::Item@ item) {
        UI::Separator();
        if(UI::BeginTable("ItemBlock", 3)){
            UI::TableSetupColumn("", UI::TableColumnFlags::WidthFixed, 50);
            UI::TableSetupColumn("", UI::TableColumnFlags::WidthStretch, 1);
            UI::TableSetupColumn("", UI::TableColumnFlags::WidthFixed, 75);

            UI::TableNextRow();
            UI::TableSetColumnIndex(0);
            IfaceRender::Image("https://" + MXURL + "/item/icon/" + item.ID, 50);
            UI::TableSetColumnIndex(1);
            UI::PushStyleVar(UI::StyleVar::ItemSpacing, vec2(0, 15));
            IfaceRender::ItemType(item);
            UI::SameLine();
            UI::PushFont(ixMenu.g_fontHeader2);
            UI::Text(item.Name);
            UI::PopFont();
            UI::PopStyleVar();
            UI::Text("By " + Icons::User + " " + item.Username + " | " + Icons::Heart + " " + item.LikeCount + " | " + Icons::Bolt + " " + item.Score + " | " + Icons::Download + " " + item.Downloads);
            UI::TableSetColumnIndex(2);
            
            if (UI::GreenButton(Icons::InfoCircle)) {
                ixMenu.AddTab(ItemTab(item.ID), true);
            }
            UI::SameLine();
            IfaceRender::ImportButton(EImportType::Item, item, 'block' + item.ID);

            UI::EndTable();
        }
        UI::Separator();
    }

    // dense version is 4 rows, otherwise 7 rows
    void ItemRow(IX::Item@ item, bool dense = false) {
        UI::Dummy(vec2(0, 7));
        UI::Separator();

        UI::TableNextRow();

        UI::TableSetColumnIndex(0);

        IfaceRender::Image("https://" + MXURL + "/item/icon/" + item.ID, 40);

        UI::TableNextColumn();
        
        // Item Type Icon
        IfaceRender::ItemType(item);
        UI::SameLine();

        // Item Name
        UI::Text(item.Name);

        // Item Tags on newline
        IfaceRender::Tags(item.Tags);

        if(!dense) {
            UI::TableNextColumn();
            UI::Text(item.Username);

            UI::TableNextColumn();
            UI::Text(tostring(item.LikeCount));

            UI::TableNextColumn();
            UI::Text(tostring(item.Score));
        }

        UI::TableNextColumn();
        UI::Text(tostring(item.FileSize) + ' KB');

        UI::TableNextColumn();
        if (UI::GreenButton(Icons::InfoCircle)) {
            ixMenu.AddTab(ItemTab(item.ID), true);
        }
        UI::SameLine();
        IfaceRender::ImportButton(EImportType::Item, item, 'row' + item.ID);
    }
}