{%- if pillar.gnocchi is defined %}
include:
{%- if pillar.gnocchi.server is defined %}
- gnocchi.server
{%- endif %}
{%- if pillar.gnocchi.statsd is defined %}
- gnocchi.statsd
{%- endif %}
{%- if pillar.gnocchi.client is defined %}
- gnocchi.client
{%- endif %}
{%- endif %}
