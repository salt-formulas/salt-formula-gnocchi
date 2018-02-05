{%- from "gnocchi/map.jinja" import client with context %}
{%- if client.enabled %}

gnocchi_client_packages:
  pkg.installed:
  - names: {{ client.pkgs }}

{%- endif %}