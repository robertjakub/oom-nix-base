{ lib
, fetchFromGitHub
, buildGoModule
,
}:
let
  pname = "checkmate-capture";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "bluewave-labs";
    repo = "capture";
    rev = "v${version}";
    sha256 = "sha256-0c8e8RG7Sx5giq+XL6TQu/EiIcK0XGhqvxN8zZJ4ibs=";
  };
in
buildGoModule {
  inherit pname version src;

  modRoot = "./.";
  vendorHash = "sha256-XE011U2sI1kj7VnMjhZoxWakXMQGhIuFSCYUIjhefOQ=";
  proxyVendor = true;
  doCheck = false;

  meta = with lib; {
    description = "An open source hardware monitoring agent.";
    homepage = "https://github.com/bluewave-labs/capture";
    license = licenses.agpl3Only;
  };
}
