{
  description = "An enhanced timer cli utility";

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
        default = self.packages.${system}.chime;

        ## make derivation for the package
        chime = pkgs.stdenv.mkDerivation {
          name = "enhanced-timer";
          version = "1.0";
          src = ./.;

          # defining requird dependencies
          buildInputs = with pkgs; [
            ncurses # for tput
            pulseaudio # for paplay
            libnotify # for notification
          ];
          installPhase = ''
            mkdir -p $out/bin
            cp chime.sh $out/bin/chime
            chmod +x $out/bin/chime
          '';
        };
      };

      apps = {
        default = self.apps.${system}.chime;
        chime = {
          type = "app";
          program = "${self.packages.${system}.chime}/bin/chime";
        };
      };

      # dev shell with additional deps ( if required )
      devShells.default = pkgs.mkShell {
        buildInputs =
          self.packages.${system}.chime.buildInputs
          ++ [
            pkgs.shellcheck # for script linting
          ];
      };
    });
}
