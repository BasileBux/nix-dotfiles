{
	description = "Reusable Android development shell with Android Studio on NixOS";

	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
	};

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
			makeAndroidShell = { 
				packageName ? "ch.heigvd.iict.daa.template", 
				activityName ? "MainActivity", 
				apkPath ? "./app/build/outputs/apk/debug/app-debug.apk" 
			}: pkgs.mkShell {
				buildInputs = [
						# pkgs.android-studio
					(pkgs.jetbrains.plugins.addPlugins pkgs.jetbrains.android-studio [ "ideavie" ])
					pkgs.android-tools
					pkgs.jdk17
					pkgs.gradle
					pkgs.git

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

					(pkgs.writeShellScriptBin "emu" ''
						run-test-emulator > /dev/null 2>&1 &
					'')
					(pkgs.writeShellScriptBin "as" ''
						android-studio
					'')
					(pkgs.writeShellScriptBin "build" ''
						$1/gradlew :app:assembleDebug
					'')
					(pkgs.writeShellScriptBin "apkinstall" ''
						adb install -r ${apkPath}
					'')
					(pkgs.writeShellScriptBin "reload" ''
						adb shell input keyevent 4
						./gradlew :app:assembleDebug
						adb install -r ${apkPath}
						adb shell am start -n ${packageName}/${packageName}.${activityName}
					'')
				];
				shellHook = ''
					export ANDROID_HOME="$HOME/Android"
					export ANDROID_SDK_ROOT="$ANDROID_HOME"
					export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH:$ANDROID_HOME/tools/bin"
					export JAVA_HOME="${pkgs.jdk17.home}"
					export QT_QPA_PLATFORM=xcb

					echo "Android dev shell ready."
					echo "Package: ${packageName}"
					echo "Activity: ${activityName}"
					echo "APK Path: ${apkPath}"
					exec zsh
				'';
			};
		in {
			# Default shell with default parameters
			devShells.${system}.default = makeAndroidShell {};
			
			# Expose the function for use in other flakes
			lib.makeAndroidShell = makeAndroidShell;
		};
}
