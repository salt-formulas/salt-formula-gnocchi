# -*- coding: utf-8 -*-
'''
Managing entities in Gnocchi
===================================
'''
# Import python libs
import logging

# Import Gnocchi libs
def __virtual__():
    return 'gnocchiv1' if 'gnocchiv1.archive_policy_list' in __salt__ else False


log = logging.getLogger(__name__)


def _gnocchiv1_call(fname, *args, **kwargs):
    return __salt__['gnocchiv1.{}'.format(fname)](*args, **kwargs)


def archive_policy_present(name, cloud_name, definition, **kwargs):
    """
    Creates an archive policy

    This state checks if an archive policy is present and, if not, creates an
    archive policy with specified name, definition, aggregation methods and
    back_window.

    :param name: name of the archive policy
    :param cloud_name: name of the cloud in cloud.yaml
    :param definition: List of dictionaries. Every dictionary may contain:
            :param granularity: String indicating policy's granularity e.g. '0:00:01'
            :param points: Integer indicating policy's points e.g. 10
            :param: timespan parameters of archive policy. e.g. '0:00:10'
    :param aggregation_methods: List of aggregation methods used in archive policy
    :param back_window: Integer specifies the number of coarsest periods to keep
    """
    try:
        archive_policy = _gnocchiv1_call(
            'archive_policy_read', name, cloud_name=cloud_name
        )
    except Exception as e:
        if 'NotFound' in repr(e):
            try:
                resp = _gnocchiv1_call(
                    'archive_policy_create', name=name, cloud_name=cloud_name,
                    definition=definition, **kwargs
                )
            except Exception as e:
                log.error('Gnocchi archive policy create failed with {}'.format(e))
                return _create_failed(name, 'archive_policy')
            return _created(name, 'archive_policy', resp)
        else:
            raise
    if archive_policy:
        # TODO: Implement and design archive policy update procedure
        return _no_changes(name, 'archive_policy')
    else:
        return _find_failed(name, 'archive_policy')


def archive_policy_absent(name, cloud_name):
    try:
        archive_policy = _gnocchiv1_call(
            'archive_policy_read', name, cloud_name=cloud_name
        )
    except Exception as e:
        if 'NotFound' in repr(e):
            return _absent(name, 'archive_policy')
    if archive_policy:
        try:
            resp = _gnocchiv1_call(
                    'archive_policy_delete', name, cloud_name=cloud_name
                )
        except Exception as e:
            log.error('Archive policy delete failed with {}'.format(e))
            return _delete_failed(name, 'archive_policy')
        return _deleted(name, 'archive_policy')
    else:
        return _find_failed(name, 'archive_policy')


def archive_policy_rule_present(name, cloud_name, archive_policy_name, metric_pattern):
    """
    Creates an archive policy rule

    This state checks if an archive policy rule is present and, if not, creates an
    archive policy rule with specified name, archive policy name, and metric_pattern.

    :param name: name of the archive policy rule
    :param cloud_name: name of the cloud in cloud.yaml
    :param archive_policy_name: name of archive policy for specified rule
    :param metric_pattern: pattern for metrics classified by the rule
    """
    try:
        archive_policy_rule = _gnocchiv1_call(
            'archive_policy_rule_read', name, cloud_name=cloud_name
        )
    except Exception as e:
        if 'NotFound' in repr(e):
            try:
                resp = _gnocchiv1_call(
                    'archive_policy_rule_create', name=name, cloud_name=cloud_name,
                    archive_policy_name=archive_policy_name, metric_pattern=metric_pattern,
                )
            except Exception as e:
                log.error('Gnocchi archive policy rule create failed with {}'.format(e))
                return _create_failed(name, 'archive_policy_rule')
            return _created(name, 'archive_policy_rule', resp)
        else:
            raise
    if archive_policy_rule:
        # Currently Gnocchi API doesn't allow to update properties in rules,
        # but they can be recreated.
        if ((archive_policy_rule['archive_policy_name'] != archive_policy_name) or
            (archive_policy_rule['metric_pattern'] != metric_pattern)):
            try:
                resp = _gnocchiv1_call(
                    'archive_policy_rule_delete', name, cloud_name=cloud_name
                )
                resp = _gnocchiv1_call(
                    'archive_policy_rule_create', name=name, cloud_name=cloud_name,
                    archive_policy_name=archive_policy_name, metric_pattern=metric_pattern
                )
            except Exception as e:
                log.error('Archive policy rule update failed with {}'.format(e))
                return _update_failed(name, 'archive_policy_rule')
            return _updated(name, 'archive_policy_rule', resp)
        else:
            return _no_changes(name, 'archive_policy_rule')
    else:
        return _find_failed(name, 'archive_policy_rule')

def archive_policy_rule_absent(name, cloud_name):
    try:
        archive_policy_rule = _gnocchiv1_call(
            'archive_policy_rule_read', name, cloud_name=cloud_name
        )
    except Exception as e:
        if 'NotFound' in repr(e):
            return _absent(name, 'archive_policy_rule')
    if archive_policy_rule:
        try:
            resp = _gnocchiv1_call(
                    'archive_policy_rule_delete', name, cloud_name=cloud_name
                )
        except Exception as e:
            log.error('Archive policy rule delete failed with {}'.format(e))
            return _delete_failed(name, 'archive_policy_rule')
        return _deleted(name, 'archive_policy_rule')
    else:
        return _find_failed(name, 'archive_policy_rule')


def _created(name, resource, resource_definition):
    changes_dict = {
        'name': name,
        'changes': resource_definition,
        'result': True,
        'comment': '{}{} created'.format(resource, name)
    }
    return changes_dict


def _updated(name, resource, resource_definition):
    changes_dict = {
        'name': name,
        'changes': resource_definition,
        'result': True,
        'comment': '{}{} updated'.format(resource, name)
    }
    return changes_dict


def _no_changes(name, resource):
    changes_dict = {
        'name': name,
        'changes': {},
        'result': True,
        'comment': '{}{} is in desired state'.format(resource, name)
    }
    return changes_dict


def _deleted(name, resource):
    changes_dict = {
        'name': name,
        'changes': {},
        'result': True,
        'comment': '{}{} removed'.format(resource, name)
    }
    return changes_dict


def _absent(name, resource):
    changes_dict = {'name': name,
                    'changes': {},
                    'comment': '{0} {1} not present'.format(resource, name),
                    'result': True}
    return changes_dict


def _delete_failed(name, resource):
    changes_dict = {'name': name,
                    'changes': {},
                    'comment': '{0} {1} failed to delete'.format(resource,
                                                                 name),
                    'result': False}
    return changes_dict


def _create_failed(name, resource):
    changes_dict = {'name': name,
                    'changes': {},
                    'comment': '{0} {1} failed to create'.format(resource,
                                                                 name),
                    'result': False}
    return changes_dict


def _update_failed(name, resource):
    changes_dict = {'name': name,
                    'changes': {},
                    'comment': '{0} {1} failed to update'.format(resource,
                                                                 name),
                    'result': False}
    return changes_dict


def _find_failed(name, resource):
    changes_dict = {
        'name': name,
        'changes': {},
        'comment': '{0} {1} found multiple {0}'.format(resource, name),
        'result': False,
    }
    return changes_dict

