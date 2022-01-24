﻿// TODO:
// ----------- [ higher priority ] -----------
// ----------- [ low priority ] -----------
// Show search results in ui
// make tags clickable
// add visit set button in item row
// date string to (6 days ago/2 years ago/today/5 months ago)
// add setting for how directory structure should be made (completely flat/include author/include setname/use set directory)
// add padding to "loading" text on item list page
// ----------- [ lowest priority ] -----------
// Support blocks
// add import by zip?


IXEditor@ ixEditor = null;

void Main() {
    @ixEditor = IXEditor();
    startnew(IX::GetAllItemTags);
    // for dev:
    sleep(100);
    // ixMenu.AddTab(ItemSetTab(11269), true);
    // ixMenu.AddTab(ItemSetTab(11273), true);
}

void RenderMenu() {
    if(UI::MenuItem(nameMenu + (IX::APIDown ? " \\$f00"+Icons::Server : ""), "", ixMenu.isOpened)) {
        if (IX::APIDown) {
            Dialogs::Message("\\$f00" + Icons::Times + " \\$zSorry, " + pluginName + " is not responding.\nReload the plugin to try again.");
        } else {
            ixMenu.isOpened = !ixMenu.isOpened;
        }
    }
}

void RenderMenuMain() {
    if(UI::BeginMenu(nameMenu + (IX::APIDown ? " \\$f00"+Icons::Server : ""))) {
        if (!IX::APIDown) {
            if(UI::MenuItem(pluginColor + Icons::WindowMaximize+"\\$z Open " + shortMXName + " menu", "", ixMenu.isOpened)) {
                ixMenu.isOpened = !ixMenu.isOpened;
            }
        } else {
            UI::TextDisabled("\\$f00" + Icons::Server + " \\$z" + shortMXName + " is down!");
            UI::TextDisabled("Consider to check your internet connection.");
            UI::TextDisabled("Reload the plugin to try again.");
        }
        UI::Separator();
         if (UI::BeginMenu(pluginColor+Icons::InfoCircle + " \\$zAbout")){
            if (UI::BeginMenu("\\$f00"+Icons::Heart + " \\$zSupport")){
                if (UI::MenuItem(pluginColor+Icons::Heart + " \\$zSupport ManiaExchange")) OpenBrowserURL("https://"+MXURL+"/support");
                if (UI::MenuItem(Icons::Heartbeat + " \\$zSupport the plugin creator")) OpenBrowserURL("https://github.com/sponsors/GreepTheSheep");
                UI::EndMenu();
            }
            UI::Separator();
            if (UI::BeginMenu(pluginColor+Icons::KeyboardO + " \\$zContact")){
                if (UI::MenuItem(pluginColor+Icons::KeyboardO + " \\$zContact ManiaExchange")) OpenBrowserURL("https://"+MXURL+"/messaging/compose/11");
                if (UI::MenuItem(Icons::DiscordAlt + "Plugin's creator Discord")) OpenBrowserURL("https://greep.gq/discord");
                UI::EndMenu();
            }
            UI::Separator();
            if (UI::MenuItem(pluginColor+Icons::Facebook + " \\$zManiaExchange on Facebook")) OpenBrowserURL("https://facebook.com/maniaexchange/");
            if (UI::MenuItem(pluginColor+Icons::Twitter + " \\$zManiaExchange on Twitter")) OpenBrowserURL("https://twitter.com/maniaexchange/");
            if (UI::MenuItem(pluginColor+Icons::YoutubePlay + " \\$zManiaExchange on YouTube")) OpenBrowserURL("https://youtube.com/maniaexchangetracks/");
            if (UI::MenuItem(pluginColor+Icons::DiscordAlt + " \\$zManiaExchange on Discord")) OpenBrowserURL("https://discord.mania.exchange/");
            UI::EndMenu();
         }
        if (UI::BeginMenu("\\$f90"+Icons::CircleThin + " \\$zAdvanced")){
            UI::TextDisabled("Actual Repository URL: ");
            UI::TextDisabled(MXURL);
            if (UI::MenuItem(pluginColor+Icons::ExternalLink + " \\$zOpen "+pluginName+" in browser")) OpenBrowserURL("https://"+MXURL);
            UI::EndMenu();
        }
        UI::EndMenu();
    }
}

void RenderInterface(){
    ixMenu.Render();
    Dialogs::RenderInterface();
}

string changeEnumStyle(string enumName){
    string str = enumName.SubStr(enumName.IndexOf(":") + 1);
    str = str.Replace("_", " ");
    return str;
}