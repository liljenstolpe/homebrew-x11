class Jskeus < Formula
  desc "EusLisp software used by JSK at The University of Tokyo"
  homepage "https://github.com/euslisp/jskeus"
  url "https://github.com/euslisp/jskeus/archive/1.0.10.tar.gz"
  sha256 "038d394438dff837b9268dbec48063b33532669d5786201e2e67433fade371f1"
  head "https://github.com/euslisp/jskeus.git"

  depends_on :x11
  depends_on "jpeg"
  depends_on "libpng"
  depends_on "mesalib-glw"
  depends_on "wget" => :build

  resource "euslisp" do
    url "https://github.com/euslisp/EusLisp/archive/EusLisp-9.16.tar.gz"
    sha256 "1e60ba14d627ecb0f426bd60ea91df971855b2b076efa1c50598b420cab93a08"
  end

  def install
    ENV.deparallelize
    ENV.O0

    # jskeus needs to be compiled in Cellar
    prefix.install "Makefile", Dir["{doc,images,irteus}"]
    (prefix/"eus").install resource("euslisp")

    executables = ["eus", "eus0", "eus1", "eus2", "euscomp", "eusg", "eusgl", "eusx", "irteus", "irteusgl"]

    cd "#{prefix}" do
      system "make"

      executables.each do |exec|
        libexec.install "eus/Darwin/bin/#{exec}"
      end
    end

    bin.mkpath
    executables.each do |exec|
      (bin/exec).write <<-EOS.undent
        #!/bin/bash
        EUSDIR=#{opt_prefix}/eus ARCHDIR=Darwin LD_LIBRARY_PATH=$EUSDIR/$ARCHDIR/bin:$LD_LIBRARY_PATH exec #{libexec}/#{exec} "$@"
      EOS
    end
  end

  test do
    system "#{bin}/eus", "(exit)"
    system "#{bin}/irteusgl", "(exit)"
  end
end