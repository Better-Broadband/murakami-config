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

1. Download the murakami.toml from github.com/Better-Broadband/murakami-config.git. Name it `murakami.toml`.
2. Get the service account keyfile from GCP for the `monitors` service account. Name it `service-account-keyfile.json`.
3. connected to the device via putty use `ip a` and then search for the ip address, generally something similar to 192.168.0.4
4. open a Cmd prompt on your computer and use the following 2 commands to move the murakami.toml and the service account keyfile to the device
```
pscp C:\pathToFile\service-account-keyfile.json UserName@deviceIp:service-account-keyfile.json
pscp C:\pathToFile\murakami.toml UserName@deviceIp:murakami.toml
```
5. Both files should now be on the device, return to using putty where you can confirm their presencewith the the `dir` command 
6. Create a folder called config using the command `mkdir config"
7. move the files into the folder using the commands `mv service-account-keyfile.json config` and ` mv murakami.toml config`
8. Start the docker container using the following config:
```
sudo docker run -d --restart always --network host --volume /home/$username/config:/murakami/configs/ measurementlab/murakami:latest -c /murakami/configs/murakami.toml
```
5. Check the docker logs to make sure authentication of the first test is successful
```
$ sudo docker ps  # to get the id of the container
$ sudo docker logs -f $id  # using the id from above
# ctrl+c to exit once you've observed the upload
```

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
