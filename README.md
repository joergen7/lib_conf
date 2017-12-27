# lib_conf
###### Simple Erlang configuration handling library.

[![hex.pm](https://img.shields.io/hexpm/v/lib_conf.svg?style=flat)](https://hex.pm/packages/lib_conf) [![Build Status](https://travis-ci.org/joergen7/lib_conf.svg?branch=master)](https://travis-ci.org/joergen7/lib_conf)

This library allows the building of complex configuration objects (in the form of key/value pairs) from several sources superseding one another.

Complex Erlang applications often use large configurations that can be manipulated in several ways. Large configurations make it prohibitive to have the user enumerate all key/value pairs. Rather, a default configuration needs to be updated only in the places appearing in the superseding configuration.

`lib_conf` is a library that allows this style of configuration superseding. Herein, five configuration sources are taken into account: (i) a default configuration that is used as a basis, (ii) a global configuration parsed from a JSON file in the file system, (iii) a user-specific configuration parsed from a JSON file located relative from the current user's home directory, (iv) optionally, a supplemental JSON file that is explicitly mentioned by the user, and (v) a configuration that was created from command line flags. Each of these entry points supersede one another with the default configuration having the lowest priority and the command line flags having the highest.

## Usage

The `lib_conf` library provides a single function `create_conf/5`. The function returns a map of the form `#{ atom() => _ }`. The five parameters are:

- `DefaultMap :: #{ atom() => _ }` the default configuration to use
- `GlobalFile :: string()` the path to the global configuration file in JSON format
- `UserFile   :: string()` the path to the user-specific configuration file relative to the user home directory
- `SupplFile  :: string()` supplement file name provided explicitly by the user
- `FlagMap    :: #{ atom() => _ }` the configuration comprising the command line flags provided explicitly by the user

Example:

```erlang
DefaultMap = #{ nthread => 4, max_size => 2000 },
GlobalFile = "/usr/local/etc/my_app/client_conf.json",
UserFile   = ".config/my_app/client_conf.json",
SupplFile  = undefined
FlagMap    = #{ max_size => 3000 },

lib_conf:create_conf( DefaultMap, GlobalFile, UserFile, SupplFile, FlagMap ).
```

In this example we create a default configuration introducing the keys `nthread` and `max_size`. We have not been given a supplement configuration file by the user, thus, setting the corresponding argument to `undefined`. However, the `max_size` parameter has been set on the command line to have the value `3000` instead of the default value `2000`.

Assuming that the global and user-specific configuration files have not been created (or parrot the default configuration) we end up with a configuration map of the form `#{ nthread => 4, max_size => 3000 }`.

## System Requirements

- [Erlang](http://www.erlang.org/) OTP 18.0 or higher
- [Rebar3](https://www.rebar3.org/) 3.0.0 or higher

## Resources

## Authors

- Jörgen Brandt ([@joergen7](https://github.com/joergen7/)) [joergen.brandt@onlinehome.de](mailto:joergen.brandt@onlinehome.de)

## License

[Apache 2.0](https://www.apache.org/licenses/LICENSE-2.0.html)