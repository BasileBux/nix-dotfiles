{
  description =
    "Reusable Android development shell with Android Studio on NixOS";

  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; };

  outputs = { self, nixpkgs }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import inputs.nixpkgs {
        inherit system;
        config = {
          android_sdk.accept_license = true;
          allowUnfree = true;
        };
      };

      # Function to create the dev shell with parameters
      makeAndroidShell = { packageName ? "ch.heigvd.iict.daa.template"
        , activityName ? "MainActivity"
        , apkPath ? "./app/build/outputs/apk/debug/app-debug.apk" }:
        pkgs.mkShell {
          buildInputs = [
            # (pkgs.jetbrains.plugins.addPlugins pkgs.jetbrains.android-studio [ "ideavim" ])
            pkgs.android-studio
            pkgs.android-tools
            pkgs.jdk17
            pkgs.gradle
            pkgs.git
            (pkgs.writeShellScriptBin "astu"
              "android-studio $1 > /dev/null 2>&1 &")

            # Emulator ran with the `run-test-emulator` command
            (pkgs.androidenv.emulateApp {
              name = "android-emulate";
              platformVersion = "36";
              abiVersion = "x86_64";
              systemImageType = "google_apis_playstore";
              app = apkPath;
              package = packageName;
              activity = activityName;
            })

            (pkgs.writeShellScriptBin "emu"
              "	run-test-emulator > /dev/null 2>&1 &\n")
            (pkgs.writeShellScriptBin "astudio"
              "	android-studio  > /dev/null 2>&1 &\n")
            (pkgs.writeShellScriptBin "build"
              "	$1/gradlew :app:assembleDebug\n")
            (pkgs.writeShellScriptBin "apkinstall"
              "	adb install -r ${apkPath}\n")
            (pkgs.writeShellScriptBin "reload"
              "	adb shell input keyevent 4\n	./gradlew :app:assembleDebug\n	adb install -r ${apkPath}\n	adb shell am start -n ${packageName}/${packageName}.${activityName}\n")
          ];
          shellHook =
            "	export ANDROID_HOME=\"$HOME/Android\"\n	export ANDROID_SDK_ROOT=\"$ANDROID_HOME\"\n	export PATH=\"$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH:$ANDROID_HOME/tools/bin\"\n	export JAVA_HOME=\"${pkgs.jdk17.home}\"\n	export QT_QPA_PLATFORM=xcb\n\n	echo \"Android dev shell ready.\"\n	echo \"Package: ${packageName}\"\n	echo \"Activity: ${activityName}\"\n	echo \"APK Path: ${apkPath}\"\n	exec zsh\n";
        };
    in {
      # Default shell with default parameters
      devShells.${system}.default = makeAndroidShell { };

      # Expose the function for use in other flakes
      lib.makeAndroidShell = makeAndroidShell;
    };
}
