# lostinmalloc-users
#### Table of Contents
1. [Overview](#overview)
2. [Module Description](#module-description)
    * [SSH Keys](#ssh-keys)
    * [Groups](#groups)
3. [Setup](#setup)
    * [Requirements](#requirements)
        * [Managing Passwords](#managing-passwords)
    * [What lostinmalloc-users affects](#what-lostinmalloc-users-affects)
4. [Usage](#usage)
5. [Reference](#reference)
5. [Limitations](#limitations)
6. [Development](#development)
7. [Contacts](#contacts)

## Overview
The `lostinmalloc-users` module manages groups, users and their secrets. It is distributed through the Apache License 2.0. Please do refer to the LICENSE for details.

## Module Description
The `lostinmalloc-users` module allows to manage both groups and users. As such, it is responsible of:

 - Defining whether a user is present or absent.
  - If the user is present:
     - If he has and owns a /home.
     - The groups he belongs to, apart his primary.
     - If he is a sudoer.
     - His secrets:
         - System password.
         - SSH key(s).
             - His own.
             - Those that can be used to login as him into the system.
  - If the user is not present:
     - His /home, if it does exist, is wiped out.

#### Groups
`lostinmalloc-users` allows the client to define, optionally, the groups each user belongs to. Note that each user, by default, belongs to a group named after himself. This is known as the *primary group* of the user, The primary group should not be listed among the groups the user belongs to.

Any other group a user belongs to either exists already or is created before the user itself is created.

Handling groups requires the `libuser` package to be installed. `lostinmalloc-users` defines it as a mandatory dependency, so that its presence is enforced.

## Setup
In order to install `lostinmalloc-users`, run the following command:
```bash
$ sudo puppet module install lostinmalloc-cntlm
```
Once installed, managing users on a node through lostinmalloc-users is a simple as:
```bash
node 'puppet.lostinmalloc.com' {
  class { 'users': }
}
```

#### Requirements
The `lostinmalloc-users` module requires:

 - All the data to be passed through Hiera. See [usage](#usage) for an example on how to configure it.
 - Puppet 4, since it uses its features.

##### Managing Passwords
Managing a user's password requires `libshadow` to be already installed on the system. This is clearly explained by the `useradd` provider itself in the documentation that comes with the [code](https://github.com/puppetlabs/puppet/blob/master/lib/puppet/provider/user/useradd.rb). This library is essential since it allows Puppet to manage shadows. If the library is not installed when `lostinmalloc-users` is executed and told to add the password of a user, this is what happens:

 - The user will be created and properly configured, but his password will not be set. Puppet, if run in verbose mode, will warn about not being able to manage shadows.
 - The `libshadow` package is installed through gem since it is part of the mandatory dependencies. Starting from the next execution, the user will be updated and his password will be properly set in the shadows.

If Puppet is installed through APT (`puppetlabs-release`), `libshadow` is automatically installed into the system. If otherwise Puppet is manually installed through gems, it is not ans it is duty of the administrator(s) of the system to either install it or notify everyone that the users' passwords will not be set on the first run.

### What lostinmalloc-users affects
By managing users, `lostinmalloc-users` affects several critical aspects of a node:

 - It manages how a user can log in and out, so that it can lock someone out of the system.
 - It manages a user's home directory, so **it can potentially wipe out all his files**.

## Reference
Users are represented as virtual resources, which are first validated then realized. Their data must be provided through Hiera. A user has the following attributes:

 * authorized_keys: A list of strings. Each represent a user of the system. The public SSH key of each user of this list is copeid into the $HOME/.ssh/authorized_keys of this specific user, allowing each of them to login into the system as him through SSH (assuming the system allows SSH connections). The module checks both that the user is defined and has the ssh information properly defined. The user is skipped otherwise. This means that for a user to be able to login as himself into the system through SSH, he must appear in his own authorized_keys and have ssh properly defined. Note that the user does not need to be present in the system, but in the catalog to have his SSH key deployed to login as another user into the system.
 * managehome: a boolean defaulting to false. If true, generates the /home directory of the user. It is required in order to login as the user through SSH.
 * password: the password used to login into the system. It defaults to an empty string, meaning the user cannot login this way. The password must not be passed as plain text but encrypted. On Debian systems, the hash can be generated through the following command: ```bash $  mkpasswd -m sha-512```. The command is part of the makepasswd package. Make sure it is installed. Note that in order to properly working with passwords, ruby-shadow and libshadow-ruby must be installed. They are defined as virtual resources and as dependencies that the class itself realizes in the init. If the packages are not present, Ruby will not be able to handle /etc/shadow, which results in the user having his password marked with an exclamation mark.
 * present: a boolean that tells if the user must be present or not in the system. it defaults to false. If false, no resources will be allocated for the given user.
 * ssh: an optional parameter, defined as a hash. It does provide the public SSH key of the user. This parameter alone will not allow the user to login into the system as himself through SSH. This allows the user to be defined in the authorized_keys of any user of the system though.

A user is, by default,disabled in the system. As such:

 - He has a home but it is not accessible.
 - He cannot log into the system
 - His SSH keys are not working on any account.

Users that are already present in the system but that are not managed through Puppet are left untouched.

## Usage
@TODO

## Limitations
@TODO

## Development
The `lostinmalloc-users` module is being actively developed. As functionality is added and tested, it will be cherry-picked into the master branch. This `README` file will be promptly updated as t hat happens. You can contact me through the official page of this module: https://github.com/jaschac/puppet-users. Please do report any bug and suggest new features/improvements.

## Contacts
If you want to report a bug, suggest a change or simply get in touch with me, feel free to:

 - [Linked](https://es.linkedin.com/in/jaschacasadio)
 - [jascha at lostinmalloc.com](jascha@lostinmalloc.com)
 - [GitHub](https://github.com/jaschac)

