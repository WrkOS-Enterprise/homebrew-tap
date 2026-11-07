# frozen_string_literal: true

require "language/node"

class WrkosLocalAgent < Formula
  desc "WrkOS Local Agents bridge — run Cursor Ultra turns on this Mac"
  homepage "https://www.npmjs.com/package/wrkos-local-agent"
  # Public npm tarball — HTTPS only. CI replaces url/sha256/version on each release.
  # Never point url at http:// or an unsigned mirror (supply-chain / hijack risk).
  url "https://registry.npmjs.org/wrkos-local-agent/-/wrkos-local-agent-0.1.0.tgz"
  sha256 "0000000000000000000000000000000000000000000000000000000000000000"
  license "MIT"
  version "0.1.0"

  depends_on "node@22"

  def install
    # Fail closed if a Formula edit swaps in a cleartext or non-npm mirror.
    unless stable.url.start_with?("https://registry.npmjs.org/wrkos-local-agent/")
      odie "Refusing install: Formula url must be the official HTTPS npm tarball " \
           "(https://registry.npmjs.org/wrkos-local-agent/…). Got: #{stable.url}"
    end
    if stable.checksum.hexdigest == ("0" * 64)
      odie "Refusing install: Formula sha256 is still the placeholder. " \
           "Publish a release (local-agent-v*) so CI fills a real checksum."
    end

    ENV.prepend_path "PATH", Formula["node@22"].opt_bin
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  def caveats
    <<~EOS
      WrkOS Local Agents bridge installed as `wrkos-local-agent`.

        wrkos-local-agent ui
        wrkos-local-agent pair --api https://YOUR_WRKOS_API --code CODE
        wrkos-local-agent start

      Security:
        • Pair only with an https:// WrkOS API URL (http:// allowed for localhost only).
        • Cursor keys stay on this Mac; the bridge dials out — nothing inbound.
        • Control UI is localhost-only (127.0.0.1:4731).
        • See SECURITY.md in this tap for the threat model.

      State: ~/.wrkos-local-agent (override with WRKOS_LOCAL_AGENT_HOME).
    EOS
  end

  test do
    assert_match "Usage", shell_output("#{bin}/wrkos-local-agent 2>&1", 1)
    # CLI must refuse cleartext remote APIs (hijack guard).
    output = shell_output("#{bin}/wrkos-local-agent pair --api http://evil.example --code DUMMY 2>&1", 1)
    assert_match(/https/i, output)
  end
end
