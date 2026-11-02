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
    rev = "5b38cae702a5b3984adf12a435f6d3012fcf90e1";
    hash = "sha256-ylMT47isbfKwDJPmDoqzaYUfgWdZIkZnBuPupRleijw=";
  };
  rsLXMF = fetchFromGitHub {
    owner = "ratspeak";
    repo = "rsLXMF";
    rev = "b5c3365b5715f1f36f74963a9d2136238d956467";
    hash = "sha256-4lzyNniGFW9GnS3tNNYQgGNy1L4TmXqrDsqAydr0i7o=";
  };
  rsLXST = fetchFromGitHub {
    owner = "ratspeak";
    repo = "rsLXST";
    rev = "8f8e664427b03c4440778bd6b63b65055fd2ad14";
    hash = "sha256-8qLUHVDyGu62Ri6n5fYf/SnH+glNDfSzS4+TUEgERH4=";
  };
  lrgp-rs = fetchFromGitHub {
    owner = "ratspeak";
    repo = "lrgp-rs";
    rev = "660e4cf100a74eec8d3521594d3fb74587de05ef";
    hash = "sha256-5blj3uHqFs4hnIKX49LV2wpLCEutKCM95F7AtrBBNLA=";
  };
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ratspeak";
  version = "1.0.37";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "ratspeak";
    repo = "Ratspeak";
    tag = "v${finalAttrs.version}";
    hash = "sha256-FndmOAR6xPNCqH6U03Fpf7IT8bW/2siKgp4+8M2241U=";
  };

  # The app expects the protocol repos next to its own checkout.
  postUnpack = ''
    cp -r ${rsReticulum} rsReticulum
    cp -r ${rsLXMF} rsLXMF
    cp -r ${rsLXST} rsLXST
    cp -r ${lrgp-rs} lrgp-rs
    chmod -R u+w rsReticulum rsLXMF rsLXST lrgp-rs
  '';

  cargoHash = "sha256-H5alUheqJGXdHlbckqitW6liw4i5e1jWGu0gD5AL+pg=";
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
