# centos-ruby
#
# This image provide a base for running Ruby based applications. It provides
# just base Ruby installation using SCL and Ruby application server.
#
# If you want to use Bundler with C-extensioned gems or MySQL/PostGresql, you
# can use 'centos-ruby-extended' image instead.
#

FROM       centos:centos7

# Pull in important updates and then install ruby193
#
RUN yum install -y --enablerepo=centosplus \
    gettext tar which ruby ruby-devel \
    rubygem-bundler rubygem-rake \
    gcc-c++ automake make autoconf curl-devel openssl-devel \
    zlib-devel libxslt-devel libxml2-devel \
    mysql-libs mysql-devel postgresql-devel sqlite-devel && \
    yum clean all -y

# Add configuration files, bashrc and other tweaks
#
ADD ./ruby /opt/ruby/

ENV STI_SCRIPTS_URL https://raw.githubusercontent.com/openshift/ruby-20-centos/master/.sti/bin

# Create 'ruby' account we will use to run Ruby application
# Add support for '#!/usr/bin/ruby' shebang.
#
RUN mkdir -p /opt/ruby/{gems,run,src} && \
    groupadd -r ruby -f -g 433 && \
    useradd -u 431 -r -g ruby -d /opt/ruby -s /sbin/nologin -c "Ruby User" ruby && \
    chown -R ruby:ruby /opt/ruby

# Install NodeJS
RUN mkdir -p /opt/nodejs && \
    curl -L http://nodejs.org/dist/latest/node-v0.10.32-linux-x64.tar.gz | \
    tar --strip-components 1 -xzf - -C /opt/nodejs

# Set the 'root' directory where this build will search for Gemfile and
# config.ru.
#
# This can be overridden inside another Dockerfile that uses this image as a base
# image or in STI via the '-e "APP_ROOT=subdir"' option.
#
# Use this in case when your application is contained in a subfolder of your
# GIT repository. The default value is the root folder.
#
ENV APP_ROOT .
ENV HOME     /opt/ruby
ENV PATH     $HOME/bin:/opt/nodejs/bin:$PATH

WORKDIR     /opt/ruby/src
USER        ruby

EXPOSE 9292

CMD ["/opt/ruby/bin/sti-helper"]
