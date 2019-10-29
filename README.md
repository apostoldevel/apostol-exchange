# apostol-exchange

**Exchange Bot (`ex-bot`)** - Bot for buy & sale of cryptocurrency on cryptocurrency exchanges.

Implementation in the form of REST API Web Service, in C++.

Built on base [Apostol](https://github.com/ufocomp/apostol).

The software stack consists of a compilation of source code, libraries and scripts.

Overview
-
1. Accepts an API request from a web client indicating amount of currency:
    - Accesses 3 different exchanges (Binance, Poloniex, Bitfinex) using the order book and takes into account how much you need to spend on a particular exchange in order to buy a certain amount of currency.
1.  Accepts an API request from a web client indicating the exchange, quantity and trading pair:
    - Sends an API request to the exchange to execute an order, returns a response to the web client. 
1. Writes the result to the PostgreSQL database.

Build and installation
-
Build required:

1. Compiler C++;
1. [CMake](https://cmake.org);
1. Library [libdelphi](https://github.com/ufocomp/libdelphi/) (Delphi classes for C++);
1. Library [libpq-dev](https://www.postgresql.org/download/) (libraries and headers for C language frontend development);
1. Library [postgresql-server-dev-10](https://www.postgresql.org/download/) (libraries and headers for C language backend development).

###### **ATTENTION**: You do not need to install [libdelphi](https://github.com/ufocomp/libdelphi/), just download and put it in the `src/lib` directory of the project.

To install the C ++ compiler and necessary libraries in Ubuntu, run:
~~~
sudo apt-get install build-essential libssl-dev libcurl4-openssl-dev make cmake gcc g++
~~~

To install PostgreSQL, use the instructions for [this](https://www.postgresql.org/download/) link.

###### A detailed description of the installation of C ++, CMake, IDE, and other components necessary for building the project is not included in this guide. 

To install (without Git) you need:

1. Download [apostol-exchange](https://github.com/ufocomp/apostol-exchange/archive/master.zip);
1. Unpack;
1. Download [libdelphi](https://github.com/ufocomp/libdelphi/archive/master.zip);
1. Unpack in `src/lib/delphi`;
1. Configure `CMakeLists.txt` (of necessity);
1. Build and compile (see below).

To install (with Git) you need:
~~~
git clone https://github.com/ufocomp/apostol-exchange.git
~~~

To add [libdelphi](https://github.com/ufocomp/libdelphi/) to a project using Git, do:
~~~
cd apostol-exchange/src/lib
git clone https://github.com/ufocomp/libdelphi.git delphi
cd ../../../
~~~

###### Build:
~~~
cd apostol-exchange
cmake -DCMAKE_BUILD_TYPE=Release . -B cmake-build-release
~~~

###### Compilation and installation:
~~~
cd cmake-build-release
make
sudo make install
~~~

By default **`ex-bot`** will be set to:
~~~
/usr/sbin
~~~

The configuration file and the necessary files for operation, depending on the installation option, will be located in:
~~~
/etc/apostol-exchange
or
~/apostol-exchange
~~~

Run
-
###### If **`INSTALL_AS_ROOT`** set to `ON`.

**`ex-bot`** - it is a Linux system service (daemon). 

To manage **`ex-bot`** use standard service management commands.

To start, run:
~~~
sudo service ex-bot start
~~~

To check the status, run:
~~~
sudo service ex-bot status
~~~
