# Users and group management
class users
  (
) inherits ::users::params{

  contain ::users::install
  contain ::users::config
  
  if $::users::accounts{
    $::users::accounts.each |$username, $userdata|{
      
      # Create the users associated to the user, if any
      if $userdata['groups']{
        $userdata['groups'].each |$groupname|{
          if !defined(Group[$groupname]){
            Group { $groupname:
	      name   => $groupname,
	      ensure => present,
	      }
	    }
	  }
	}

      @users::manage{$username:
        userdata => $userdata,
	}
      realize(Users::Manage[$username])
    }
  }
}
