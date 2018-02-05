{%- from "gnocchi/map.jinja" import server,cfg with context %}
{%- if server.get('enabled', False) %}

include:
  - apache
  - gnocchi._common

gnocchi_server_packages:
  pkg.installed:
  - names: {{ server.pkgs }}

gnocchi_upgrade:
  cmd.run:
  - name: gnocchi-upgrade
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}
  - runas: gnocchi
  - require:
    - file: gnocchi_common_conf

apache_enable_gnocchi_wsgi:
  apache_site.enabled:
  - name: wsgi_gnocchi
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}
  - require:
    - cmd: gnocchi_upgrade

gnocchi_apache_restart:
  service.running:
  - name: apache2
  - enable: true
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}
  - watch:
    - apache_enable_gnocchi_wsgi

gnocchi_server_services:
  service.running:
  - enable: true
  - names: {{ server.services }}
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}
  - require:
    - cmd: gnocchi_upgrade
  - watch:
    - gnocchi_common_conf
{%- if cfg.database.get('ssl',{}).get('enabled', False) %}
    - mysql_ca_gnocchi_file
{%- endif %}

{%- endif %}
