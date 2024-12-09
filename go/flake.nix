{
  description = "Example flake for Go";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.11";
  };

  outputs = { self, nixpkgs }:
  let
    supportedSystems = [ "x86_64-linux" "x86_64-darwin" ];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
  in
  {
    packages = forAllSystems (system:
      let
        pkgs = nixpkgsFor.${system};
      in
      {
        default = pkgs.buildGoModule {
          pname = "example";
          version = "0.0.1";
          src = ./.;
          vendorHash = pkgs.lib.fakeHash;
          proxyVendor = true;
        };
    });
    devShells = forAllSystems (system:
      let
        pkgs = nixpkgsFor.${system};
      in
      {
        default = pkgs.mkShell {
          buildInputs = with pkgs; [
            go
            gopls
          ];
        };
      }
    );
  };
}
