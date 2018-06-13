{%- from "gnocchi/map.jinja" import client with context %}

{%- set resources = client.get('resources', {}).get('v1', {}) %}

{%- if resources.get('enabled', False) %}

{%- for policy_name, policy in resources.get('archive_policies', {}).iteritems() %}

gnocchi_archive_policy_{{ policy_name }}:
  gnocchiv1.archive_policy_present:
  - cloud_name: {{ policy.get('cloud_name', resources.cloud_name) }}
  - name: {{ policy_name }}
  - definition:
    {{ policy.definition|yaml(false)|indent(4) }}
{%- if policy.aggregation_methods is defined %}
  - aggregation_methods:
    {{ policy.aggregation_methods|yaml(false)|indent(4) }}
{%- endif %}
{%- if policy.back_window is defined %}
  - back_window: {{ policy.back_window }}
{%- endif %}

{%- for rule_name, rule in policy.get('rules', {}).iteritems() %}

gnocchi_archive_policy_rule_{{ rule_name }}:
  gnocchiv1.archive_policy_rule_present:
  - cloud_name: {{ policy.get('cloud_name', resources.cloud_name) }}
  - name: {{ rule_name }}
  - archive_policy_name: {{ policy_name }}
  - metric_pattern: {{ rule.metric_pattern }}
  - require:
    - gnocchi_archive_policy_{{ policy_name }}
{%- endfor %}

{%- endfor %}

{%- endif %}
