# Manages groups
define users::groups::manage
  (
  Optional[
    Array[String, 1]
    ] $data
){
  
  $data.each |$groupname|{
    if !defined(Group[$groupname]){
      Group { $groupname:
        name   => $groupname,
        ensure => present,
      }
    }
  }

}
