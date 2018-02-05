{%- from "gnocchi/map.jinja" import cfg with context %}

gnocchi_common.pkgs:
  pkg.installed:
    - name: 'gnocchi-common'

gnocchi_common_conf:
  file.managed:
  - name: /etc/gnocchi/gnocchi.conf
  - source: salt://gnocchi/files/{{ cfg.version }}/gnocchi.conf
  - template: jinja
  - require:
    - pkg: gnocchi_common.pkgs

{%- if cfg.database.get('ssl',{}).get('enabled', False) %}
mysql_ca_gnocchi_file:
{%- if cfg.database.ssl.cacert is defined %}
  file.managed:
    - name: {{ cfg.databse.ssl.cacert_file }}
    - contents_pillar: cfg.database:ssl:cacert
    - mode: 0444
    - makedirs: true
{%- else %}
  file.exists:
   - name: {{ cfg.database.ssl.get('cacert_file', cfg.cacert_file) }}
{%- endif %}
{%- endif %}