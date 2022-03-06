{ config, pkgs, lib, ... }:

{
  home = {
    stateVersion = "22.05";
    packages = with pkgs; [
      # Some basics
      coreutils
      curl wget
      tmux nox
      htop

      # Dev stuff
      whois
      kubectl
      ripgrep-all
      watch
      terraform

      awscli2
      google-cloud-sdk

      jq
      nodePackages.typescript
      nodejs

      # Useful nix related tools
      cachix # adding/managing alternative binary caches hosted by Cachix
      # comma # run software from without installing it
      nodePackages.node2nix

      # Documents
      texlive.combined.scheme-full
      imagemagick
      poppler_utils
      pandoc

    ] ++ lib.optionals stdenv.isDarwin [
      cocoapods
      m-cli # useful macOS CLI commands
    ];

    sessionVariables.SSH_AUTH_SOCK = "$(\${pkgs.gnupg}/bin/gpgconf --list-dirs agent-ssh-socket)";
    file.".gnupg/gpg-agent.conf".text = ''
                                      max-cache-ttl 18000
                                      default-cache-ttl 18000
                                      pinentry-program ${pkgs.pinentry_mac}/Applications/pinentry-mac.app/Contents/MacOS/pinentry-mac
                                      enable-ssh-support
                                      '';
  };
  # https://github.com/malob/nixpkgs/blob/master/home/default.nix

  # Direnv, load and unload environment variables depending on the current directory.
  # https://direnv.net
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.direnv.enable
  programs = {
    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    # Htop
    # https://rycee.gitlab.io/home-manager/options.html#opt-programs.htop.enable
    htop = {
      enable = true;
      settings.show_program_path = true;
    };

    git = {
      enable = true;
      package = pkgs.gitAndTools.gitFull;
      userEmail = "source@proof.construction";
      userName = "alex";
      extraConfig = {
        core = {
          editor = "emacs";
        };
      };
    };

    gpg.enable = true;

    password-store = {
      enable = true;
      package = pkgs.pass;
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    tmux = {
      enable = true;
      #terminal = "";
      keyMode = "emacs";
      escapeTime = 10;
      prefix = "C-b";
    };

    zsh = {
      enable = true;
      profileExtra = ''
                   export EDITOR=emacs
                   '';
      enableAutosuggestions = true;
      enableCompletion = true;
      autocd = true;
      defaultKeymap = "emacs";
      dotDir = ".config/zsh";
      history = {
        extended = true;
        share = true;
      };
      oh-my-zsh = {
        enable = true;
        plugins = [ "git" "sudo" ];
        theme = "lambda";
      };
    };
  };

  # Misc configuration files --------------------------------------------------------------------{{{

  # https://docs.haskellstack.org/en/stable/yaml_configuration/#non-project-specific-config
  home.file.".stack/config.yaml".text = lib.generators.toYAML {} {
    templates = {
      scm-init = "git";
      params = {
        author-name = "Your Name"; # config.programs.git.userName;
        author-email = "youremail@example.com"; # config.programs.git.userEmail;
        github-username = "yourusername";
      };
    };
    nix.enable = true;
  };

}
