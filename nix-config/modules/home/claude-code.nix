{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  # Public-safe base settings, tracked in the repo and used to seed fresh
  # machines. Kept separate from the machine-specific waza keys below.
  settingsTemplate = ../../config/claude/settings.json;
  settingsPath = "${config.home.homeDirectory}/.claude/settings.json";
  marketplacePath = "${config.home.homeDirectory}/.claude/waza-marketplace";
in
{
  programs.claude-code.enable = true;

  # Waza marketplace source (a public GitHub repo, pinned via the `waza` flake
  # input). Exposed at a stable path so settings.json can reference it without a
  # churning /nix/store hash. Read-only is fine: Claude only reads marketplaces.
  home.file.".claude/waza-marketplace".source = inputs.waza;

  # Register the Waza marketplace without home-manager owning settings.json.
  # Claude Code refuses to write through a symlink and rewrites settings.json via
  # atomic rename, so a managed/symlinked settings.json would break runtime writes
  # (theme, model, /plugin). Instead seed from the tracked template on a fresh
  # machine, then merge the two waza keys in idempotently on every activation.
  home.activation.claudeWazaMarketplace = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p "$(dirname ${lib.escapeShellArg settingsPath})"
    if [ ! -e ${lib.escapeShellArg settingsPath} ]; then
      run install -m600 ${settingsTemplate} ${lib.escapeShellArg settingsPath}
    fi
    _waza_tmp="$(mktemp)"
    ${lib.getExe pkgs.jq} \
      --arg path ${lib.escapeShellArg marketplacePath} \
      '.extraKnownMarketplaces.waza = { source: { source: "directory", path: $path } }
       | .enabledPlugins["waza@waza"] = true' \
      ${lib.escapeShellArg settingsPath} > "$_waza_tmp"
    run mv "$_waza_tmp" ${lib.escapeShellArg settingsPath}
  '';
}
