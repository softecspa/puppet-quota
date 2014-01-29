# == class quota
#
#  Install quota package
#
# === Params
#
# === Examples
#
class quota {
	package{ "quota":
        ensure => present,
    }

	#modify { "root":
	#	dest	=> "/",
	#	opts	=> "usrquota,grpquota"
	#}
}
