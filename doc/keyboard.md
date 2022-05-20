# Keyboard configuration
https://github.com/free5lot/hid-apple-patched

### Keyboard Layout
`English (US) | Variant English (intl., with AltGr dead keys)`

### Installation via [DKMS](https://en.wikipedia.org/wiki/Dynamic_Kernel_Module_Support) (recommended)

You may need to install git and dkms first, e.g. on Ubuntu: `sudo apt install git dkms`

Clone this repo and go into the source code directory:
```bash
git clone https://github.com/free5lot/hid-apple-patched
cd hid-apple-patched
```
Install module:
```bash
sudo dkms add .
sudo dkms build hid-apple/1.0
sudo dkms install hid-apple/1.0
```
Then, create file `/etc/modprobe.d/hid_apple.conf`. The following configuration emulates a standard PC layout:
```
options hid_apple fnmode=2
options hid_apple swap_fn_leftctrl=1
options hid_apple swap_opt_cmd=1
options hid_apple rightalt_as_rightctrl=1
options hid_apple ejectcd_as_delete=1
```
Finally, apply the new config file:
```bash
sudo update-initramfs -u
```
To (re-)load the module for immediate use, run
```bash
sudo modprobe -r hid_apple; sudo modprobe hid_apple
```
in one go (since the first command will disable your Apple keyboard). Alternatively, run `sudo reboot`, and the new module should be loaded on reboot.

The advantage of DKMS is that the module is automatically re-built after every kernel upgrade and installation. This method has been tested at least on Ubuntu 14.04 and 16.04.