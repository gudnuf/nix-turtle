{
  config,
  pkgs,
  user,
  ...
}:

{
  home = {
    username = user;
    homeDirectory = "/home/${user}";
    stateVersion = "24.05";
    packages = with pkgs; [
      holesail
    ];
    sessionVariables = {
      EDITOR = "nvim";
    };
    sessionPath = [ "${pkgs.holesail}/bin" ];
  };

  programs.git = {
    enable = true;
    userName = "gudnuf";
    userEmail = "gudnuf21@proton.me";
  };

  programs.home-manager.enable = true;
}
