Ruby 2.0 - CentOS Docker image
========================================

This repository contains the sources and
[Dockerfile](https://github.com/openshift/ruby-20-centos/blob/master/Dockerfile)
of the base image for deploying Ruby 2.0 applications as reproducible Docker
images. The resulting images can be run either by [Docker](http://docker.io)
or using [STI](https://github.com/openshift/source-to-image).

Installation
---------------

This image is available as trusted build in [Docker Index](https://index.docker.io):

[index.docker.io/u/openshift/ruby-20-centos](https://index.docker.io/u/openshift/ruby-20-centos/)

You can install it using:

```
$ docker pull openshift/ruby-20-centos
```

Repository organization
------------------------

* **`.sti/bin/`**

  This folder contains scripts that are run by [STI](https://github.com/openshift/source-to-image):

  *   **assemble**

      Is used to restore the build artifacts from the previous built (in case of
      'incremental build'), to install the sources into location from where the
      application will be run and prepare the application for deployment (eg.
      installing rubygems using bundler, compiling Rails assets, etc..)

  *   **run**

      This script is responsible for running the application, by using the
      application web server. In case of Ruby, the [puma](http://puma.io/)
      server is used, if users put the `gem "puma"` into `Gemfile`. If they do not,
      then the application is run by using the `rackup` command, which should
      honour the application server users provided.

  *   **save-artifacts**

      In order to do an *incremental build* (iow. re-use the build artifacts
      from an already built image in a new image), this script is responsible for
      archiving those. In this image, this script will archive the
      `/opt/src/ruby/bundle` and `Gemfile.lock`.


* **`ruby/`**

  This folder is a skeleton of the `$HOME` folder, which is set to `/opt/ruby`.
  It provides a Ruby shebang helper (`ruby` script) and the `usage` script,
  which STI uses to print a usage message when you run this image outside STI.
  This folder also provides minimal, production ready configuration for *puma*
  and also tweaked *.bashrc* and *.gemrc* to optimize the installation of ruby
  gems.


Environment variables
---------------------

*  **APP_ROOT** (default: '.')

    This variable specifies a relative location to your application inside the
    application GIT repository. In case your application is located in a
    sub-folder, you can set this variable to a *./myapplication*.

*  **STI_SCRIPTS_URL** (default: '[.sti/bin](https://raw.githubusercontent.com/openshift/ruby-19-centos/master/.sti/bin)')

    This variable specifies the location of directory, where *assemble*, *run* and
    *save-artifacts* scripts are downloaded/copied from. By default the scripts
    in this repository will be used, but users can provide an alternative
    location and run their own scripts.

Contributing
------------

In order to test your changes to this STI image or to the STI scripts, you can
use the `test/run` script. Before that, you have to build the 'candidate' image:

```
$ docker build -t openshift/ruby-20-centos-candidate .
```

After that you can execute `./test/run`. You can also use `make test` to
automate this.

Usage
---------------------

**Building the [sinatra-app-example](https://github.com/mfojtik/sinatra-app-example) Ruby 2.0 application..**

1. **using standalone [STI](https://github.com/openshift/source-to-image) and running the resulting image by [Docker](http://docker.io):**

    ```
$ sti build git://github.com/mfojtik/sinatra-app-example openshift/ruby-20-centos sinatra-app
$ docker run -p 9292:9292 sinatra-app
```

**Accessing the application:**
```
$ curl 127.0.0.1:9292
```


Copyright
--------------------

Released under the Apache License 2.0. See the [LICENSE](https://github.com/openshift/ruby-19-centos/blob/master/LICENSE) file.
