//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import audio_session
import just_audio
import package_info_plus
import path_provider_foundation
import sqflite
import sqlite3_flutter_libs
import url_launcher_macos
import wakelock_plus

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  AudioSessionPlugin.register(with: registry.registrar(forPlugin: "AudioSessionPlugin"))
  JustAudioPlugin.register(with: registry.registrar(forPlugin: "JustAudioPlugin"))
  FLTPackageInfoPlusPlugin.register(with: registry.registrar(forPlugin: "FLTPackageInfoPlusPlugin"))
  PathProviderPlugin.register(with: registry.registrar(forPlugin: "PathProviderPlugin"))
  SqflitePlugin.register(with: registry.registrar(forPlugin: "SqflitePlugin"))
  Sqlite3FlutterLibsPlugin.register(with: registry.registrar(forPlugin: "Sqlite3FlutterLibsPlugin"))
  UrlLauncherPlugin.register(with: registry.registrar(forPlugin: "UrlLauncherPlugin"))
  WakelockPlusMacosPlugin.register(with: registry.registrar(forPlugin: "WakelockPlusMacosPlugin"))
}
