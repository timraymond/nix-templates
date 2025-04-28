{
  description = "Minimal TLA+ development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [
        "aarch64-darwin"
        "x86_64-linux"
      ];
      
      nixpkgsFor = system: import nixpkgs {
        inherit system;
        overlays = [];
      };
      
      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = nixpkgsFor system;
        inherit system;
      });

      # TLA+ toolbox version
      tlaVersion = "1.8.0";
    in
    {
      packages = forEachSupportedSystem ({ pkgs, system }: 
        let
          # Download the TLA+ tools jar
          tla2tools = pkgs.fetchurl {
            url = "https://github.com/tlaplus/tlaplus/releases/download/v${tlaVersion}/tla2tools.jar";
            sha256 = "sha256-nvERYNJDGACGqZ2iFIDFLC6qaO/Y1Jiqe0WsTlJLL0c=";
          };
          
          # Create wrapper scripts for TLA+ tools
          tla-tools = pkgs.stdenv.mkDerivation {
            name = "tla-tools-${tlaVersion}";
            buildInputs = [ pkgs.makeWrapper ];
            dontUnpack = true;
            
            installPhase = ''
              mkdir -p $out/bin $out/share/java
              cp ${tla2tools} $out/share/java/tla2tools.jar
              
              # Create wrapper for the TLC model checker
              makeWrapper ${pkgs.jdk}/bin/java $out/bin/tlc \
                --add-flags "-cp $out/share/java/tla2tools.jar tlc2.TLC"
              
              # Create wrapper for the SANY parser
              makeWrapper ${pkgs.jdk}/bin/java $out/bin/sany \
                --add-flags "-cp $out/share/java/tla2tools.jar tla2sany.SANY"
              
              # Create wrapper for the PlusCal translator
              makeWrapper ${pkgs.jdk}/bin/java $out/bin/pcal \
                --add-flags "-cp $out/share/java/tla2tools.jar pcal.trans"
            '';
          };
        in
        {
          default = tla-tools;
        }
      );
      
      devShells = forEachSupportedSystem ({ pkgs, system }: {
        default = pkgs.mkShell {
          buildInputs = [
            self.packages.${system}.default
            pkgs.jdk
          ];
        };
      });
    };
}
