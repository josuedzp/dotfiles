# Spotify
https://github.com/abba23/spotify-adblock/

## Installing spotify-client

<details> 
  <summary>Debian/Ubuntu</summary>
  <p>
```
https://www.spotify.com/es/download/linux/
```
  </p>
</details>

<details> 
  <summary>Fedora</summary>
  <p>
```
dnf config-manager --add-repo=https://negativo17.org/repos/fedora-spotify.repo
dnf install spotify-client
```
  </p>
</details>


## Build Adblock

<details> 
  <summary>Debian/Ubuntu</summary>
  <p>
Install the rust:
```
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```
Install cargo:
```
sudo apt install cargo
```
  </p>
</details>

<details> 
  <summary>Fedora</summary>
  <p>
Install the dependencies:
```
dnf install rust cargo
```
  </p>
</details>

Clone and build:
```
git clone https://github.com/abba23/spotify-adblock.git
cd spotify-adblock
make
```

Install to system path:
```
sudo make install
```

### Important Last Step
We are go to create a wrapper (is not fedora) that load `LD_PRELOAD` variable and execute spotify binary

```export LD_PRELOAD=/usr/local/lib/spotify-adblock.so```

<details> 
  <summary>Debian/Ubuntu</summary>
  <p>
  Rename original binary:

  ```
  sudo mv /usr/bin/spotify /usr/bin/spotify-client
  ```

  Create wrapper binary:

  ```
  sudo touch /usr/bin/spotify && sudo chmod 755 /usr/bin/spotify
  ```

  Exporting the variable env and executing spotify:

  ```
  #!/usr/bin/sh
  # Wrapper script for Spotify.
  export LD_PRELOAD=/usr/local/lib/spotify-adblock.so

  exec /usr/bin/spotify-client &
  ```
  </p>
</details>


<details> 
  <summary>Fedora</summary>
  <p>
Normally on other GNU/Linux distribution users add the LD_PRELOAD value to the desktop file, but this method didn’t work on Fedora 34 (I really don’t know why). So we will add LD_PRELOAD to spotify’s executable: /usr/bin/spotify.
Add LD_PRELOAD value to /usr/bin/spotify:

/usr/bin/spotify look like this:

```
#!/usr/bin/sh
# Wrapper script for Spotify.

# The spotify binary has a RUNPATH of its origin folder. It requires a few
# librares compiled with minimum options (no external dependencies).
# The FFMpeg library is loaded ONLY on the system path libraries, ignoring the
# RUNPATH.

# So remove the RUNPATH from the binary, put all the libraries in its private
# folder and make sure that only the spotify binary can access them.

export LD_LIBRARY_PATH="/usr/lib64/spotify-client${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export SCALE_FACTOR="$(/usr/lib64/spotify-client/get-scale-factor.py)"
#HERE
export LD_PRELOAD=/usr/local/lib/spotify-adblock.so

exec /usr/lib64/spotify-client/spotify --force-device-scale-factor=$SCALE_FACTOR "$@" &
exec /usr/lib64/spotify-client/set-dark-theme-variant.py &
```
  </p>
</details>
