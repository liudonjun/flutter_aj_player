#ifndef FLUTTER_PLUGIN_AJ_PLAYER_PLUGIN_H_
#define FLUTTER_PLUGIN_AJ_PLAYER_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace aj_player {

class AjPlayerPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  AjPlayerPlugin();

  virtual ~AjPlayerPlugin();

  // Disallow copy and assign.
  AjPlayerPlugin(const AjPlayerPlugin&) = delete;
  AjPlayerPlugin& operator=(const AjPlayerPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace aj_player

#endif  // FLUTTER_PLUGIN_AJ_PLAYER_PLUGIN_H_
