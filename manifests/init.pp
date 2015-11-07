# Users and group management
class users
  (
) inherits ::users::params{

  contain ::users::install
  contain ::users::config
  
  if $::users::accounts{
    $::users::accounts.each |$username, $userdata|{
      @users::manage{$username:
        userdata => $userdata,
	}
      realize(Users::Manage[$username])
    }
  }
}
