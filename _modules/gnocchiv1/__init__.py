try:
    import os_client_config
    from keystoneauth1 import exceptions as ka_exceptions
    REQUIREMENTS_MET = True
except ImportError:
    REQUIREMENTS_MET = False

from gnocchiv1 import archive_policy

archive_policy_create = archive_policy.archive_policy_create
archive_policy_delete = archive_policy.archive_policy_delete
archive_policy_list = archive_policy.archive_policy_list
archive_policy_update = archive_policy.archive_policy_update
archive_policy_read = archive_policy.archive_policy_read

archive_policy_rule_create = archive_policy.archive_policy_rule_create
archive_policy_rule_delete = archive_policy.archive_policy_rule_delete
archive_policy_rule_list = archive_policy.archive_policy_rule_list
archive_policy_rule_read = archive_policy.archive_policy_rule_read

__all__ = (
    'archive_policy_update', 'archive_policy_create', 'archive_policy_list', 'archive_policy_delete',
    'archive_policy_read', 'archive_policy_rule_create', 'archive_policy_rule_delete', 'archive_policy_rule_list',
    'archive_policy_rule_read'
)

def __virtual__():
    """Only load gnocchiv1 if requirements are available."""
    if REQUIREMENTS_MET:
        return 'gnocchiv1'
    else:
        return False, ("The gnocchiv1 execution module cannot be loaded: "
                       "os_client_config or keystoneauth are unavailable.")
