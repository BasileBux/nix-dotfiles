# Workaround for nixpkgs bug: pi-coding-agent 1.5.0's postInstall omits the
# @earendil-works/pi-schema workspace package (new runtime dep of pi-ai /
# pi-agent-core in 1.5.0), breaking subagent child-session startup.
# See nixpkgs #583791 and fix PR #582756. Drop this once the fix lands
# upstream and our nixpkgs pin advances past it.
{ self, ... }: {
  flake.module.pi-fix = {
    nixos = { ... }: {
      nixpkgs.overlays = [
        (final: prev: {
          pi-coding-agent = prev.pi-coding-agent.overrideAttrs (old: {
            postInstall = (old.postInstall or "") + ''
              cp -r packages/schema "$out/lib/node_modules/pi-monorepo/node_modules/@earendil-works/pi-schema"
            '';
          });
        })
      ];
    };
  };
}
