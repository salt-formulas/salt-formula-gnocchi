{%- from "gnocchi/map.jinja" import cfg with context %}

include:
  - gnocchi._ssl.mysql

gnocchi_common.pkgs:
  pkg.installed:
    - name: 'gnocchi-common'
    - require_in:
      - sls: gnocchi._ssl.mysql

gnocchi_common_conf:
  file.managed:
  - name: /etc/gnocchi/gnocchi.conf
  - source: salt://gnocchi/files/{{ cfg.version }}/gnocchi.conf
  - mode: 0640
  - group: gnocchi
  - template: jinja
  - require:
    - pkg: gnocchi_common.pkgs
    - sls: gnocchi._ssl.mysql
