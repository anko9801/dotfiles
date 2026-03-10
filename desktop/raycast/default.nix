{ config, pkgs, ... }:

let
  rayconfig =
    pkgs.runCommand "raycast.rayconfig"
      {
        nativeBuildInputs = with pkgs; [
          openssl
          gzip
        ];
        src = ./raycast.json;
        header = ./header.bin;
      }
      ''
        cat "$src" | gzip | cat "$header" - \
          | openssl enc -e -aes-256-cbc -nosalt -md sha256 -k "12345678" -out "$out"
      '';
in
{
  home-manager.users.${config.system.primaryUser}.home.file = {
    "Documents/raycast.rayconfig" = {
      source = rayconfig;
      onChange = ''open "$HOME/Documents/raycast.rayconfig"'';
    };
  };

  system.defaults.CustomUserPreferences."com.raycast.macos" = {
    # Appearance
    raycastShouldFollowSystemAppearance = true;
    raycastPreferredWindowMode = "default";

    # Hotkey: Option+Space
    raycastGlobalHotkey = "Option-49";

    # Window behavior
    raycastWindowPresentationMode = 0;
    raycastWindowEscapeKeyBehavior = 0;
    raycastAlternativeEscape = false;
    keepWindowVisibleOnResignKey = false;
    popToRootTimeout = 90;

    # Navigation
    navigationCommandStyleIdentifierKey = "macos";
    showFavoritesInCompactMode = true;

    # UI
    useHyperKeyIcon = false;
    showGettingStartedLink = false;
    "onboarding_showTasksProgress" = false;
  };
}
