try:
    from urllib.parse import urlencode
except ImportError:
    from urllib import urlencode
import hashlib

from gnocchiv1.common import send, get_raw_client

@send('get')
def archive_policy_list(**kwargs):
    url = '/archive_policy?{}'.format(urlencode(kwargs))
    return url, {}


@send('post')
def archive_policy_create(**kwargs):
     url = '/archive_policy'
     return url, {'json': kwargs}

@send('get')
def archive_policy_read(policy_name, **kwargs):
    url = '/archive_policy/{}'.format(policy_name)
    return url, {}


@send('patch')
def archive_policy_update(policy_name, **kwargs):
    url = '/archive_policy/{}'.format(policy_name)
    return url, {'json': kwargs}


@send('delete')
def archive_policy_delete(policy_name, **kwargs):
     url = '/archive_policy/{}'.format(policy_name)
     return url, {}

@send('get')
def archive_policy_rule_list(**kwargs):
    url = '/archive_policy_rule?{}'.format(urlencode(kwargs))
    return url, {}

@send('post')
def archive_policy_rule_create(**kwargs):
     url = '/archive_policy_rule'
     return url, {'json': kwargs}

@send('get')
def archive_policy_rule_read(rule_name, **kwargs):
    url = '/archive_policy_rule/{}'.format(rule_name)
    return url, {}

@send('delete')
def archive_policy_rule_delete(rule_name, **kwargs):
     url = '/archive_policy_rule/{}'.format(rule_name)
     return url, {}
