#!/bin/sh

<% user = name %>
<% group = project %>

getent group <%= project %> > /dev/null 2>&1
if [ $? -eq 2 ]; then
  groupadd -r <%= project %>
fi

getent passwd <%= name %> > /dev/null 2>&1
if [ $? -eq 2 ]; then
  useradd -md /var/lib/<%=name %> -g <%=project %> -s /bin/bash -r <%= name %>
fi

mkdir -p <%= log_dir %>
chown -R <%= user %>:<%= group %> <%= log_dir %>
mkdir -p <%= pid_dir %>
chown -R <%= user %>:root <%= pid_dir %>