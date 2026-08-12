{
  self,
  lib,
  inputs,
  ...
}:
let
  mimeTypes = [
    "application/rdf+xml"
    "application/rss+xml"
    "application/xhtml+xml"
    "application/xhtml_xml"
    "application/xml"
    "text/html"
    "text/xml"
    "x-scheme-handler/http"
    "x-scheme-handler/https"
    "x-scheme-handler/about"
    "x-scheme-handler/unknown"
  ];
  browserOptionModule = {
    options.my.defaultBrowser = lib.mkOption {
      type = lib.types.enum [
        "helium"
        "zen-twilight"
      ];
      default = "helium";
      description = "Global default browser and WEB_BROWSER env var on all desktop hosts.";
    };
  };
in
{
  config.flake.module.helium = {
    home = { pkgs, ... }: {
      home.packages = [
        inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    };
  };

  config.flake.module.zen = {
    home = { ... }: {
      imports = [ inputs.zen-browser.homeModules.twilight ];
      programs.zen-browser.enable = true;
    };
  };

  config.flake.module.browser = {
    nixos = browserOptionModule;
    home =
      {
        lib,
        osConfig,
        ...
      }:
      let
        inherit (lib.attrsets) genAttrs;
        inherit (lib.trivial) const;
        defaultBrowser = osConfig.my.defaultBrowser;
      in
      {
        imports = [
          self.flakeModules.helium.home
          self.flakeModules.zen.home
        ];

        config = {
          home.sessionVariables.WEB_BROWSER = defaultBrowser;

          xdg.mimeApps.defaultApplications = genAttrs mimeTypes (const "${defaultBrowser}.desktop");
        };
      };
  };
}
