# == define quota::modify
#
# Configure quota for a certain dest
#
# === Params
#
# [*dest*]
#   Path for which configure quota (default: /)
#
# [*opts*]
#   Quota options (default: usrquota,grpquota)
#
# === Examples
#
define modify($dest="/", $opts="usrquota,grpquota") {
  $fstab = "/etc/fstab"
  $tmptab = "/tmp/fstab"

  $quser = "quota.user"
  $qgroup = "quota.group"
  $quotauser = "${dest}${quser}"
  $quotagroup = "${dest}${qgroup}"
		
	exec { "modify-line":
		command	    => "sudo sed -e's#^[^\\ #][^\\ ]*[\\ ][\\ ]*${dest}[\\ ][\\ ]*[^\\ ][^\\ ]*[\\ ][\\ ]*[^\\ ][^\\ ]*#&,${opts}#' -i.orig ${fstab}",
		onlyif  => ["test -z \"`grep -E '^[^#].*[\\ ]${dest}[\\ ]' ${fstab} | grep ${opts}`\""]
	}

	file { "$quotauser":
		ensure      => present,
    mode        => 600,
    owner       => root,
    group       => root,
	}

	file { "$quotagroup":
    ensure      => present,
    mode        => 600,
    owner       => root,
    group       => root,
  }

	exec { "remount":
		command	=> "sudo mount -o remount ${dest}",
    onlyif  => ["test -z \"`mount | grep -E '\\ ${dest}\\ ' | grep ${opts}`\""],
		require => [ File["${quotauser}"], File["${quotagroup}"], Exec["modify-line"] ],
		before  => Exec["quotaon"]
	}

  exec { "quotaon":
    command => "sudo quotaon -avug",
    onlyif  => ["sudo quotacheck -avugm", "test -z \"`mount | grep -E '\\ ${dest}\\ ' | grep ${opts}`\""],
 	}
}
