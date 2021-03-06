class Terminator < Formula
  desc "Multiple terminals in one window"
  homepage "http://gnometerminator.blogspot.co.uk/p/introduction.html"
  url "https://launchpad.net/terminator/trunk/0.97/+download/terminator-0.97.tar.gz"
  sha256 "9131847023fa22f11cf812f6ceff51b5d66d140b6518ad41d7fa8b0742bfd3f7"

  bottle do
    cellar :any
    revision 1
    sha256 "db25b36de9844473fddd6afa620fc5a4719fd5908e1c6afa74a6b792f6b88985" => :yosemite
    sha256 "16fae780f572189db5b84d86a89c22260e5aa456e7a1941ebb8331aa2bfb1c33" => :mavericks
    sha256 "b0c6d46bc9088520cd271b0e35aad958a6ef4c792fa404a9fbf52d3e3d52de6e" => :mountain_lion
  end

  depends_on "pkg-config" => :build
  depends_on "intltool" => :build
  depends_on :python if MacOS.version <= :snow_leopard
  depends_on "vte"
  depends_on "pygtk"
  depends_on "pygobject"
  depends_on "pango"

  # Patch to fix cwd resolve issue for OS X / Darwin
  # See: https://bugs.launchpad.net/terminator/+bug/1261293
  patch :DATA

  def install
    ENV.prepend_create_path "PYTHONPATH", lib/"python2.7/site-packages"
    system "python", *Language::Python.setup_install_args(prefix)
  end

  def post_install
    system "#{Formula["gtk"].opt_bin}/gtk-update-icon-cache", "-f",
           "-t", "#{HOMEBREW_PREFIX}/share/icons/hicolor"
  end

  test do
    system "#{bin}/terminator", "--version"
  end
end

__END__
diff --git a/terminatorlib/cwd.py b/terminatorlib/cwd.py
index 7b17d84..e3bdbad 100755
--- a/terminatorlib/cwd.py
+++ b/terminatorlib/cwd.py
@@ -49,6 +49,11 @@ def get_pid_cwd():
         func = sunos_get_pid_cwd
     else:
         dbg('Unable to determine a get_pid_cwd for OS: %s' % system)
+        try:
+            import psutil
+            func = generic_cwd
+        except (ImportError):
+            dbg('psutil not found')

     return(func)

@@ -71,4 +76,9 @@ def sunos_get_pid_cwd(pid):
     """Determine the cwd for a given PID on SunOS kernels"""
     return(proc_get_pid_cwd(pid, '/proc/%s/path/cwd'))

+def generic_cwd(pid):
+    """Determine the cwd using psutil which also supports Darwin"""
+    import psutil
+    return psutil.Process(pid).as_dict()['cwd']
+
 # vim: set expandtab ts=4 sw=4:
