# Install the dependencies of lostinmalloc-users
class users::install{
  if $::users::mandatory_dependencies {
    $::users::mandatory_dependencies.each |$dependency,$provider| {
      if !defined(Package[$dependency]) {
        Package { $dependency:
          ensure   => $::users::package_ensure,
	  provider => $provider,
	  tag      => 'mandatory_dependency',
        }
      }
    }
  }

  if $::users::extra_dependencies {
    $::users::extra_dependencies.each |$dependency,$provider| {
      if !defined(Package[$dependency]) {
        Package { $dependency:
          ensure   => $::users::package_ensure,
          provider => $provider,
          tag      => 'extra_dependency',
        }
      }
    }
  }
}
