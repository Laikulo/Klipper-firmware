# Klipper Firmware Tools
Tools for generating klipper firmware images

## Build Environment Containers

### Build Environment
The `build` container contains a funcitonal toolchain for building klipper on all targets.  
*IMPORTANT*: This environment uses a relatively recent version of newlib, so stm32 configs will fail without a linker patch.

This container is built nightly from OpenSUSE Tumbleweed.

### Factory
This is a build environment container, with a specific version of Klipper present and ready to build.

This container is tagged based on the git revision of klipper it contains.

Entrypoint options:
```
-c The path to the Kconfig to build with
-C The name of a built-in test config to build
-o Output Directory
-d Klipper source tree location
-h This help
-v Verbose builds
-m launch menuconfig
-l list built in configs
```

### Cannery
This is a build environment with a specific version of CanBoot present and ready to build.

The container is tagged basd on the git revision of CanBoot it contains.

Entrypoint options:
```
-c The path to the Kconfig to build with
-o Output Directory
-d CanBoot source tree location
-h This help
-v Verbose builds
-m launch menuconfig
```

## Helper Scripts

### factory-all.sh and cannery-all.sh

Runs factory/cannery for all configurations in the -config directory.  
Not DirSafe.  
Places the results in ./dist/  
Takes a single argument, being the tag to use when running

### latest-\*.sh

Gets the latest git hash of the given component, takes an optional arguments of the repo to interact with, and the ref to look for
