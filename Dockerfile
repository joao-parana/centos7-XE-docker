FROM parana/centos7-docker

# Based on centos:7.2.1511 Public Image

MAINTAINER "João Antonio Ferreira" <joao.parana@gmail.com>`

# Adding Apache web server
RUN yum -y install httpd && systemctl enable httpd.service
EXPOSE 80

# Adding Oracle Install from oracle.com
ADD rpm/* /tmp/
RUN cd /tmp && cat xaa xab xac xad xae xaf xag > oracle-xe-11.2.0-1.0.x86_64.rpm && rm -rf xaa xab xac xad xae xaf xag

# Pre-requirements
RUN mkdir -p /run/lock/subsys

RUN yum install -y libaio bc initscripts net-tools
 
# Install Oracle XE
RUN yum localinstall -y /tmp/oracle-xe-11.2.0-1.0.x86_64.rpm && \
    rm -rf /tmp/oracle-xe-11.2.0-1.0.x86_64.rpm
 
# Configure instance
ADD config/xe.rsp config/init.ora config/initXETemp.ora /u01/app/oracle/product/11.2.0/xe/config/scripts/
RUN chown oracle:dba /u01/app/oracle/product/11.2.0/xe/config/scripts/*.ora \
                     /u01/app/oracle/product/11.2.0/xe/config/scripts/xe.rsp
RUN chmod 755        /u01/app/oracle/product/11.2.0/xe/config/scripts/*.ora \
                     /u01/app/oracle/product/11.2.0/xe/config/scripts/xe.rsp
ENV ORACLE_HOME /u01/app/oracle/product/11.2.0/xe
ENV ORACLE_SID  XE
ENV PATH        $ORACLE_HOME/bin:$PATH

RUN echo "••••" && cat /u01/app/oracle/product/11.2.0/xe/config/scripts/xe.rsp && echo "••••"
RUN /etc/init.d/oracle-xe configure responseFile=/u01/app/oracle/product/11.2.0/xe/config/scripts/xe.rsp

# Run script
ADD config/start.sh /

EXPOSE 1521
EXPOSE 8080

RUN yum clean all

CMD /start.sh

# CMD ["/usr/sbin/init"]

