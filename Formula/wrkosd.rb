# frozen_string_literal: true

class Wrkosd < Formula
  desc "WrkOS protocol-v2 host daemon for remote workspaces"
  homepage "https://www.npmjs.com/package/@wrkos/wrkosd"
  # Public npm tarball — HTTPS only. CI replaces url/sha256 on each wrkosd-v* release.
  # Homebrew reads the version from the tarball name. Never point url at http://
  # or an unsigned mirror (supply-chain / hijack risk).
  url "https://registry.npmjs.org/@wrkos/wrkosd/-/wrkosd-0.1.1.tgz"
  # Checksum of the published @wrkos/wrkosd@0.1.1 tarball.
  sha256 "f08e17ba811ef7aae70de2b5382fb8590e35d7356e335244180d961fcd868c2b"
  license "MIT"

  depends_on "node@24"

  def install
    unless stable.url.start_with?("https://registry.npmjs.org/@wrkos/wrkosd/")
      odie "Refusing install: Formula url must be the official HTTPS npm tarball " \
           "(https://registry.npmjs.org/@wrkos/wrkosd/…). Got: #{stable.url}"
    end
    if stable.checksum.hexdigest == ("0" * 64)
      odie "Refusing install: Formula sha256 is still the placeholder. " \
           "Publish a release (wrkosd-v*) so CI fills a real checksum."
    end

    ENV.prepend_path "PATH", formula_opt_bin("node@24")
    # node-pty@1.1.0 has no prebuild; its install script compiles the addon.
    system "npm", "install", *std_npm_args(prefix: libexec, ignore_scripts: false)
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  def caveats
    <<~EOS
      WrkOS host daemon installed as `wrkosd`. Node 24 is required.

        wrkosd pair --api https://YOUR_WRKOS_API --code CODE
        wrkosd service install

      `service install` keeps the daemon running for this user through launchd.
      It does not run as root and it does not open an inbound port.

      Linux servers can use the published image instead:
        ghcr.io/wrkos-enterprise/wrkosd:latest

      State: ~/.wrkosd (mode 0700). Override with WRKOSD_STATE_DIR.
    EOS
  end

  test do
    assert_match "Usage", shell_output("#{bin}/wrkosd 2>&1", 1)
    # CLI must refuse cleartext remote APIs (hijack guard).
    output = shell_output("#{bin}/wrkosd pair --api http://evil.example --code DUMMY 2>&1", 1)
    assert_match(/https/i, output)
  end
end
