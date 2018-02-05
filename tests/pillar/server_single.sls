gnocchi:
  common:
    version: 4.0
    database:
      engine: mysql
      host: 127.0.0.1
      name: gnocchi
      password: workshop
      user: gnocchi
    storage:
      aggregation_workers: 2
      driver: ceph
      ceph_pool: gnocchi
      ceph_username: gnocchi
      ceph_secret: workshop
      ceph_keyring: /etc/ceph/ceph.gnocchi.keyring
      ceph_timeout: 20
      ceph_conf: /etc/ceph/ceph.conf
      redis_url: redis://127.0.0.2/test
      file_basepath: /var/lib/gnocchi
      incoming:
        driver: redis
        redis_url: redis://127.0.0.2/test_incoming
        ceph_pool: gnocchi_incoming
        ceph_username: gnocchi
        ceph_secret: workshop
        ceph_keyring: /etc/ceph/ceph.gnocchi.keyring
        ceph_timeout: 30
        ceph_conf: /etc/ceph/ceph.conf
        file_basepath: /var/lib/gnocchi_incoming
    coordination_backend:
      url: redis://127.0.0.1/test
  server:
    enabled: true
    debug: true
    enable_proxy_headers_parsing: true
    archive_policy:
      default_aggregation_methods:
      - mean
      - max
    identity:
      engine: keystone
      region: RegionOne
      protocol: http
      host: 127.0.0.1
      port: 35357
      private_port: 5000
      user: gnocchi
      password: workshop
      tenant: service
      auth_type: password
    cache:
      engine: memcached
      members:
      - host: 127.0.0.1
        port: 11211
    metricd:
      workers: 5
  statsd:
    resource_id: 07f26121-5777-48ba-8a0b-d70468133dd9
    enabled: true
    bind:
      address: 127.0.0.1
      port: 8125
apache:
  server:
    enabled: true
    default_mpm: event
    mpm:
      prefork:
        enabled: true
        servers:
          start: 5
          spare:
            min: 2
            max: 10
        max_requests: 0
        max_clients: 20
        limit: 20
    site:
      gnocchi:
        enabled: false
        available: true
        type: wsgi
        name: gnocchi
        host:
          name: gnocchi.ci.local
          address: 127.0.0.1
          port: 8041
        log:
          custom:
            format: >-
              %v:%p %{X-Forwarded-For}i %h %l %u %t \"%r\" %>s %D %O \"%{Referer}i\" \"%{User-Agent}i\"
        wsgi:
          daemon_process: gnocchi-api
          processes: 2
          threads: 10
          user: gnocchi
          group: gnocchi
          display_name: '%{GROUP}'
          script_alias: '/ /usr/bin/gnocchi-api'
          application_group: '%{GLOBAL}'
          authorization: 'On'
    pkgs:
      - apache2
    modules:
      - wsgi
