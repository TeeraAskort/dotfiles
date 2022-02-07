Name:           mednaffe
Version:        0.9.2
Release:        1%{?dist}
Summary:        A front-end (GUI) for mednafen emulator

License:        GPLv3+
URL:            https://github.com/AmatCoder/mednaffe
Source0:        https://github.com/AmatCoder/mednaffe/releases/download/%{version}/%{name}-%{version}.tar.gz

BuildRequires: gcc
BuildRequires: make
BuildRequires: gtk3-devel

Requires:      gtk3
Requires:      mednafen

%description
Mednaffe is a front-end (GUI) for mednafen emulator

Its main features are:
- It is written in C language.
- Available for Linux and Windows.
- The only dependency (on Linux) is GTK+2 (or GTK+3).
- GPLv3 licensed.

%prep
%autosetup -p1

%build
%configure --prefix=/usr
make

%install
%make_install

%files
%{_bindir}/%{name}
%{_datadir}/applications/%{name}.desktop
%{_docdir}/%{name}/AUTHORS
%{_docdir}/%{name}/COPYING
%{_docdir}/%{name}/ChangeLog
%{_docdir}/%{name}/README
%{_datadir}/icons/hicolor/128x128/apps/%{name}.png
%{_datadir}/icons/hicolor/16x16/apps/%{name}.png
%{_datadir}/icons/hicolor/32x32/apps/%{name}.png
%{_datadir}/icons/hicolor/48x48/apps/%{name}.png
%{_datadir}/icons/hicolor/64x64/apps/%{name}.png
%{_datadir}/icons/hicolor/scalable/apps/%{name}.svg
%{_datadir}/pixmaps/%{name}.png

%changelog
