{
  description = "timraymond's Nix templates";

  outputs = {self}:
  {
    templates = {
      go = {
        path = ./go;
        description = "A basic Go template";
      };
      tla = {
        path = ./tla;
        description = "A template for TLA+ specifications";
      };
    };
  };
}
