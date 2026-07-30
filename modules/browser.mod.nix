{
  self,
  lib,
  inputs,
  ...
}:
{
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
          default = "helium";
          description = "Default browser (WEB_BROWSER env var). Both browsers are always installed.";
        };

        config = lib.mkIf (config.my.settings.desktop != null) {
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
        config = lib.mkIf (osConfig.my.settings.desktop != null) {
          programs.zen-browser.enable = true;
          home.sessionVariables.WEB_BROWSER = osConfig.my.browser;
        };
      };
  };
}
