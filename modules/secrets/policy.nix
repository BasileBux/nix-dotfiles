let
  personalHosts = [
    "simon"
    "kamina"
    "genome"
    "yoko"
  ];
  envNames = [
    "api-keys/anthropic"
    "api-keys/deepseek"
    "api-keys/exa"
    "api-keys/gemini"
    "api-keys/google-generative-ai"
    "api-keys/moonshot"
    "api-keys/nvidia"
    "api-keys/openai"
    "api-keys/openrouter"
    "api-keys/tavily"
    "api-keys/typesafe"
    "api-keys/xai"
    "api-keys/zai"
    "github-token"
    "rad-passphrase"
  ];
in
builtins.listToAttrs (
  map (name: {
    name = "modules/secrets/env/${name}.age";
    value = {
      hosts = personalHosts;
      owner = "primary-user";
    };
  }) envNames
)
// {
  "modules/smb/synology.age" = {
    hosts = [
      "simon"
      "genome"
    ];
    owner = "root";
  };
  "packages/fonts/TX-02/tx-02.tar.gz.age" = {
    hosts = [ "simon" ];
    owner = "primary-user";
  };
}
