sss
===

my shadow sockets client service 

Intallation
-----------

### Node.js

goto [http://nodejs.org/download/], verified in v0.10.26

linux

    wget http://nodejs.org/dist/v0.10.26/node-v0.10.26.tar.gz
    tar xzvf node-v0.10.26.tar.gz
    cd node-v0.10.26
    ./configure
    make
    make install

### Shadow sockets

    npm install -g shadowsocks

### configuration

    {
        "server":"your_sockets_server_ip",
        "server_port":your_server_port,
        "local_port":your_local_port,
        "password":"your_password",
        "timeout":600,
        "method":"table"
    }

The local port is used when you define your sockes-proxy setting in your web browser.
Ex: 127.0.0.1:1234
