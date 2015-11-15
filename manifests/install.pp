# Install the dependencies of lostinmalloc-users
class users::install{
  if $::users::dependencies{
    $::users::dependencies.each |$dependency,$provider|{
      if !defined(Package[$dependency]){
        Package{ $dependency:
          ensure   => $::users::package_ensure,
	  provider => $provider,
	  tag      => 'dependency',
          }
        }
      }
    }
}
