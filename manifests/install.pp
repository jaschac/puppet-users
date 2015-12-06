# Install the dependencies of lostinmalloc-users
class users::install{

  $mandatory_dependencies = empty($::users::mandatory_dependencies) ? {
    false => $::users::mandatory_dependencies,
    true  => {},
  }

  $extra_dependencies = empty($::users::extra_dependencies) ? {
    false => $::users::extra_dependencies,
    true  => {},
  }

  $dependencies = merge($mandatory_dependencies, $extra_dependencies)

  if !empty($dependencies){
    $dependencies.each |$dependency,$provider| {
      if !defined(Package[$dependency]) {
        Package { $dependency:
          ensure   => $::users::package_ensure,
          provider => $provider,
          tag      => 'dependency',
        }   
      }   
    }
  }

}
