# What is GYMIR ? 

GYMIR is a GPL implementation of the Ymir compiler that use the GCC as a back end.

# Compilation for local usage and tests

```bash
# installing dependencies

sudo apt install gcc-9
curl https://www.gitlab.emile-cadorel.fr/9.3.0/${arch}/gyc-9_9.3.0_${arch}.deb
curl https://www.gitlab.emile-cadorel.fr/9.3.0/${arch}/libgmidgard_9.3.0_${arch}.deb
sudo dpkg -i gyc-9_9.3.0_${arch}.deb
sudo dpkg -i libgmidgard_9.3.0_${arch}.deb

# Create source directories

mkdir {install_dir}/gcc
cd {install_dir}/gcc
mkdir gcc-src
mkdir gcc-build
mkdir gcc-install

# cloning gcc
git clone --depth=1 git://gcc.gnu.org/git/gcc.git gcc-src
cd {install_dir}/gcc/gcc-src
git fetch --tags --depth=1
git checkout releases/gcc-{version}

# cloning ymir bootstrap - master revision
cd {install_dir}/gcc/gcc-src/gcc
git clone --depth=1 https://github.com/GNU-Ymir/bootstrap.git ymir

# install deps
cd {install_dir}/gcc/gcc-src/gcc
./contrib/download_prerequisites

# configure
cd {install_dir}/gcc/gcc-build
../gcc-src/configure --prefix={install_dir}/gcc/gcc-build/../gcc-install --enable-languages=c,ymir --disable-bootstrap --disable-multilib

# compile
make
make install

# export path
export PATH=${PATH}:{install_dir}/gcc/gcc-install/bin:.
```

The compiler is know compiled and ready for debugging.
All the source code of ymir are located in {install_dir}/gcc/gcc-src/gcc/ymir/.
Simply running:

```bash
cd {install_dir}/gcc/gcc-build
make
make install
```
Will update the gyc command.

**Warning** some modification of ymir may require to recompile every
  ymir files. To remove all precompiled file, and make sure everything
  is correct, you will have to run :

```bash
cd {install_dir}/gcc/gcc-build
rm gcc/ymir/*.o # remove old object files
make
make install
```

To be fully usable, you will have to compile the runtime locally [Runtime](https://github.com/GNU-Ymir/yruntime).

# Compilation for release

The repository [Ymir-Docker](https://github.com/GNU-Ymir/Ymir-Docker) is the repository used to create releases of gyc.