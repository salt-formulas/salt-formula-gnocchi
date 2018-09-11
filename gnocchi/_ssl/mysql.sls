{% from "gnocchi/map.jinja" import cfg with context %}

gnocchi_ssl_mysql:
  test.show_notification:
    - text: "Running gnocchi._ssl.mysql"

{%- if cfg.database.get('x509',{}).get('enabled',False) %}

  {%- set ca_file=cfg.database.x509.ca_file %}
  {%- set key_file=cfg.database.x509.key_file %}
  {%- set cert_file=cfg.database.x509.cert_file %}

mysql_gnocchi_ssl_x509_ca:
  {%- if cfg.database.x509.cacert is defined %}
  file.managed:
    - name: {{ ca_file }}
    - contents_pillar: cfg.database:x509:cacert
    - mode: 444
    - user: gnocchi
    - group: gnocchi
    - makedirs: true
  {%- else %}
  file.exists:
    - name: {{ ca_file }}
  {%- endif %}

mysql_gnocchi_client_ssl_cert:
  {%- if cfg.database.x509.cert is defined %}
  file.managed:
    - name: {{ cert_file }}
    - contents_pillar: cfg.database:x509:cert
    - mode: 440
    - user: gnocchi
    - group: gnocchi
    - makedirs: true
  {%- else %}
  file.exists:
    - name: {{ cert_file }}
  {%- endif %}

mysql_gnocchi_client_ssl_private_key:
  {%- if cfg.database.x509.key is defined %}
  file.managed:
    - name: {{ key_file }}
    - contents_pillar: cfg.database:x509:key
    - mode: 400
    - user: gnocchi
    - group: gnocchi
    - makedirs: true
  {%- else %}
  file.exists:
    - name: {{ key_file }}
  {%- endif %}

mysql_gnocchi_ssl_x509_set_user_and_group:
  file.managed:
    - names:
      - {{ ca_file }}
      - {{ cert_file }}
      - {{ key_file }}
    - user: gnocchi
    - group: gnocchi

  {% elif cfg.database.get('ssl',{}).get('enabled',False) %}
mysql_ca_gnocchi_file:
  {%- if cfg.database.ssl.cacert is defined %}
  file.managed:
    - name: {{ cfg.database.ssl.cacert_file }}
    - contents_pillar: cfg.database:ssl:cacert
    - mode: 0444
    - makedirs: true
  {%- else %}
  file.exists:
    - name: {{ cfg.database.ssl.get('cacert_file', cfg.cacert_file) }}
  {%- endif %}

{%- endif %}
