//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <aj_player/aj_player_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) aj_player_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "AjPlayerPlugin");
  aj_player_plugin_register_with_registrar(aj_player_registrar);
}
