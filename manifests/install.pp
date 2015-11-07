# Install the dependencies of lostinmalloc-users
class users::install{
  if $::users::dependencies{
    $::users::dependencies.each |$dependency|{
      if !defined(Package[$dependency]){
        Package{ $dependency:
          ensure   => $::users::package_ensure,
	  provider => 'gem',
	  tag      => 'dependency',
          }
        }
      }
    }
}
