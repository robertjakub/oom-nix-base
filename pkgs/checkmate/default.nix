{ lib
, fetchFromGitHub
, buildNpmPackage
, nodejs
, libusb1
, makeWrapper
, iputils
,
}:
let
  pname = "checkmate";
  version = "3.2.0";

  src = fetchFromGitHub {
    owner = "bluewave-labs";
    repo = "Checkmate";
    rev = "v${version}";
    sha256 = "sha256-M8YhqaJz2oJ9K7WUEOHZgrc6HK1QY4TYLvU2L5Bby8E=";
  };

  server = buildNpmPackage {
    inherit version;
    pname = "${pname}-server";
    src = "${src}/server";
    nativeBuildInputs = [ nodejs ];
    npmDepsHash = "sha256-8GhliIKx6OTsTaVEHYiTPZYga+ztYbglc0NK2FZkylE=";
    dontNpmBuild = true;
    # postPatch = ''
    #   cp -f ${./package-lock.json.server} package-lock.json
    # '';
  };
in
buildNpmPackage {
  inherit version pname;
  src = "${src}/client";

  nativeBuildInputs = [ nodejs makeWrapper ];
  buildInputs = [ libusb1 ];

  npmDepsHash = "sha256-TsIWJJ0rcwxc+C1Kx+VALcSd9R9Rm0Jqna55uV6z3Gs=";

  # npmFlags = ["--legacy-peer-deps"];

  postPatch = ''
    echo "VITE_APP_API_BASE_URL=/api/v1" > .env.production
    cp -f ${./package-lock.json.client} package-lock.json
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/{client,server}
    (cd dist; cp -r . $out/client)
    cp -r ${server}/lib/node_modules/server $out
    makeWrapper "${nodejs}/bin/node" $out/startserver \
    	--set PATH ${lib.makeBinPath [iputils]};
    runHook postInstall
  '';

  meta = with lib; {
    description = "An open source uptime and infrastructure monitoring application.";
    homepage = "https://checkmate.so";
    license = licenses.agpl3Only;
  };
}
