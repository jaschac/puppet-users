# Add something intelligent
class users::params(
  Optional[
    Hash[
      String,
      Struct[{
        authorized_keys => Optional[
	  Tuple[String, default]
	  ],
	managehome      => Boolean,
	password        => String[0, default],
	present         => Boolean,
	ssh             => Optional[
	  Struct[{
            key       => String[1, default],
	    key_label => String[1, default],
	    key_type  => String[7, 7],
	    }]
	  ],
      }]
      ]
  ] $accounts,
  Optional[Tuple[String, default]] $dependencies,
  Enum[
      'absent',
      'held',
      'installed',
      'latest',
      'present',
      'purged'] $package_ensure,
){
}
