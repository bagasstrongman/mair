{ pkgs, lib, ... }:
{
  # Nix configuration ------------------------------------------------------------------------------

  nix.binaryCaches = [
    "https://cache.nixos.org/"
  ];
  nix.binaryCachePublicKeys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
  ];
  nix.trustedUsers = [
    "@admin"
  ];
  users.nix.configureBuildUsers = true;

  # Enable experimental nix command and flakes
  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
                 auto-optimise-store = true
                 experimental-features = nix-command flakes
                 ''
    + lib.optionalString (pkgs.system == "aarch64-darwin") ''
                 extra-platforms = x86_64-darwin aarch64-darwin
                 '';
  };

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.zsh.enable = true;

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  # Apps
  # `home-manager` currently has issues adding them to `~/Applications`
  # Issue: https://github.com/nix-community/home-manager/issues/1341
  environment.systemPackages = with pkgs; [
    kitty
    terminal-notifier
  ];

  # https://github.com/nix-community/home-manager/issues/423
  environment.variables = {
    TERMINFO_DIRS = "${pkgs.kitty.terminfo.outPath}/share/terminfo";
  };

  # Fonts
  fonts = {
    enableFontDir = true;
    fonts = with pkgs; [
      corefonts
      inconsolata ubuntu_font_family dejavu_fonts
      lmodern source-code-pro
      fira fira-code fira-code-symbols
      noto-fonts noto-fonts-cjk noto-fonts-emoji
      wqy_microhei wqy_zenhei
    ];
  };

   system = {
    defaults = {
      trackpad.Clicking = true;
      trackpad.TrackpadThreeFingerDrag = true;
    };

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
  };

  # Add ability to used TouchID for sudo authentication
  security.pam.enableSudoTouchIdAuth = true;

}
