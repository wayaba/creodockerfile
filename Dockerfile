# © Copyright IBM Corporation 2018.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v2.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v20.html

FROM ibmcom/ace

ENV BAR1=abc.bar
ENV ODBC=odbc.ini

# Copy in the bar file to a temporary directory
COPY --chown=aceuser $BAR1 /tmp

# Copy odbc.ini file to a temporary directory
COPY $ODBC /opt/ibm/ace-11.0.0.0/server/ODBC/unixodbc/

# Unzip the BAR file; need to use bash to make the profile work
RUN bash -c 'mqsicreateworkdir /home/aceuser/ace-server && mqsibar -w /home/aceuser/ace-server -a /tmp/$BAR1 -c'

# Switch off the admin REST API for the server run, as we won't be deploying anything after start
#RUN sed -i 's/adminRestApiPort/#adminRestApiPort/g' /home/aceuser/ace-server/server.conf.yaml 

RUN sudo chmod 666 /etc/bash.bashrc

RUN echo "export ODBCINI=/opt/ibm/ace-11.0.0.0/server/ODBC/unixodbc/odbc.ini" >> /etc/bash.bashrc
RUN echo "export ODBCSYSINI=/opt/ibm/ace-11.0.0.0/server/ODBC/unixodbc/odbcinst.ini" >> /etc/bash.bashrc

#Configuracion de entorno para ejecutar comandos de broker
RUN echo "source /opt/ibm/ace-11.0.0.0/server/bin/mqsiprofile" >> /etc/bash.bashrc

# We inherit the command from the base layer
WORKDIR /opt/ibm/ace-11.0.0.0/server/bin/
RUN sudo mv IntegrationServer  IntSer-pablo
RUN sudo touch IntegrationServer
RUN sudo chmod 777 IntegrationServer
RUN sudo echo -e "export ODBCINI=/opt/ibm/ace-11.0.0.0/server/ODBC/unixodbc/odbc.ini \n export ODBCSYSINI=/opt/ibm/ace-11.0.0.0/server/ODBC/unixodbc/odbcinst.ini \n IntSer-pablo \$*" >> IntegrationServer
RUN source /opt/ibm/ace-11.0.0.0/server/bin/mqsiprofile
RUN mqsisetdbparms -w /home/aceuser/ace-server -n SQLLOCAL -u sa -p Password0!