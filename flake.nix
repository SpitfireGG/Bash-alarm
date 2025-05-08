{
  description = "An enhanced timer in bash";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      packages = {
        default = self.packages.${system}.timer;

        ## make derivation for the package
        timer = pkgs.stdenv.mkDerivation {
          name = "enhanced-timer";
          version = "1.0";
          src = ./.;

          # defining requird dependencies
          buildInputs = with pkgs; [
            bash
            coreutils  # for basic toolings
            ncurses # for tput
            pulseaudio # for paplay
            libnotify # for notification
          ];
          installPhase = ''
            mkdir -p $out/bin
            cp timer.sh $out/bin/timer
            chmod +x $out/bin/timer
          '';
        };
      };

      apps = {
        default = self.apps.${system}.timer;
        timer = {
          type = "app";
          program = "${self.packages.${system}.timer}/bin/timer";
        };
      };

      # dev shell with additional deps ( if required )
      devShells.default = pkgs.mkShell {
        buildInputs =
          self.packages.${system}.timer.buildInputs
          ++ [
            pkgs.shellcheck # for script linting
          ];
      };
    });
}
