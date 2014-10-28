# centos-ruby
#
# This image provide a base for running Ruby based applications. It provides
# just base Ruby installation using SCL and Ruby application server.
#
# If you want to use Bundler with C-extensioned gems or MySQL/PostGresql, you
# can use 'centos-ruby-extended' image instead.
#

FROM centos:centos7

# Pull in important updates and then install ruby193
#
RUN yum install -y --enablerepo=centosplus epel-release \
    gettext tar which ruby ruby-devel \
    rubygem-bundler rubygem-rake \
    gcc-c++ automake make autoconf curl-devel openssl-devel \
    zlib-devel libxslt-devel libxml2-devel \
    mysql-libs mysql-devel postgresql-devel sqlite-devel && \
    yum install -y --enablerepo=centosplus nodejs && \
    yum clean all -y

# Add configuration files, bashrc and other tweaks
#
ADD ./ruby /opt/ruby/
ADD ./.sti/bin/usage /opt/ruby/bin/

ENV STI_SCRIPTS_URL https://raw.githubusercontent.com/openshift/ruby-20-centos/master/.sti/bin

# Create 'ruby' account we will use to run Ruby application
# Add support for '#!/usr/bin/ruby' shebang.
#
RUN mkdir -p /opt/ruby/{gems,run,src} && \
    groupadd -r ruby -f -g 433 && \
    useradd -u 431 -r -g ruby -d /opt/ruby -s /sbin/nologin -c "Ruby user" ruby && \
    chown -R ruby:ruby /opt/ruby

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
ENV PATH     $HOME/bin:$PATH

WORKDIR     /opt/ruby/src
USER        ruby

EXPOSE 9292

CMD ["/opt/ruby/bin/sti-helper"]
