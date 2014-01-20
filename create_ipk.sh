#!/bin/bash

D=$(pushd $(dirname $0) &> /dev/null; pwd; popd &> /dev/null)
P=${D}/ipkg.tmp.$$
B=${D}/ipkg.build.$$

pushd ${D} &> /dev/null
#VER=$(head -n 3 CHANGES.md | grep -i '## Version' | sed 's/^## Version \([[:digit:]]\+\.[[:digit:]]\+\.[[:digit:]]\+\)/\1/')
VER=1.4
GITVER=git$(git log -1 --format="%ci" | awk -F" " '{ print $1 }' | tr -d "-")
PKG=${D}/binaries/enigma2-plugin-extensions-virtualzappicon_${VER}-${GITVER}_all.ipk
popd &> /dev/null

mkdir -p ${P}
mkdir -p ${P}/CONTROL
mkdir -p ${B}

cat > ${P}/CONTROL/control << EOF
Package: enigma2-plugin-extensions-virtualzappicon
Version: ${VER}-${GITVER}
Section: misc
OE: enigma2-plugins
License: CC_BY-NC-SA_3.0
Priority: optional
Architecture: all
Conflicts: enigma2-plugin-extensions-virtualzap
Maintainer: herpoi <herpoi2006@gmail.com>
Description: E2 VirtualZap plugin with picon widget
Source: https://github.com/herpoi
Homepage: https://github.com/herpoi
EOF

cat > ${P}/CONTROL/postrm << EOF
#!/bin/sh
rm -R /usr/lib/enigma2/python/Plugins/Extensions/VirtualZap
EOF

chmod +x ${P}/CONTROL/postrm
mkdir -p ${P}/usr/lib/enigma2/python/Plugins/Extensions/VirtualZap/
cp -rp ${D}/VirtualZap/* ${P}/usr/lib/enigma2/python/Plugins/Extensions/VirtualZap/
#cp -rp ${D}/locale ${P}/usr/lib/enigma2/python/Plugins/Extensions/VirtualZap/

tar -C ${P} -czf ${B}/data.tar.gz . --exclude=CONTROL
tar -C ${P}/CONTROL -czf ${B}/control.tar.gz .

echo "2.0" > ${B}/debian-binary

cd ${B}
ls -la
ar -r ${PKG} ./debian-binary ./data.tar.gz ./control.tar.gz 
cd -

rm -rf ${P}
rm -rf ${B}
