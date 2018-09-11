{%- from "gnocchi/map.jinja" import statsd,cfg with context %}
{%- if statsd.get('enabled', False) %}

include:
  - gnocchi._common

gnocchi_statsd_packages:
  pkg.installed:
  - names: {{ statsd.pkgs }}

gnocchi_statsd_services:
  service.running:
  - enable: true
  - names: {{ statsd.services }}
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}
  - require:
    - pkg: gnocchi_statsd_packages
    - sls: gnocchi._common
  - watch:
    - gnocchi_common_conf

{%- endif %}
