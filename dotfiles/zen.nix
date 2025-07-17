{ config, pkgs, inputs, settings, ... }:

{
  imports = [ inputs.zen-browser.homeModules.twilight ];
  home.packages = [ inputs.zen-browser.packages.${pkgs.system}.twilight ];
  programs.zen-browser = {
    enable = true;
# I haven't figured this out yet
 #    policies = {
 #      DisableFeedbackCommands = true;
 #      DisableFirefoxStudies = true;
 #      DisablePocket = true;
 #      DisableTelemetry = true;
 #      EnableTrackingProtection = {
 #        Value = true;
 #        Locked = true;
 #        Cryptomining = true;
 #        Fingerprinting = true;
 #      };
 #      SearchEngines.Add = {
 #        Name = "Unduck";
 #        UrlTemplate = "https://unduck.link?q={searchTerms}";
 #      };
 #      ExtensionSettings = {
 #        "uBlock0@raymondhill.net" = {
 #          install_url =
 #            "https://addons.mozilla.org/firefox/downloads/file/4531307/ublock_origin-1.65.0.xpi";
 #          installation_mode = "force_installed";
 #        };
	# "jetpack-extension@dashlane.com" = {
	#   install_url = "https://addons.mozilla.org/firefox/downloads/file/4509595/dashlane-6.2524.0.xpi";
	#   installation_mode = "force_installed";
	# };
 #      };
 #    };
 #    profiles.basileb.settings = {
 #      "zen.view.compact.hide-tabbar" = {
 #        "Value" = false;
 #        "Locked" = true;
 #      };
 #    };
  };
}
