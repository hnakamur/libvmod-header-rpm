%global libvmod_header_git_branch 4.1

Name:              libvmod-header
Version:           20151207
Release:           1%{?dist}
Summary:           Varnish Cookie VMOD
License:           FreeBSD
Source:            https://github.com/varnish/libvmod-header/archive/%{libvmod_header_git_branch}.tar.gz#/libvmod-header-%{libvmod_header_git_branch}.tar.gz
URL:               https://www.varnish-cache.org/vmod/header
Requires:          varnish >= 4.1.0
BuildRequires:     varnish-libs-devel >= 4.1.0
BuildRequires:     git
BuildRequires:     automake
BuildRequires:     autoconf
BuildRequires:     libtool
BuildRequires:     python-docutils

%description
Varnish Module (vmod) for manipulation of duplicated headers (for instance multiple set-cookie headers).

Developed by Varnish Software. Sponsored by Softonic.com

%prep
%setup -q -n %{name}-%{libvmod_header_git_branch}

%build
./autogen.sh
./configure --prefix=%{_prefix}
make

%install
make install DESTDIR=%{buildroot}
rm %{buildroot}%{_libdir}/varnish/vmods/libvmod_header.a
rm %{buildroot}%{_libdir}/varnish/vmods/libvmod_header.la

%files
%doc %{_docdir}/libvmod-header/LICENSE
%doc %{_docdir}/libvmod-header/README.rst
%doc %{_mandir}/man3/vmod_header.3.gz
%{_libdir}/varnish/vmods/libvmod_header.so

%changelog
* Mon Dec  7 2015 Hiroaki Nakamura <hnakamur@gmail.com> - 20151207-1
- Initial package using commit f2ab597174f4abf69129f04e73b77d73d88b0777
