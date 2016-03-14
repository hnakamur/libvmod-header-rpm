FROM centos:7
MAINTAINER jfroche@affinitic.be

RUN yum -y install ruby ruby-devel rubygems rubygem-bundler gcc gcc-c++ make zlib-devel libxml2-devel libxslt-devel nmap-ncat && yum clean all
ADD ./Gemfile ./Rakefile /tester/
RUN mkdir -p /tester/spec
WORKDIR /tester
RUN bundle config build.nokogiri --use-system-libraries && bundle install
CMD /usr/local/bin/rspec
