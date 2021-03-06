This repository contains a simple fix for Java applications being unable to open external applications in Linux Snapcraft confinement.

Applications are expected to make use of xdg-desktop-portals in order communicate with the operating system in Flatpaks and Snaps. Unfortunately Java interfaces directly with GIO/GVFS which does not currently have portal support, and so the LD_PRELOAD trick is used to instead send these requests to core snaps xdg-open, which itself forwards onto the OS via the portals API. 

This fix has various assumptions:
* The snap is not using the Gnome 3 extensions. It explicitly will fail in this scenario. Consider using Snapcraft Desktop Helpers in GTK2 mode which Java supports fine.
* The library is added to LD_PRELOAD, the desktop helpers do not do this automatically. The library can be found at $SNAP/usr/lib/g_app_info_launch_default_for_uri.so
* The OS has xdg-desktop-portal support
* The desktop interface is connected
* The was tested on an Ubuntu 20.04 host, running a core18 snap with Java 11, with GTK2 Snapcraft Desktop Helpers as a template.

Note that without the LD_PRELOAD set, adding GVFS to the library search path is enough to get http/https URI's working. However file URI's won't work without LD_PRELOAD configured.

Furthermore, in order to prevent unexpectedly locking any UI threads whilst xdg-portal UI's are enabled, this patch runs asynchronously and will unconditionally return success to the JRE, even if the request is actually rejected. I see this as preferable to potentially giving the user the illusion an app has crashed, or perhaps preventing important operations on a main thread that may cause unexpected beaviour.

In short, to use this patch in a snapcraft.yaml, include stanza's akin to the following.

```
parts:
  java-portals-snap-patch:
    plugin: make
    source: https://github.com/mrcarroll/java-portals-snap-patch.git
    source-type: git
    stage-packages: 
      - gvfs
    organize:
      'usr/lib/*/gvfs/*.so': 'usr/lib'
      
environment:
  LD_PRELOAD: ${SNAP}/usr/lib/g_app_info_launch_default_for_uri.so
```
