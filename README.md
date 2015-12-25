# lostinmalloc-users
#### Table of Contents
1. [Overview](#overview)
2. [Module Description](#module-description)
    * [SSH Keys](#ssh-keys)
3. [Setup](#setup)
    * [What lostinmalloc-users affects](#what-lostinmalloc-users-affects)
    * [Requirements](#requirements)
    * [Managing Passwords](#managing-passwords)
    * [Managing Groups](#managing-groups)
4. [Usage](#usage)
5. [Reference](#reference)
6. [Limitations](#limitations)
7. [Development](#development)

## Overview
The `lostinmalloc-users` module manages users and their secrets. It is distributed through the Apache License 2.0. Please do refer to the [LICENSE](https://github.com/jaschac/puppet-users/blob/master/LICENSE) for details.

## Module Description
The `lostinmalloc-users` module allows to manage users. It's main feature is to define whether a user is  present or absent on a specific node.

If the user is present, it allows the client to define:

  - If he has  a `/home`.
  - The groups he belongs to.
  - If he is a *sudoer*.
  - His secrets:
    - System password.
    - His public and/or private SSH key(s).
    - SSH key(s) that are allowed to log into the system *as him*.

If the user is not present:

  - His `/home`, if it does exist, is **wiped out**.

#### SSH Keys
`lostinmalloc-users` is able to deploy both the public and the private SSH keys of an user into his `$HOME/.ssh` directory. Providing the private SSH key is not mandatory. If given, being it sensitive data, it is encrypted through [`hiera-eyaml`](https://github.com/TomPoulton/hiera-eyaml). The end user is expected to properly install and configure Puppet so that is has both the `yaml` and the `eyaml` backends.

`lostinmalloc-users` also allows to generate, for each user it manages, the `authorized_keys` file, whose content are the public SSH keys of those users that can log into the system as one. This has some limitations:

  - Only users directly managed through  `lostinmalloc-users` can be used to state who can log into the system as who through SSH keys, since the module generates the `authorized_keys` fetching data from that provided through Hiera.
  - For a user to log into the system as himself he must provide his key and list himself among in the `authorized_keys` entries.

## Setup
In order to install `lostinmalloc-users`, run the following command:
```bash
$ sudo puppet module install lostinmalloc-users
```
Once installed, managing users on a node through `lostinmalloc-users` is a simple as:
```bash
node 'puppet.lostinmalloc.com' {
  class { 'users': }
}
```
The module does expect all the data to be provided through 'Hiera'. See [Usage](#usage) for examples on how to configure it.

#### What lostinmalloc-users affects
By managing users, `lostinmalloc-users` affects several **critical** aspects of a node:

 - It manages a user's existence. As such, if used on already existing users, **it can potentially wipe out his `$HOME`**.
 - It manages how a user can log in and out, so that it can lock someone out of the system.

Users that are not managed through `lostinmalloc-users` are left untouched.

#### Requirements
In terms of **requirements** `lostinmalloc-users` demands:

  - `puppet >=4.0.0`
  - `hiera-eyaml >= 2.0.8`

In terms of **dependencies**, `lostinmalloc-users` defines two kinds of dependencies:

  - `puppetlabs-stdlib >= 2.2.1`

In order for `lostinmalloc-users` to work, several packages, which can be installed either through `apt` or as a `gem`.

  - **Mandatory*** dependencies are hardcoded into `manifest/params.pp` as `mandatory_dependencies`.
  - **Optional** can be provided by the client through `Hiera` using the key `users::params::extra_dependencies`. For example, to get `cmatrix` installed as an optional dependency, we define it like this in `Hiera`:

```bash
users::params::extra_dependencies:
  cmatrix: 'apt'
```

All of these extra dependencies must be supplied as a hash:

  - The key represents the name of the package.
  - The value represents the provider that Puppet must use to install it.

#### Managing Passwords
Managing a user's password requires `libshadow` to be already installed on the system. This is clearly explained by the `useradd` provider itself in the documentation that comes with the [code](https://github.com/puppetlabs/puppet/blob/master/lib/puppet/provider/user/useradd.rb). This library is essential since it allows Puppet to manage shadows. If the library is not installed when `lostinmalloc-users` is executed and told to add the password of a user, this is what happens:

 - The user will be created and properly configured, but his password will not be set. Puppet, if run in verbose mode, will warn about not being able to manage shadows.
 - The `libshadow` package is installed through gem since it is part of the mandatory dependencies. Starting from the next execution, the user will be updated and his password will be properly set in the shadows.

If Puppet is installed through APT (`puppetlabs-release`), `libshadow` is automatically installed into the system. If otherwise Puppet is manually installed through gems, it is not ans it is duty of the administrator(s) of the system to either install it or notify everyone that the users' passwords will not be set on the first run.

#### Managing Groups
`lostinmalloc-users` allows the client to define, optionally, the groups each user belongs to. Note that each user, by default, belongs to a group named after himself. This is known as the *primary group* of the user, The primary group should not be listed among the groups the user belongs to.

Any other group a user belongs to either exists already or is created before the user itself is created.

Handling groups requires the `libuser` package to be installed. `lostinmalloc-users` defines it as a mandatory dependency, so that its presence is enforced.

## Usage
All data must be provided through `Hiera`. 

In the following example:

  - The user `dave`:
    - Is be created.
    - Owns his `$HOME`.
    - Is a `sudoer`.
    - Can login with username/password.
    - Has both a public and a private SSH keys.
    - Allows users `dave`, `gru` and `stuart` to log in as him through SSH. Note that `gru` does not exist, so it will be skipped.
  - The user `stuart`:
    - Is created.
    - Does not own a `$HOME`.
    - Cannot login with username/password.
    - Has a public SSH key only.
    - Does not allow anyone to log in as him through SSH.

**YAML**
```yaml
---
users::params::accounts:
  dave:
    authorized_keys:
      - 'dave'
      - 'gru'
      - 'stuart'
    groups:
      - 'sudo'
      - 'foo'
    managehome: true
    password: '$6$3xG2CaJYHkmVQ$340oMY0S1YSEwhiPpTC3Qz/Gz3VR2KC4iQefhrc00w2PunFXpYCmTanJ4ORXzMjQGASPEA13IUmwTS82Uj85c1'
    present: true
    ssh:
      key: 'QWERTY'
      key_label: 'dave@minions.com'
      key_type: 'ssh-rsa'
  stuart:
    groups:
      - 'foo'
    managehome: false
    password: ''
    present: true
    ssh:
      key: 'banana'
      key_label: 'stuart@minions.com'
      key_type: 'ssh-rsa'
```
**eYAML**
```yaml
---
users::params::secrets:
  dave:
    ssh:
      private_key: |
        -----BEGIN RSA PRIVATE KEY-----
        super_secret
        -----END RSA PRIVATE KEY-----
```

```bash
$ id dave
uid=1004(dave) gid=1007(dave) groups=1007(dave),27(sudo),1004(foo)
$ id stuart
uid=1005(stuart) gid=1005(stuart) groups=1005(stuart),1004(foo)

$ ls -l /home/dave/.ssh
-rwx------ 1 dave dave 66 Dec 12 19:23 authorized_keys
-rw------- 1 dave dave 75 Dec 25 23:12 dave
-rw-r-xr-x 1 dave dave  6 Dec 25 23:01 dave.pub

$ cat /home/dave/.ssh/authorized_keys
ssh-rsa QWERTY dave@minions.com
ssh-rsa banana stuart@minions.com

$ sudo cat /etc/shadow
dave:$6$3xG2CaJYHkmVQ$340oMY0S1YSEwhiPpTC3Qz/Gz3VR2KC4iQefhrc00w2PunFXpYCmTanJ4ORXzMjQGASPEA13IUmwTS82Uj85c1:16775:0:99999:7:::
stuart::16781:0:99999:7:::
```

## Reference
All data must be provided through `Hiera`. A user is defined by many attributes, some of which, *in italic*, are optional:

**YAML**

  -  *`authorized_keys`*: A list of strings representing users managed through `lostinmalloc-users` that can log into the system as him. The public keys of these users are stored into his `$HOME/.ssh/authorized_keys`. If this value is not given for the user, none can log in as him through SSH keys.
  - *`groups`*: the groups he belongs to. Note that the group named after himself, also known as his *primary group*, should not be listed here, since it is generated automatically by the system. The groups the user belongs to are generated before any user is created, if they don't exist already.
  - `managehome`: a boolean, which defaults to `false`. If `true`, it generates the user has a `/home` named after himself and owns it. This parameter needs to be set as `true` if we want people to log into the system as him through SSH keys, since the `authorized_keys` is stored in his `$HOME/.ssh`.
  - *`password`*: the password used to login into the system. If an empty string is given the user cannot login this way. Note that the password **must not be passed as plain text** but encrypted. On `Debian` systems, the hash can be generated through the following command: `$  mkpasswd -m sha-512`. The command is part of the `makepasswd` package.
  - `present`: a boolean that states whether the user must be present or not. it defaults to false. If `false`, no resources will be allocated for the given user. Note that setting a previously existing user to `false` will wipe his `$HOME` out.
  - *`ssh`*: a hash used to provide the public SSH key of the user. This allows `lostinmalloc-users` to add this key to the `authorized_keys` of any users it manages.

**eYAML**

  - *`ssh`*
    - `private_key`: the private SSH key of the user.

## Limitations
`lostinmalloc-users` has been developed and tested on the following setup(s):

  - Operating Systems:
    - Debian 7 Wheezy (3.2.68-1+deb7u3 x86_64)
    - Debian 8 Jessie (3.16.7-ckt11-1+deb8u3 x86_64)
  - Puppet
    - 4.2.1
  - Hiera
    - 3.0.1
  - Facter
    - 2.4.4
  - Ruby
    - 2.1.6p336

## Development
You can contact me through the official page of this module: https://github.com/jaschac/puppet-users. Please do report any bug and suggest new features/improvements.

