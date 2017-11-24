# sshportal

Jump host/Jump server without the jump, a.k.a Transparent SSH bastion

```
                       ┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─
                                  DMZ           │
┌────────┐             │             ┌────────┐
│ homer  │───▶╔═════════════════╗───▶│ host1  │ │
└────────┘    ║                 ║    └────────┘
┌────────┐    ║                 ║    ┌────────┐ │
│  bart  │───▶║    sshportal    ║───▶│ host2  │
└────────┘    ║                 ║    └────────┘ │
┌────────┐    ║                 ║    ┌────────┐
│  lisa  │───▶╚═════════════════╝───▶│ host3  │ │
└────────┘             │             └────────┘
┌────────┐                           ┌────────┐ │
│  ...   │             │             │  ...   │
└────────┘                           └────────┘ │
                       └ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─
```

## Features

* Host management
* User management
* User Group management
* Host Group management
* Host Key management
* User Key management
* ACL management
* Connect to host using key or password
* Admin commands can be run directly or in an interactive shell
* User Roles
* User invitations
* Easy authorized_keys installation
* Sensitive data encryption

## Usage

Start the server

```console
$ sshportal
2017/11/13 10:58:35 Admin user created, use the user 'invite:BpLnfgDsc2WD8F2q' to associate a public key with this account
2017/11/13 10:58:35 SSH Server accepting connections on :2222
```

Link your SSH key with the admin account

```console
$ ssh localhost -p 2222 -l invite:BpLnfgDsc2WD8F2q
Welcome Administrator!

Your key is now associated with the user "admin@sshportal".
Shared connection to localhost closed.
$
```

Drop an interactive administrator shell

```console
ssh localhost -p 2222 -l admin


    __________ _____           __       __
   / __/ __/ // / _ \___  ____/ /____ _/ /
  _\ \_\ \/ _  / ___/ _ \/ __/ __/ _ '/ /
 /___/___/_//_/_/   \___/_/  \__/\_,_/_/


config>
```

Create your first host

```console
config> host create bart@foo.example.org
1
config>
```

List hosts

```console
config> host ls
  ID | NAME |           URL           |   KEY   | PASS | GROUPS  | COMMENT
+----+------+-------------------------+---------+------+---------+---------+
   1 | foo  | bart@foo.example.org:22 | default |      | default |
Total: 1 hosts.
config>
```

Add the key to the server

```console
$ ssh bart@foo.example.org "$(ssh localhost -p 2222 -l admin key setup default)"
$
```

Profit

```console
ssh localhost -p 2222 -l foo
bart@foo>
```

Invite friends

```console
config> user invite bob@example.com
User 2 created.
To associate this account with a key, use the following SSH user: 'invite-NfHK5a84jjJkwzDk'.
config>
```

## CLI

sshportal embeds a configuration CLI.

By default, the configuration user is `admin`, (can be changed using `--config-user=<value>` when starting the server.

Each commands can be run directly by using this syntax: `ssh admin@portal.example.org <command> [args]`:

```
ssh admin@portal.example.org host inspect toto
```

You can enter in interactive mode using this syntax: `ssh admin@portal.example.org`

### Synopsis

```sh
# acl management
acl help
acl create [-h] [--hostgroup=HOSTGROUP...] [--usergroup=USERGROUP...] [--pattern=<value>] [--comment=<value>] [--action=<value>] [--weight=value]
acl inspect [-h] ACL...
acl ls [-h]
acl rm [-h] ACL...
acl update [-h] [--comment=<value>] [--action=<value>] [--weight=<value>] [--assign-hostgroup=HOSTGROUP...] [--unassign-hostgroup=HOSTGROUP...] [--assign-usergroup=USERGROUP...] [--unassign-usergroup=USERGROUP...] ACL...

# config management
config help
config backup [-h] [--indent] [--decrypt]
config restore [-h] [--confirm] [--decrypt]

# host management
host help
host create [-h] [--name=<value>] [--password=<value>] [--fingerprint=<value>] [--comment=<value>] [--key=KEY] [--group=HOSTGROUP...] <username>[:<password>]@<host>[:<port>]
host inspect [-h] [--decrypt] HOST...
host ls [-h]
host rm [-h] HOST...
host update [-h] [--name=<value>] [--comment=<value>] [--fingerprint=<value>] [--key=KEY] [--assign-group=HOSTGROUP...] [--unassign-group=HOSTGROUP...] HOST...

# hostgroup management
hostgroup help
hostgroup create [-h] [--name=<value>] [--comment=<value>]
hostgroup inspect [-h] HOSTGROUP...
hostgroup ls [-h]
hostgroup rm [-h] HOSTGROUP...

# key management
key help
key create [-h] [--name=<value>] [--type=<value>] [--length=<value>] [--comment=<value>]
key inspect [-h] [--decrypt] KEY...
key ls [-h]
key rm [-h] KEY...
key setup [-h] KEY

# user management
user help
user invite [-h] [--name=<value>] [--comment=<value>] [--group=USERGROUP...] <email>
user inspect [-h] USER...
user ls [-h]
user rm [-h] USER...
user update [-h] [--name=<value>] [--email=<value>] [--set-admin] [--unset-admin] [--assign-group=USERGROUP...] [--unassign-group=USERGROUP...] USER...

# usergroup management
usergroup help
hostgroup create [-h] [--name=<value>] [--comment=<value>]
usergroup inspect [-h] USERGROUP...
usergroup ls [-h]
usergroup rm [-h] USERGROUP...

# other
exit [-h]
help, h
info [-h]
version [-h]
```

## Docker

Docker is the recommended way to run sshportal.

An [automated build is setup on the Docker Hub](https://hub.docker.com/r/moul/sshportal/tags/).

```console
# Start a server in background
#   mount `pwd` to persist the sqlite database file
docker run -p 2222:2222 -d --name=sshportal -v "$(pwd):$(pwd)" -w "$(pwd)" moul/sshportal:v1.4.0

# check logs (mandatory on first run to get the administrator invite token)
docker logs -f sshportal
```

The easier way to upgrade sshportal is to do the following:

```sh
# we consider you were using an old version and you want to use the new version v1.4.0

# stop and rename the last working container + backup the database
docker stop sshportal
docker rename sshportal sshportal_old
cp sshportal.db sshportal.db.bkp

# run the new version
docker run -p 2222:2222 -d --name=sshportal -v "$(pwd):$(pwd)" -w "$(pwd)" moul/sshportal:v1.4.0
# check the logs for migration or cross-version incompabitility errors
docker logs -f sshportal
```

Now you can test ssh-ing to sshportal to check if everything looks OK.

In case of problem, you can rollback to the latest working version with the latest working backup, using:

```sh
docker stop sshportal
docker rm sshportal
cp sshportal.db.bkp sshportal.db
docker rename sshportal_old sshportal
docker start sshportal
docker logs -f sshportal
```

## Manual Install

Get the latest version using GO.

```sh
go get -u github.com/moul/sshportal
```

## Backup / Restore

sshportal embeds built-in backup/restore methods which basically import/export JSON objects:

```sh
# Backup
ssh admin@sshportal config backup  > sshportal.bkp

# Restore
ssh admin@sshportal config restore < sshportal.bkp
```

This method is particularly useful as it should be resistant against future DB schema changes (expected during development phase).

I suggest you to be careful during this development phase, and use an additional backup method, for example:

```sh
# sqlite dump
sqlite3 sshportal.db .dump > sshportal.sql.bkp

# or just the immortal cp
cp sshportal.db sshportal.db.bkp
```
