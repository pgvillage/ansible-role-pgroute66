PgFga
=========

PgRoute66 is a tool to manage redirection from HAProxy to PostgreSQL.
PgRoutte66 tracks the master, and if only one, he reports the hostname (if 0 or more than 1, none are reported to prevent split brain issues).
PgRoute66 additionally can forward traffic to standby's.
This role installs and configures pgroute66.
This role is part of PgVillage, which is an opinated PostgreSQL deployment for Virtual Machines.

Requirements
------------

This role aims at using an RPM from the MannemSolutions repo.

Role Variables
--------------

Please see [defaults](https://github.com/pgvillage/ansible-role-pgroute66/blob/main/defaults/main.yml) for all variables


Dependencies
------------

No dependencies


Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - pgvillage.pgroute66

License
-------

PostgreSQL

Author Information
------------------

PgVillage is an Open Community.
Main contributor is Nibble-IT.
