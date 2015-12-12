# Manages an user, his home and files
define users::manage
  (
  Struct[{
    authorized_keys => Optional[
      Tuple[String, default]
    ],
    groups => Optional[
      Array[String, 1]
    ],
    managehome => Boolean,
    password   => String[0, default],
    present    => Boolean,
    ssh        => Optional[
      Struct[{
        key       => String[1, default],
        key_label => String[1, default],
        key_type  => String[7, 7],
      }]
    ],
  }] $userdata
){
  File {
    group => $name,
    mode  => '0700',
    owner => $name,
  }

  user { $name:
    ensure   => $userdata['present'] ? {
      false  => absent,
      true   => present,
    },
    password => $userdata['password'],
    shell    => '/bin/bash',
    groups   => empty($userdata['groups']) ? {
      false  => $userdata['groups'],
      true   => [],
    },
    home     => "/home/${name}",
    require  => Package[[keys($::users::mandatory_dependencies)], [keys($::users::extra_dependencies)]],
  }

  if $userdata['present'] and $userdata['managehome'] {
      
      file { "/home/${name}":
        ensure  => directory,
        mode    => '0755',
        owner   => $name,
        require => User[$name],
      }

      file { "/home/${name}/.ssh":
        ensure  => directory,
        owner   => $name,
        require => File["/home/${name}"],
      }
      
      if ! empty($userdata['authorized_keys']) {
        file { "/home/${name}/.ssh/authorized_keys":
          ensure  => present,
          content => epp('users/authorized_keys', {'authorized_users' => $userdata['authorized_keys'    ]}),
          owner   => $name,
          require => File["/home/${name}/.ssh"],
        }
      }
    }
  
  else {
    
    file { "/home/${name}":
      ensure  => absent,
      force   => true,
      require => User[$name],
    }

  }

}
