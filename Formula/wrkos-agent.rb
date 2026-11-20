# frozen_string_literal: true

require "language/node"

class WrkosAgent < Formula
  desc "WrkOS agent bridge — run Cursor Ultra turns on this Mac"
  homepage "https://www.npmjs.com/package/wrkos-agent"
  # Public npm tarball — HTTPS only. CI replaces url/sha256/version on each release.
  # Never point url at http:// or an unsigned mirror (supply-chain / hijack risk).
  url "https://registry.npmjs.org/wrkos-agent/-/wrkos-agent-0.1.4.tgz"
  # Checksum of the previous published tarball. CI overwrites this when
  # local-agent-v0.1.4 is published to npm as wrkos-agent.
  sha256 "a607d399b4d6dcb61caafc95681a220e868372626308193eb9587c3fb15c6a48"
  license "MIT"
  version "0.1.4"

  depends_on "node@22"

  def install
    # Fail closed if a Formula edit swaps in a cleartext or non-npm mirror.
    unless stable.url.start_with?("https://registry.npmjs.org/wrkos-agent/")
      odie "Refusing install: Formula url must be the official HTTPS npm tarball " \
           "(https://registry.npmjs.org/wrkos-agent/…). Got: #{stable.url}"
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
      WrkOS agent bridge installed as `wrkos-agent`.

        wrkos-agent pair --api https://YOUR_WRKOS_API --code CODE
        wrkos-agent start

      `start` opens the localhost control panel and connects to WrkOS.
      Leave that process running.

      Security:
        • Pair only with an https:// WrkOS API URL (http:// allowed for localhost only).
        • Cursor keys stay on this Mac; the bridge dials out — nothing inbound.
        • Control UI is localhost-only (127.0.0.1:4731).

      State: ~/.wrkos-agent (an existing ~/.wrkos-local-agent is still read).
      Override with WRKOS_AGENT_HOME.
    EOS
  end

  test do
    assert_match "Usage", shell_output("#{bin}/wrkos-agent 2>&1", 1)
    # CLI must refuse cleartext remote APIs (hijack guard).
    output = shell_output("#{bin}/wrkos-agent pair --api http://evil.example --code DUMMY 2>&1", 1)
    assert_match(/https/i, output)
  end
end
