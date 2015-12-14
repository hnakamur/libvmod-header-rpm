#!/bin/bash -x
set -eu

project_name=libvmod-header
rpm_name=libvmod-header
arch=x86_64

spec_file=${rpm_name}.spec
base_chroot=epel-7-${arch}
mock_chroot=epel-7-varnish-${arch}

varnish_repo_id='varnish-4.1'
varnish_repo_name='Varnish Cache 4.1 for Enterprise Linux'
varnish_repo_baseurl='https://repo.varnish-cache.org/redhat/varnish-4.1/el7/$basearch'

copr_project_description="A header-modification vmod for Varnish"

copr_project_instructions="\`\`\`
sudo curl -sL -o /etc/yum.repos.d/${COPR_USERNAME}-${project_name}.repo https://copr.fedoraproject.org/coprs/${COPR_USERNAME}/${project_name}/repo/epel-7/${COPR_USERNAME}-${project_name}-epel-7.repo
\`\`\`

\`\`\`
sudo yum install ${rpm_name}
\`\`\`"

topdir=`rpm --eval '%{_topdir}'`

usage() {
  cat <<'EOF' 1>&2
Usage: build.sh subcommand

subcommand:
  srpm          build the srpm
  mock          build the rpm locally with mock
  copr          upload the srpm and build the rpm on copr
EOF
}

download_source_files() {
  # NOTE: Edit commands here.
  source_url=`rpmspec -P ${topdir}/SPECS/${spec_file} | awk '$1=="Source:" { print $2 }'`
  source_file=${source_url##*/}
  (cd ${topdir}/SOURCES \
    && if [ ! -f ${source_file} ]; then curl -sLO ${source_url}; fi)
}

create_varnish_repo_file() {
  varnish_repo_file=varnish-4.1.repo
  if [ ! -f $varnish_repo_file ]; then
    # NOTE: Although https://repo.varnish-cache.org/redhat/varnish-4.1.el7.rpm at https://www.varnish-cache.org/installation/redhat
    #       has the gpgkey in it, I don't use it since I don't know how to add it to /etc/mock/*.cfg
    cat > ${varnish_repo_file} <<EOF
[${varnish_repo_id}]
name=${varnish_repo_name}
baseurl=${varnish_repo_baseurl}
enabled=1
gpgcheck=0
EOF
  fi
}

create_mock_chroot_cfg() {
  create_varnish_repo_file

  # Insert ${scl_repo_file} before closing """ of config_opts['yum.conf']
  # See: http://unix.stackexchange.com/a/193513/135274
  #
  # NOTE: Support of adding repository was added to mock,
  #       so you can use it in the future.
  # See: https://github.com/rpm-software-management/ci-dnf-stack/issues/30
  (cd ${topdir} \
    && echo | sed -e '$d;N;P;/\n"""$/i\
' -e '/\n"""$/r '${varnish_repo_file} -e '/\n"""$/a\
' -e D /etc/mock/${base_chroot}.cfg - | sudo sh -c "cat > /etc/mock/${mock_chroot}.cfg")
}

build_srpm() {
  download_source_files
  create_mock_chroot_cfg
  rpmbuild -bs "${topdir}/SPECS/${spec_file}"
  version=`rpmspec -P ${topdir}/SPECS/${spec_file} | awk '$1=="Version:" { print $2 }'`
  release=`rpmspec -P ${topdir}/SPECS/${spec_file} | awk '$1=="Release:" { print $2 }'`
  rpm_version_release=${version}-${release}
  srpm_file=${rpm_name}-${rpm_version_release}.src.rpm
}

build_rpm_with_mock() {
  build_srpm
  /usr/bin/mock -r ${mock_chroot} --rebuild ${topdir}/SRPMS/${srpm_file}

  mock_result_dir=/var/lib/mock/${base_chroot}/result
  if [ -n "`find ${mock_result_dir} -maxdepth 1 -name \"${rpm_name}-*${rpm_version_release}.${arch}.rpm\" -print -quit`" ]; then
    mkdir -p ${topdir}/RPMS/${arch}
    cp ${mock_result_dir}/${rpm_name}-*${rpm_version_release}.${arch}.rpm ${topdir}/RPMS/${arch}/
  fi
  if [ -n "`find ${mock_result_dir} -maxdepth 1 -name \"${rpm_name}-*${rpm_version_release}.noarch.rpm\" -print -quit`" ]; then
    mkdir -p ${topdir}/RPMS/noarch
    cp ${mock_result_dir}/${rpm_name}-*${rpm_version_release}.noarch.rpm ${topdir}/RPMS/noarch/
  fi
}

build_rpm_on_copr() {
  build_srpm

  # Check the project is already created on copr.
  status=`curl -s -o /dev/null -w "%{http_code}" https://copr.fedoraproject.org/api/coprs/${COPR_USERNAME}/${project_name}/detail/`
  if [ $status = "404" ]; then
    # Create the project on copr.
    # We call copr APIs with curl to work around the InsecurePlatformWarning problem
    # since system python in CentOS 7 is old.
    # I read the source code of https://pypi.python.org/pypi/copr/1.62.1
    # since the API document at https://copr.fedoraproject.org/api/ is old.
    curl -s -X POST -u "${COPR_LOGIN}:${COPR_TOKEN}" \
      --data-urlencode "name=${project_name}" \
      --data-urlencode "${base_chroot}=y" \
      --data-urlencode "repos=${varnish_repo_baseurl}" \
      --data-urlencode "description=$copr_project_description" \
      --data-urlencode "instructions=$copr_project_instructions" \
      https://copr.fedoraproject.org/api/coprs/${COPR_USERNAME}/new/
  fi
  # Add a new build on copr with uploading a srpm file.
  curl -s -X POST -u "${COPR_LOGIN}:${COPR_TOKEN}" \
    -F "${base_chroot}=y" \
    -F "pkgs=@${topdir}/SRPMS/${srpm_file};type=application/x-rpm" \
    https://copr.fedoraproject.org/api/coprs/${COPR_USERNAME}/${project_name}/new_build_upload/
}

case "${1:-}" in
srpm)
  build_srpm
  ;;
mock)
  build_rpm_with_mock
  ;;
copr)
  build_rpm_on_copr
  ;;
*)
  usage
  ;;
esac
