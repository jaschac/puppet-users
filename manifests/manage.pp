#Manages an user, his home and files
define users::manage
  (
  $userdata 	# TODO: add validation
){
  File{
    group => $name,
    mode  => '0700',
    owner => $name,
  }   

  # install all the dependencies before any user is created # this could be superfluous
  # Package <| tag == 'dependency' |> -> User <| |>

  user { $name:
    ensure     => $userdata['present'] ? {
      false => absent,
      true  => present,
      },
    managehome => $userdata['managehome'],
    password   => $userdata['password'], 
    shell      => '/bin/bash',
    groups     => [],
    home       => "/home/${name}",
    require    => Package[keys($::users::dependencies)],
  }   

  if $userdata['managehome'] and $userdata['present'] {

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
      
    file { "/home/${name}/.ssh/authorized_keys":
      ensure  => present,
      content => epp('users/authorized_keys', {'authorized_users' => $userdata['authorized_keys']}),
      require => File["/home/${name}/.ssh"],
    }  
  }   
}
