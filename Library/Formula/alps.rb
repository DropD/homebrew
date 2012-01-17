require 'formula'

class Alps < Formula
  url 'http://alps.comp-phys.org/static/software/releases/alps-2.0.2-r5790-src.tar.gz'
  head 'http://alps.comp-phys.org/static/software/releases/alps-nightly-src.tar.gz'
  homepage 'http://alps.comp-phys.org/mediawiki/index.php/Main_Page'
  md5 '18a3e859eb0775aadf0a65d26d22a51c'
  version '2.0.2'

  depends_on 'cmake' => :build
  depends_on 'boost'
  depends_on 'hdf5' # needs 1.8.2 or higher, as of now, formula is 1.8.7

  def options
  [
    ["--without-applications", "Don't build the ALPS applications."],
    ["--without-examples", "Don't build ALPS examples."],
    ["--without-python", "Don't build ALPS python extensions."],
    ["--without-tests", "Don't build ALPS tests."],
    ["--with-fortran", "Build ALPS Fortran Binaries (currently TEBD)."],
    ["--without-mpi", "Disable MPI parallelization in ALPS."],
    ["--with-omp", "Enable OpenMP parallelization in ALPS."],
    ["--without-shared", "Don't build the ALPS shared libraries."],
  ]
  end

  def caveats
      return <<-EOS
        Note: for python support without VisTrails, you will need the following python packages:
            * numpy
            * scipy
            * matplotlib
        Look at the homepage to learn more about how to use ALPS with VisTrails.
      EOS
  end

  def install
    args = std_cmake_parameters.split
    test_bool = true

    if ARGV.include? "--without-applications"
      args << "-DALPS_BUILD_APPLICATIONS=OFF"
    end
    if ARGV.include? "--without-examples"
      args << "-DALPS_BUILD_APPLICATIONS=OFF"
    end
    if ARGV.include? "--without-python"
      args << "-DALPS_BUILD_PYTHON=OFF"
    end
    if ARGV.include? "--without-tests"
      args << "DALPS_BUILD_TESTS=OFF"
      test_bool = false
    end
    if ARGV.include? "--with-fortran"
      args << "DALPS_BUILD_FORTRAN=ON"
      if ARGV.include? "--with-omp"
        args << "DALPS_Fortran_FLAGS='-fopenmp'"
      end
    end
    if ARGV.include? "--without-mpi"
      args << "DALPS_ENABLE_MPI=OFF"
    end
    if ARGV.include? "--with-omp"
      args << "DALPS_ENABLE_OPENMP=ON"
    end
    if ARGV.include? "--without-shared"
      args << "DBUILD_SHARED_LIBS=OFF"
    end
    # system "./configure", "--disable-debug", "--disable-dependency-tracking",
    #                       "--prefix=#{prefix}"
    system "mkdir build"
    args << "../alps"
    Dir.chdir 'build' do
      system "cmake", *args
      system "make"
      if ARGV.include? "--without-tests"
      else
          system "make test"
      end
      system "make install"
    end
    Dir.chdir "#{bin}" do
      system "chmod 755 *"
    end
    Dir.chdir "#{lib}/python/alps" do
      system "chmod 755 *"
    end
  end

  def test
    ohai "testing was included in the build process,"
    ohai "provided you didn't build with --without-tests."
  end
end
