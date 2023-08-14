#include "include/aj_player/aj_player_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "aj_player_plugin.h"

void AjPlayerPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  aj_player::AjPlayerPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
