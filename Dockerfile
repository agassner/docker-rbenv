FROM ubuntu:14.04

# Prepare apt
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update
RUN locale-gen en_GB en_GB.UTF-8

RUN apt-get install -y build-essential curl git make man
RUN apt-get install -y --force-yes zlib1g-dev libssl-dev libreadline-dev libyaml-dev libxml2-dev libxslt-dev

# Install sshd
RUN apt-get install -y openssh-server
RUN mkdir -p /var/run/sshd /root/.ssh
RUN echo 'root:password' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
RUN sed -i 's/UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config

# Install supervisord
RUN apt-get install -y supervisor
RUN apt-get clean

# Install rbenv
RUN git clone https://github.com/sstephenson/rbenv.git /usr/local/rbenv
RUN echo '# rbenv setup' > /etc/profile.d/rbenv.sh
RUN echo 'export RBENV_ROOT=/usr/local/rbenv' >> /etc/profile.d/rbenv.sh
RUN echo 'export PATH="$RBENV_ROOT/bin:$PATH"' >> /etc/profile.d/rbenv.sh
RUN echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh
RUN chmod +x /etc/profile.d/rbenv.sh

# install ruby-build
RUN mkdir /usr/local/rbenv/plugins
RUN git clone https://github.com/sstephenson/ruby-build.git /usr/local/rbenv/plugins/ruby-build

ENV RBENV_ROOT /usr/local/rbenv

RUN bash -l -c 'rbenv rehash && rbenv install 2.0.0-p481'
RUN bash -l -c 'rbenv global 2.0.0-p481 && rbenv rehash'

# Install Bundler
RUN echo 'gem: --no-rdoc --no-ri' >> /root/.gemrc
RUN bash -l -c 'gem install bundler'

# Add supervisord config for ssh
ADD ./files/supervisor/sshd.conf /etc/supervisor/conf.d/

# Start supervisord in the foreground
EXPOSE 22
CMD /usr/bin/supervisord -n