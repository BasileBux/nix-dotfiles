{
  self,
  lib,
  inputs,
  config,
  ...
}:
let
  defaultBrowser = config.my.defaultBrowser;
in
{
  options.my.defaultBrowser = lib.mkOption {
    type = lib.types.enum [
      "helium"
      "zen-twilight"
    ];
    default = "helium"; # Set default browser here
    description = "Global default browser. Controls WEB_BROWSER env var on all desktop hosts.";
  };

  config = {
    commonModules.browser =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      {
        options.my.browser = lib.mkOption {
          type = lib.types.enum [
            "helium"
            "zen-twilight"
          ];
          default = defaultBrowser;
          description = "Default browser for this host (WEB_BROWSER env var). Both browsers are always installed.";
        };

        config = lib.mkIf (config.my.settings.desktop) {
          environment.systemPackages = [
            inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default
          ];
        };
      };

    flake.homeModules.browser =
      {
        config,
        lib,
        osConfig,
        ...
      }:
      {
        imports = [ inputs.zen-browser.homeModules.twilight ];
        config = lib.mkIf (osConfig.my.settings.desktop) {
          programs.zen-browser.enable = true;
          home.sessionVariables.WEB_BROWSER = osConfig.my.browser;
        };
      };
  };
}
