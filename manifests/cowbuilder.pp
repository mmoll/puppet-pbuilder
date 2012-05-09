define pbuilder::cowbuilder (
  $ensure='present',
  $dist=$lsbdistcodename,
  $arch=$architecture,
  $cachedir='/var/cache/pbuilder',
  $confdir='/etc/pbuilder',
  $pbuilderrc=''
) {

  include pbuilder::cowbuilder::common

  $cowbuilder = '/usr/sbin/cowbuilder'
  $basepath = "${cachedir}/base-${name}.cow"

  case $ensure {
    present: {
      file {
        "${confdir}/${name}":
          ensure  => directory,
          require => Package['pbuilder'];

        "${confdir}/${name}/apt":
          ensure  => directory,
          require => File["${confdir}/${name}"];

        "${confdir}/${name}/apt/sources.list.d":
          ensure  => directory,
          require => File["${confdir}/${name}/apt"];

        "${confdir}/${name}/pbuilderrc":
          ensure  => present,
          content => $pbuilderrc,
      }

      exec {
        "create cowbuilder ${name}":
          command => "${cowbuilder} --create --basepath ${basepath} --dist ${dist} --architecture ${arch}",
          require => File['/etc/pbuilderrc'],
          creates => $basepath;

        "update cowbuilder ${name}":
          command     => "${cowbuilder} --update --configfile ${confdir}/${name}/pbuilderrc --override-config --basepath ${basepath} --dist ${dist} --architecture ${arch}",
          refreshonly => true;
      }
    }

    absent: {

    }

    default: {
      fail("Wrong value for ensure: ${ensure}")
    }
  }
  

}