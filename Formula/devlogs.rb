class Devlogs < Formula
  desc "Project based logging"
  homepage "https://github.com/aquaflamingo/devlogs"
  url "https://github.com/aquaflamingo/devlogs/archive/v0.1.6.tar.gz"
  sha256 ""

  depends_on "ruby" 

  def install
    ENV["GEM_HOME"] = libexec
    resources.each do |r|
      r.verify_download_integrity(r.fetch)
      system "gem", "install", r.cached_download, "--ignore-dependencies",
             "--no-document", "--install-dir", libexec
    end
    system "gem", "build", "devlogs.gemspec"
    system "gem", "install", "--ignore-dependencies", "devlogs#{version}.gem"
    bin.install "exe/devlogs"
    bin.env_script_all_files(libexec/"exe", :GEM_HOME => ENV["GEM_HOME"])
    libexec.install Dir["*"]
  end

  test do
    output = shell_output("#{bin}/devlogs version 2>&1", 1)
    assert_match "Running version 0.1.5", output
  end
end
