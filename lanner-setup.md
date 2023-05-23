# Lanner Setup

Usefull links:

1. Rufus (to create ubuntu install media) `https://rufus.ie/en/`
2. Ubuntu server (the OS we will be installing) `https://ubuntu.com/download/server`
3. Putty (assists in comunication over a com port) `https://www.putty.org/`
    * `use connection type: serial, speed: 115200n8`
4. Murakami's Git `https://github.com/m-lab/murakami`


## OS installation

Precondition: Lanner is turned off and connected via the management port to a machine with telnet/PuTTY installed

1. Insert Ubuntu 20.04 installation media into USB drive
2. Open telnet connection using the correct serial COM port and 115200 baud
3. Power on Lanner
4. When greeted with the grub bootloader, press `e` to edit the "Install" options
5. Change the line that begins with `linux` to add the following two flags before the triple hyphen `---`:
    * `console=tty0`
    * `console=ttyS0,115200n8`
6. Press `ctrl+X` to boot into the Ubuntu installer
7. Install the minimified version of the OS -- this will save space
8. When prompted about disk setup, deselect the option to use LVM
9. Use username `TODO` and password `TODO`

## Docker installation

Precondition: Ubuntu 20.04 is set up and a network cable is plugged into the device

1. Power on and log into the Lanner
2. Install `curl` from apt using `sudo apt update && sudo apt install curl`
3. Use the convenience script to install Docker
```
curl -fsSL https://get.docker.com | sudo sh -
```

## Murakami setup

Precondition: Ubuntu 20.04 is set up, network is attached, Docker is installed

1. From github.com/Better-Broadband/murakami-config.git, download the following files:
   a. `murakami.toml`.
   b. `trusted-edge.sh`
   c. `trusted-edge.service`
1.A.D.A.M. Edit the murakami.toml to include a unique id in the location field (line 34) e.g. location = "dell-jax-de4b"
1.B Edit the `trusted-edge.service` unit file. Line 7 should read "User = USERNAME". Change that "USERNAME" to the Username on the Lanner system.
2. Get the TrustedEdge private key. Name it `precision-key.pem`
3. connected to the device via putty use `ip a` and then search for the ip address, generally something similar to 192.168.0.4
4. open a Cmd prompt on your computer and use the following commands to move the relevant files to the device
```
pscp C:\pathToFile\murakami.toml UserName@deviceIp:murakami.toml
pscp C:\pathToFile\trusted-edge.sh UserName@deviceIp:trusted-edge.sh
pscp C:\pathToFile\trusted-edge.service UserName@deviceIp:trusted-edge.service
pscp C:\pathToFile\precision-key.pem UserName@deviceIp:precision-key.pem
```
5. All files should now be on the device, return to using putty where you can confirm their presence with the `dir` command 
6. Create a folder called `config` with the command `mkdir -p config`
7. Create a folder called `data` with the command `mkdir -p data`
8. Create a folder called `.ssh` if it does not already exist with the command `mkdir -p .ssh`
9. Move the murakami.toml into the new config directory. `mv murakami.toml config`
10. Start the docker container using the following config:
```
sudo docker run -d --restart always --network host --volume /home/$username/config:/murakami/configs/ --volume /home/$username/data:/data measurementlab/murakami:latest -c /murakami/configs/murakami.toml
```
11. Check the docker logs to make sure authentication of the first test is successful
```
$ sudo docker ps  # to get the id of the container
$ sudo docker logs -f $id  # using the id from above
# ctrl+c to exit once you've observed the upload
```

13. Move the `trusted-edge.service` unit file to the `/etc/systemd/system` directory. You will need to assume root to do this `sudo mv trusted-edge.service /etc/systemd/system`
15. Move the `trusted-edge.sh` script to its own directory. `sudo mkdir -p /trusted-edge; sudo mv trusted-edge.sh /trusted-edge`
16. Change ownership of the new directory to the current user so the service can use it. `sudo chown -R $USER /trusted-edge`
17. Move the `precision-key.pem` private key to the .ssh directory. `mv precision-key.pem .ssh`
18. Install `inotify-tools` using apt. The shell script requires this package to watch for file system events. `sudo apt install inotify-tools`
19. Reload the systemctl daemon to update it with the new unit file, then enable and start the service
```
sudo systemctl daemon-reload
sudo systemctl enable trusted-edge.service
sudo systemctl start trusted-edge.service
```
20. Use systemctl one more time to verify the service is running. `sudo systemctl status trusted-edge.service`

Note: files can be transferred using `scp` on Linux or `pscp` on Windows with a syntax like:

```
$ scp path/to/file username@$LANNER_IP:/remote/path/to/destination  # identical on Windows, just with pscp instead of scp
```

This may prompt you to accept a fingerprint if it's the first time you're connecting to the Lanner this way.

## Shutdown

Precondition: Whole system set up, running, and upload observed

1. Disconnect all terminal sessions
2. Press the small power button on the back of the Lanner once to trigger a graceful shutdown
3. Unplug from your workbench and prepare for shipment to customer
