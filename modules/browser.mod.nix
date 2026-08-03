{
  self,
  lib,
  inputs,
  config,
  ...
}:
let
  defaultBrowser = config.my.defaultBrowser;

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
in
{
  options.my.defaultBrowser = lib.mkOption {
    type = lib.types.enum [
      "helium"
      "zen-twilight"
    ];
    default = "helium";
    description = "Global default browser. Controls my.browser default and WEB_BROWSER env var on all desktop hosts.";
  };

  config = {
    flake.homeModules.helium = { pkgs, ... }: {
      home.packages = [
        inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    };

    flake.homeModules.zen = { ... }: {
      imports = [ inputs.zen-browser.homeModules.twilight ];
      programs.zen-browser.enable = true;
    };

    flake.homeModules.desktop = self.homeModules.browser;
    flake.homeModules.browser =
      { config, lib, ... }:
      let
        inherit (lib.attrsets) genAttrs;
        inherit (lib.trivial) const;
      in
      {
        imports = [
          self.homeModules.helium
          self.homeModules.zen
        ];

        options.my.browser = lib.mkOption {
          type = lib.types.enum [
            "helium"
            "zen-twilight"
          ];
          default = defaultBrowser;
          description = "Default browser for this host. Both browsers are always installed.";
        };

        config = {
          home.sessionVariables.WEB_BROWSER = config.my.browser;

          xdg.mimeApps.defaultApplications = genAttrs mimeTypes (const "${config.my.browser}.desktop");
        };
      };
  };
}
