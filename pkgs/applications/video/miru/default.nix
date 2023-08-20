{ appimageTools, lib, fetchurl }:
appimageTools.wrapType2 rec {
  pname = "miru";
  name = pname;
  version = "3.11.6";

  src = fetchurl {
    url = "${meta.homepage}/releases/download/v${version}/linux-Miru-${version}.AppImage";
    hash = "0abc03c5a8cf9557309d054d2281b4267951f5d929c8ee11d4f015ed335ef2f2";
  };

  extraInstallCommands =
    let
      contents = appimageTools.extractType2 { name = "linux-Miru-${version}.AppImage"; inherit src; };
    in
    ''
      mkdir -p "$out/share/applications"
      mkdir -p "$out/share/lib/miru"
      cp -r ${contents}/{locales,resources} "$out/share/lib/miru"
      cp -r ${contents}/usr/* "$out"
      cp "${contents}/${pname}.desktop" "$out/share/applications/"
      substituteInPlace $out/share/applications/${pname}.desktop --replace 'Exec=AppRun' 'Exec=${pname}'
    '';

  meta = with lib; {
    description = "Bittorrent streaming software for cats. Stream anime torrents, real-time with no waiting for downloads (If xdg-open isn't working on login, try using ungoogled-chromium)";
    homepage = "https://github.com/ThaUnknown/miru";
    license = lib.licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ lyonsyonii ];
  };
}
