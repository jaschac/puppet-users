# Add something intelligent
class users::params(

  Optional[
    Hash[
      String,
      Struct[{
        authorized_keys => Optional[
          Tuple[String, default]
        ],
        groups => Optional[
          Array[String, 1]
        ],
        managehome => Boolean,
        password   => Optional[String[0, default]],
        present    => Boolean,
        ssh        => Optional[
          Struct[{
            key       => String[1, default],
            key_label => String[1, default],
            key_type  => String[7, 7],
          }]
        ],
      }]
      ]
  ] $accounts,

  Optional[
    Hash[
      String,
      String
    ]
  ] $extra_dependencies,

  $mandatory_dependencies = {
    libshadow => 'gem',
    libuser   => 'apt',
    sudo      => 'apt',
  }
){
}
