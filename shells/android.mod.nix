{ ... }: {
  perSystem =
    { pkgs, ... }:
    let
      androidPkgs = import pkgs.path {
        system = pkgs.stdenv.hostPlatform.system;
        config = {
          android_sdk.accept_license = true;
          allowUnfree = true;
        };
      };
      packageName = "ch.heigvd.iict.daa.template";
      activityName = "MainActivity";
      apkPath = "./app/build/outputs/apk/debug/app-debug.apk";
    in
    {
      devShells.android = androidPkgs.mkShell {
        buildInputs = [
          androidPkgs.android-studio
          androidPkgs.android-tools
          androidPkgs.jdk17
          androidPkgs.gradle
          androidPkgs.git
          (androidPkgs.androidenv.emulateApp {
            name = "android-emulate";
            platformVersion = "36";
            abiVersion = "x86_64";
            systemImageType = "google_apis_playstore";
            app = apkPath;
            package = packageName;
            activity = activityName;
          })
          (androidPkgs.writeShellScriptBin "emu" "run-test-emulator > /dev/null 2>&1 &\n")
          (androidPkgs.writeShellScriptBin "astudio" "android-studio $1 > /dev/null 2>&1 &\n")
          (androidPkgs.writeShellScriptBin "build" "$1/gradlew :app:assembleDebug\n")
          (androidPkgs.writeShellScriptBin "apkinstall" "adb install -r ${apkPath}\n")
          (androidPkgs.writeShellScriptBin "reload" "adb shell input keyevent 4\n	./gradlew :app:assembleDebug\n	adb install -r ${apkPath}\n	adb shell am start -n ${packageName}/${packageName}.${activityName}\n")
        ];
        shellHook = ''
          export ANDROID_HOME="$HOME/Android"
          export ANDROID_SDK_ROOT="$ANDROID_HOME"
          export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH:$ANDROID_HOME/tools/bin"
          export JAVA_HOME="${androidPkgs.jdk17.home}"
          export QT_QPA_PLATFORM=xcb
          echo "Android dev shell ready."
          echo "Package: ${packageName}"
          echo "Activity: ${activityName}"
          echo "APK Path: ${apkPath}"
          export SHELL=$(getent passwd $USER | cut -d: -f7)
          exec $SHELL
        '';
      };
    };
}
