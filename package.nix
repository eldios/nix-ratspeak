{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  cargo-tauri,
  alsa-lib,
  dbus,
  glib-networking,
  libayatana-appindicator,
  libsoup_3,
  openssl,
  pcsclite,
  perl,
  pkg-config,
  udev,
  webkitgtk_4_1,
  wrapGAppsHook4,
}:

let
  # Ratspeak resolves its protocol crates by relative path from sibling
  # checkouts (../rsReticulum and friends). Upstream does not tag the
  # siblings together with every app release, so each one is pinned to the
  # revision current at the v1.0.25 release date.
  rsReticulum = fetchFromGitHub {
    owner = "ratspeak";
    repo = "rsReticulum";
    rev = "49aa33db1bbe8c7d93b12c4e8fa378ba5060376e";
    hash = "sha256-tCDB94+CdcTVAoJdtf11/MZ9oaBFPaNwwuNWQZHXBo8=";
  };
  rsLXMF = fetchFromGitHub {
    owner = "ratspeak";
    repo = "rsLXMF";
    rev = "4a0abec3b4c90550987c5fc0c3cde024b7ace2a7";
    hash = "sha256-w1s7K+IBQb9FH/kHH8Vy7+8aoXcTFhDQskUpdUMm3OE=";
  };
  rsLXST = fetchFromGitHub {
    owner = "ratspeak";
    repo = "rsLXST";
    rev = "22ad7c89b8aceabaa13d2fd7e898617bde044d25";
    hash = "sha256-SaH14Z76ey/ZtdsXNRVxBsOGvAx/HJzJEyE2DSdG18s=";
  };
  lrgp-rs = fetchFromGitHub {
    owner = "ratspeak";
    repo = "lrgp-rs";
    rev = "88c8665e1e7e1ad710e53e8da6425f3dbe4f5856";
    hash = "sha256-SgdQZpVmJjB/g1OnW2/Gx3fwtrcUC+2UQy88gvMTDUw=";
  };
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ratspeak";
  version = "1.0.32";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "ratspeak";
    repo = "Ratspeak";
    tag = "v${finalAttrs.version}";
    hash = "sha256-oGCCJsnPffzi80e2uqQwS+it5W+NhbggU1DpMIFEm5k=";
  };

  # The app expects the protocol repos next to its own checkout.
  postUnpack = ''
    cp -r ${rsReticulum} rsReticulum
    cp -r ${rsLXMF} rsLXMF
    cp -r ${rsLXST} rsLXST
    cp -r ${lrgp-rs} lrgp-rs
    chmod -R u+w rsReticulum rsLXMF rsLXST lrgp-rs
  '';

  cargoHash = "sha256-dEH18883HkpYj0HhSDhCneFTrBR+vXyqGrsZKZX+lzM=";
  cargoRoot = "src-tauri";
  buildAndTestSubdir = finalAttrs.cargoRoot;

  nativeBuildInputs = [
    cargo-tauri.hook
    perl
    pkg-config
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ wrapGAppsHook4 ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib
    dbus
    glib-networking
    libayatana-appindicator
    libsoup_3
    openssl
    pcsclite
    udev
    webkitgtk_4_1
  ];

  # The dashboard ships modular CSS; the app serves the concatenated file.
  preBuild = ''
    bash dashboard/build-css.sh
  '';

  # The tray icon library is dlopened at runtime, not linked.
  preFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    gappsWrapperArgs+=(
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libayatana-appindicator ]}
    )
  '';

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Reticulum and LXMF client with messaging, file sharing, voice calls and LoRa support";
    homepage = "https://github.com/ratspeak/Ratspeak";
    changelog = "https://github.com/ratspeak/Ratspeak/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "ratspeak";
  };
})
