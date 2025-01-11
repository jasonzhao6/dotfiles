# https://zsh.sourceforge.io/Doc/Release/Shell-Grammar.html#Reserved-Words
# do done esac then elif else fi for case if while function repeat time until select coproc nocorrect foreach end ! [[ { } declare export float integer local readonly typeset
# See notes at the bottom of the file on how this list was generated

typeset -A RESERVED

function is_reserved {
	local keyword=$1

	[[ ${RESERVED[$keyword]} -eq 1 ]]
}

# Unreserved
RESERVED[aa]=0
RESERVED[ar]=0
RESERVED[as]=0

# Reserved
RESERVED[2to3-3.10]=1
RESERVED[2to3-3.11]=1
RESERVED[2to3-3.12]=1
RESERVED[2to3-3.9]=1
RESERVED[2to3]=1
RESERVED[411toppm]=1
RESERVED[BTLEServer]=1
RESERVED[BlueTool]=1
RESERVED[DeRez]=1
RESERVED[IOSDebug]=1
RESERVED[ResMerger]=1
RESERVED[Rez]=1
RESERVED[SetFile]=1
RESERVED[SplitForks]=1
RESERVED[ab]=1
RESERVED[ac]=1
RESERVED[accton]=1
RESERVED[aclocal]=1
RESERVED[actool]=1
RESERVED[acyclic]=1
RESERVED[adig]=1
RESERVED[aea]=1
RESERVED[afclip]=1
RESERVED[afconvert]=1
RESERVED[afhash]=1
RESERVED[afida]=1
RESERVED[afinfo]=1
RESERVED[afktool]=1
RESERVED[afplay]=1
RESERVED[afscexpand]=1
RESERVED[agentxtrap]=1
RESERVED[agvtool]=1
RESERVED[ahost]=1
RESERVED[alias]=1
RESERVED[amagent]=1
RESERVED[amt]=1
RESERVED[annotate]=1
RESERVED[ansible]=1
RESERVED[anytopnm]=1
RESERVED[aomdec]=1
RESERVED[aomenc]=1
RESERVED[apachectl]=1
RESERVED[app-sso]=1
RESERVED[apply]=1
RESERVED[appsleepd]=1
RESERVED[apropos]=1
RESERVED[apt]=1
RESERVED[arch]=1
RESERVED[aria_chk]=1
RESERVED[aria_pack]=1
RESERVED[arp]=1
RESERVED[asa]=1
RESERVED[asciitopgm]=1
RESERVED[aslmanager]=1
RESERVED[asr]=1
RESERVED[assetutil]=1
RESERVED[at]=1
RESERVED[atktopbm]=1
RESERVED[atos]=1
RESERVED[atq]=1
RESERVED[atrm]=1
RESERVED[atsutil]=1
RESERVED[audit]=1
RESERVED[auditd]=1
RESERVED[authserver:]=1
RESERVED[autoconf]=1
RESERVED[autoheader]=1
RESERVED[autom4te]=1
RESERVED[automake]=1
RESERVED[automator]=1
RESERVED[automount]=1
RESERVED[autopoint]=1
RESERVED[autoreconf]=1
RESERVED[autoscan]=1
RESERVED[autoupdate]=1
RESERVED[auval]=1
RESERVED[auvaltool]=1
RESERVED[avbdeviced]=1
RESERVED[avbutil]=1
RESERVED[avconvert]=1
RESERVED[avdb-cli]=1
RESERVED[avifdec]=1
RESERVED[avifenc]=1
RESERVED[avstopam]=1
RESERVED[awk]=1
RESERVED[aws]=1
RESERVED[b2sum]=1
RESERVED[banner]=1
RESERVED[base32]=1
RESERVED[base64]=1
RESERVED[basename]=1
RESERVED[basenc]=1
RESERVED[bash]=1
RESERVED[bashbug]=1
RESERVED[batch]=1
RESERVED[bazel]=1
RESERVED[bc]=1
RESERVED[bcomps]=1
RESERVED[bdftogd]=1
RESERVED[bg]=1
RESERVED[binhex.pl]=1
RESERVED[binhex]=1
RESERVED[bintrans]=1
RESERVED[bioutil]=1
RESERVED[bison]=1
RESERVED[bitesize.d]=1
RESERVED[black]=1
RESERVED[blackd]=1
RESERVED[bless]=1
RESERVED[bluetoothd]=1
RESERVED[bm4]=1
RESERVED[bmptopnm]=1
RESERVED[bmptoppm]=1
RESERVED[bputil]=1
RESERVED[brctl]=1
RESERVED[brew]=1
RESERVED[brotli]=1
RESERVED[brushtopbm]=1
RESERVED[bsdtar]=1
RESERVED[bspatch]=1
RESERVED[bundle]=1
RESERVED[bundler]=1
RESERVED[bunzip2]=1
RESERVED[bzcat]=1
RESERVED[bzcmp]=1
RESERVED[bzdiff]=1
RESERVED[bzegrep]=1
RESERVED[bzfgrep]=1
RESERVED[bzgrep]=1
RESERVED[bzip2]=1
RESERVED[bzless]=1
RESERVED[bzmore]=1
RESERVED[c++]=1
RESERVED[c++filt]=1
RESERVED[c89]=1
RESERVED[c99]=1
RESERVED[c_rehash]=1
RESERVED[caffeinate]=1
RESERVED[cal]=1
RESERVED[calendar]=1
RESERVED[cancel]=1
RESERVED[cap_mkdb]=1
RESERVED[captoinfo]=1
RESERVED[captoinfo]=1
RESERVED[cargo]=1
RESERVED[cat]=1
RESERVED[cc]=1
RESERVED[ccmake]=1
RESERVED[ccomps]=1
RESERVED[cd]=1
RESERVED[cdiff]=1
RESERVED[certtool]=1
RESERVED[cfprefsd]=1
RESERVED[chardetect]=1
RESERVED[chat]=1
RESERVED[chcon]=1
RESERVED[checkgid]=1
RESERVED[chflags]=1
RESERVED[chfn]=1
RESERVED[chgrp]=1
RESERVED[chmod]=1
RESERVED[chown]=1
RESERVED[chpass]=1
RESERVED[chroot]=1
RESERVED[chsh]=1
RESERVED[circo]=1
RESERVED[cistopbm]=1
RESERVED[cjpeg]=1
RESERVED[cjpeg_hdr]=1
RESERVED[cjxl]=1
RESERVED[ckksctl]=1
RESERVED[cksum]=1
RESERVED[clang++]=1
RESERVED[clang]=1
RESERVED[clangd]=1
RESERVED[clear]=1
RESERVED[clear]=1
RESERVED[cluster]=1
RESERVED[cmake]=1
RESERVED[cmark]=1
RESERVED[cmp]=1
RESERVED[cmpdylib]=1
RESERVED[cmuwmtopbm]=1
RESERVED[codecctl]=1
RESERVED[codesign]=1
RESERVED[col]=1
RESERVED[colldef]=1
RESERVED[colordiff]=1
RESERVED[colrm]=1
RESERVED[column]=1
RESERVED[comm]=1
RESERVED[command]=1
RESERVED[compress]=1
RESERVED[coreaudiod]=1
RESERVED[corelist]=1
RESERVED[coverage3]=1
RESERVED[coverage]=1
RESERVED[cp]=1
RESERVED[cpack]=1
RESERVED[cpan-5.30]=1
RESERVED[cpan5.30]=1
RESERVED[cpan5.34]=1
RESERVED[cpan]=1
RESERVED[cpio]=1
RESERVED[cpp]=1
RESERVED[cpuctl]=1
RESERVED[cpuinfo]=1
RESERVED[cpuwalk.d]=1
RESERVED[crc325.30]=1
RESERVED[crc325.34]=1
RESERVED[crc32]=1
RESERVED[crlrefresh]=1
RESERVED[cron]=1
RESERVED[crontab]=1
RESERVED[csh]=1
RESERVED[csplit]=1
RESERVED[csreq]=1
RESERVED[csrutil]=1
RESERVED[ctags]=1
RESERVED[ctest]=1
RESERVED[ctf_insert]=1
RESERVED[cu]=1
RESERVED[cupsaccept]=1
RESERVED[cupsctl]=1
RESERVED[cupsd]=1
RESERVED[cupsenable]=1
RESERVED[cupsfilter]=1
RESERVED[cupsreject]=1
RESERVED[curl]=1
RESERVED[cut]=1
RESERVED[cvadmin]=1
RESERVED[cvaffinity]=1
RESERVED[cvcp]=1
RESERVED[cvdb]=1
RESERVED[cvdbset]=1
RESERVED[cvfsck]=1
RESERVED[cvfsdb]=1
RESERVED[cvfsid]=1
RESERVED[cvgather]=1
RESERVED[cvlabel]=1
RESERVED[cvmkdir]=1
RESERVED[cvmkfile]=1
RESERVED[cvmkfs]=1
RESERVED[cvupdatefs]=1
RESERVED[cvversions]=1
RESERVED[cwebp]=1
RESERVED[daemondo]=1
RESERVED[dappprof]=1
RESERVED[dapptrace]=1
RESERVED[dash]=1
RESERVED[date]=1
RESERVED[db48_dump]=1
RESERVED[db48_load]=1
RESERVED[db48_sql]=1
RESERVED[db48_stat]=1
RESERVED[db_archive]=1
RESERVED[db_codegen]=1
RESERVED[db_dump]=1
RESERVED[db_load]=1
RESERVED[db_recover]=1
RESERVED[db_stat]=1
RESERVED[db_upgrade]=1
RESERVED[db_verify]=1
RESERVED[dbicadmin]=1
RESERVED[dbiprof]=1
RESERVED[dbiproxy]=1
RESERVED[dbmmanage]=1
RESERVED[dc]=1
RESERVED[dd]=1
RESERVED[ddbugtopbm]=1
RESERVED[ddev]=1
RESERVED[defaults]=1
RESERVED[delaunay]=1
RESERVED[delv]=1
RESERVED[demandoc]=1
RESERVED[derq]=1
RESERVED[desdp]=1
RESERVED[dev_mkdb]=1
RESERVED[devmodectl]=1
RESERVED[df]=1
RESERVED[diff3]=1
RESERVED[diff]=1
RESERVED[diffimg]=1
RESERVED[diffstat]=1
RESERVED[dig]=1
RESERVED[dijkstra]=1
RESERVED[dirname]=1
RESERVED[disklabel]=1
RESERVED[diskutil]=1
RESERVED[dispqlen.d]=1
RESERVED[distnoted]=1
RESERVED[distro]=1
RESERVED[ditto]=1
RESERVED[djpeg]=1
RESERVED[djxl]=1
RESERVED[dmc]=1
RESERVED[dmesg]=1
RESERVED[dnctl]=1
RESERVED[dns-sd]=1
RESERVED[docker]=1
RESERVED[dot2gxl]=1
RESERVED[dot]=1
RESERVED[dot_clean]=1
RESERVED[dotenv]=1
RESERVED[drone]=1
RESERVED[drutil]=1
RESERVED[dscl]=1
RESERVED[dsconfigad]=1
RESERVED[dserr]=1
RESERVED[dsexport]=1
RESERVED[dsimport]=1
RESERVED[dsymutil]=1
RESERVED[dtrace]=1
RESERVED[dtruss]=1
RESERVED[du]=1
RESERVED[dwarfdump]=1
RESERVED[dwebp]=1
RESERVED[dyld_info]=1
RESERVED[dyld_usage]=1
RESERVED[echo]=1
RESERVED[ed]=1
RESERVED[edgepaint]=1
RESERVED[edquota]=1
RESERVED[egrep]=1
RESERVED[eksctl]=1
RESERVED[enc2xs5.30]=1
RESERVED[enc2xs5.34]=1
RESERVED[enc2xs]=1
RESERVED[encguess]=1
RESERVED[env]=1
RESERVED[envsubst]=1
RESERVED[envsubst]=1
RESERVED[envvars]=1
RESERVED[erb]=1
RESERVED[errinfo]=1
RESERVED[escp2topbm]=1
RESERVED[eslogger]=1
RESERVED[ex]=1
RESERVED[execsnoop]=1
RESERVED[expand]=1
RESERVED[expect]=1
RESERVED[expr]=1
RESERVED[exr2aces]=1
RESERVED[exrenvmap]=1
RESERVED[exrheader]=1
RESERVED[exrinfo]=1
RESERVED[exrstdattr]=1
RESERVED[extcheck]=1
RESERVED[eyapp5.30]=1
RESERVED[eyapp5.34]=1
RESERVED[eyapp]=1
RESERVED[eyuvtoppm]=1
RESERVED[factor]=1
RESERVED[false]=1
RESERVED[fc-cache]=1
RESERVED[fc-cat]=1
RESERVED[fc-list]=1
RESERVED[fc-match]=1
RESERVED[fc-pattern]=1
RESERVED[fc-query]=1
RESERVED[fc-scan]=1
RESERVED[fc]=1
RESERVED[fddist]=1
RESERVED[fdesetup]=1
RESERVED[fdisk]=1
RESERVED[fdp]=1
RESERVED[fg]=1
RESERVED[fgrep]=1
RESERVED[fido2-cred]=1
RESERVED[file]=1
RESERVED[find]=1
RESERVED[findrule]=1
RESERVED[finger]=1
RESERVED[fio-dedupe]=1
RESERVED[fio]=1
RESERVED[fitstopnm]=1
RESERVED[fixproc]=1
RESERVED[flex++]=1
RESERVED[flex]=1
RESERVED[fmt]=1
RESERVED[fold]=1
RESERVED[footprint]=1
RESERVED[fribidi]=1
RESERVED[fs_usage]=1
RESERVED[fsck]=1
RESERVED[fsck_apfs]=1
RESERVED[fsck_cs]=1
RESERVED[fsck_exfat]=1
RESERVED[fsck_hfs]=1
RESERVED[fsck_msdos]=1
RESERVED[fsck_udf]=1
RESERVED[fstopgm]=1
RESERVED[fstyp]=1
RESERVED[fstyp_hfs]=1
RESERVED[fstyp_ntfs]=1
RESERVED[fstyp_udf]=1
RESERVED[funzip]=1
RESERVED[fuser]=1
RESERVED[fwkdp]=1
RESERVED[fwkpfv]=1
RESERVED[g++]=1
RESERVED[g3topbm]=1
RESERVED[gb2sum]=1
RESERVED[gbase32]=1
RESERVED[gbase64]=1
RESERVED[gbasename]=1
RESERVED[gbasenc]=1
RESERVED[gc]=1
RESERVED[gcat]=1
RESERVED[gcc]=1
RESERVED[gchcon]=1
RESERVED[gchgrp]=1
RESERVED[gchmod]=1
RESERVED[gchown]=1
RESERVED[gchroot]=1
RESERVED[gcksum]=1
RESERVED[gcomm]=1
RESERVED[gcore]=1
RESERVED[gcov]=1
RESERVED[gcp]=1
RESERVED[gcsplit]=1
RESERVED[gcut]=1
RESERVED[gd2copypal]=1
RESERVED[gd2togif]=1
RESERVED[gd2topng]=1
RESERVED[gdate]=1
RESERVED[gdbm_dump]=1
RESERVED[gdbm_dump]=1
RESERVED[gdbm_load]=1
RESERVED[gdbm_load]=1
RESERVED[gdbmtool]=1
RESERVED[gdbmtool]=1
RESERVED[gdbus]=1
RESERVED[gdcmpgif]=1
RESERVED[gdd]=1
RESERVED[gdf]=1
RESERVED[gdir]=1
RESERVED[gdircolors]=1
RESERVED[gdirname]=1
RESERVED[gdtopng]=1
RESERVED[gdu]=1
RESERVED[gecho]=1
RESERVED[gegrep]=1
RESERVED[gem]=1
RESERVED[gemtopbm]=1
RESERVED[gemtopnm]=1
RESERVED[gencat]=1
RESERVED[genfio]=1
RESERVED[genson]=1
RESERVED[genstrings]=1
RESERVED[genv]=1
RESERVED[getconf]=1
RESERVED[getopt]=1
RESERVED[getopts]=1
RESERVED[gettext.sh]=1
RESERVED[gettext.sh]=1
RESERVED[gettext]=1
RESERVED[gettext]=1
RESERVED[gettextize]=1
RESERVED[gexpand]=1
RESERVED[gexpr]=1
RESERVED[gfactor]=1
RESERVED[gfalse]=1
RESERVED[gfgrep]=1
RESERVED[gfmt]=1
RESERVED[gfold]=1
RESERVED[ggrep]=1
RESERVED[ggroups]=1
RESERVED[gh]=1
RESERVED[ghead]=1
RESERVED[ghostid]=1
RESERVED[gid]=1
RESERVED[gif2rgb]=1
RESERVED[gif2webp]=1
RESERVED[gifbuild]=1
RESERVED[gifclrmp]=1
RESERVED[giffix]=1
RESERVED[giftext]=1
RESERVED[giftogd2]=1
RESERVED[giftool]=1
RESERVED[giftopnm]=1
RESERVED[ginstall]=1
RESERVED[gio]=1
RESERVED[git-shell]=1
RESERVED[git-shell]=1
RESERVED[git2]=1
RESERVED[git]=1
RESERVED[git]=1
RESERVED[gjoin]=1
RESERVED[gkill]=1
RESERVED[gktool]=1
RESERVED[glibtool]=1
RESERVED[glink]=1
RESERVED[gln]=1
RESERVED[glogname]=1
RESERVED[gls]=1
RESERVED[gm4]=1
RESERVED[gmake]=1
RESERVED[gmd5sum]=1
RESERVED[gmkdir]=1
RESERVED[gmkfifo]=1
RESERVED[gmknod]=1
RESERVED[gmktemp]=1
RESERVED[gml2gv]=1
RESERVED[gmv]=1
RESERVED[gnice]=1
RESERVED[gnl]=1
RESERVED[gnohup]=1
RESERVED[gnproc]=1
RESERVED[gnumake]=1
RESERVED[gnumfmt]=1
RESERVED[go]=1
RESERVED[god]=1
RESERVED[gofmt]=1
RESERVED[gouldtoppm]=1
RESERVED[gpaste]=1
RESERVED[gpathchk]=1
RESERVED[gperf]=1
RESERVED[gpg-error]=1
RESERVED[gpinky]=1
RESERVED[gpr]=1
RESERVED[gprintenv]=1
RESERVED[gprintf]=1
RESERVED[gpt]=1
RESERVED[gptx]=1
RESERVED[gpwd]=1
RESERVED[graphml2gv]=1
RESERVED[greadlink]=1
RESERVED[grealpath]=1
RESERVED[grep]=1
RESERVED[gresource]=1
RESERVED[grm]=1
RESERVED[grmdir]=1
RESERVED[groonga]=1
RESERVED[groups]=1
RESERVED[grpcurl]=1
RESERVED[gruncon]=1
RESERVED[gsed]=1
RESERVED[gseq]=1
RESERVED[gsettings]=1
RESERVED[gsha1sum]=1
RESERVED[gsha224sum]=1
RESERVED[gsha256sum]=1
RESERVED[gsha384sum]=1
RESERVED[gsha512sum]=1
RESERVED[gshred]=1
RESERVED[gshuf]=1
RESERVED[gsleep]=1
RESERVED[gsort]=1
RESERVED[gsplit]=1
RESERVED[gssd]=1
RESERVED[gstat]=1
RESERVED[gstdbuf]=1
RESERVED[gstty]=1
RESERVED[gsum]=1
RESERVED[gsync]=1
RESERVED[gtac]=1
RESERVED[gtail]=1
RESERVED[gtee]=1
RESERVED[gtest]=1
RESERVED[gtester]=1
RESERVED[gtimeout]=1
RESERVED[gtouch]=1
RESERVED[gtr]=1
RESERVED[gtrue]=1
RESERVED[gtruncate]=1
RESERVED[gts-config]=1
RESERVED[gts2dxf]=1
RESERVED[gts2oogl]=1
RESERVED[gts2stl]=1
RESERVED[gtscheck]=1
RESERVED[gtscompare]=1
RESERVED[gtsort]=1
RESERVED[gtty]=1
RESERVED[guname]=1
RESERVED[gunexpand]=1
RESERVED[guniq]=1
RESERVED[gunlink]=1
RESERVED[gunzip]=1
RESERVED[guptime]=1
RESERVED[gusers]=1
RESERVED[gv2gml]=1
RESERVED[gv2gxl]=1
RESERVED[gvcolor]=1
RESERVED[gvdir]=1
RESERVED[gvgen]=1
RESERVED[gvmap.sh]=1
RESERVED[gvmap]=1
RESERVED[gvpack]=1
RESERVED[gvpr]=1
RESERVED[gwc]=1
RESERVED[gwho]=1
RESERVED[gwhoami]=1
RESERVED[gxl2dot]=1
RESERVED[gxl2gv]=1
RESERVED[gyes]=1
RESERVED[gzcat]=1
RESERVED[gzexe]=1
RESERVED[gzip]=1
RESERVED[h2ph-5.30]=1
RESERVED[h2ph5.30]=1
RESERVED[h2ph5.34]=1
RESERVED[h2ph]=1
RESERVED[h2xs-5.30]=1
RESERVED[h2xs5.30]=1
RESERVED[h2xs5.34]=1
RESERVED[h2xs]=1
RESERVED[halt]=1
RESERVED[happrox]=1
RESERVED[hash]=1
RESERVED[hb-info]=1
RESERVED[hb-shape]=1
RESERVED[hb-subset]=1
RESERVED[hb-view]=1
RESERVED[hdid]=1
RESERVED[hdifftopam]=1
RESERVED[hdik]=1
RESERVED[hdiutil]=1
RESERVED[head]=1
RESERVED[heap]=1
RESERVED[hexdump]=1
RESERVED[hidutil]=1
RESERVED[hipstopgm]=1
RESERVED[hiutil]=1
RESERVED[host]=1
RESERVED[hostid]=1
RESERVED[hostinfo]=1
RESERVED[hostname]=1
RESERVED[hotspot.d]=1
RESERVED[hpcdtoppm]=1
RESERVED[htdbm]=1
RESERVED[htdigest]=1
RESERVED[htmltree]=1
RESERVED[htpasswd]=1
RESERVED[httpd]=1
RESERVED[httxt2dbm]=1
RESERVED[hub-tool]=1
RESERVED[ibtool]=1
RESERVED[icontopbm]=1
RESERVED[iconutil]=1
RESERVED[iconv]=1
RESERVED[iconv]=1
RESERVED[ictool]=1
RESERVED[id]=1
RESERVED[idle3.10]=1
RESERVED[idle3.11]=1
RESERVED[idle3.12]=1
RESERVED[idle3.9]=1
RESERVED[idle3]=1
RESERVED[idlj]=1
RESERVED[idn2]=1
RESERVED[ifconfig]=1
RESERVED[ifnames]=1
RESERVED[ilbmtoppm]=1
RESERVED[img2webp]=1
RESERVED[imgcmp]=1
RESERVED[imginfo]=1
RESERVED[imgtoppm]=1
RESERVED[imptrace]=1
RESERVED[indent]=1
RESERVED[infocmp]=1
RESERVED[infocmp]=1
RESERVED[infotocap]=1
RESERVED[infotocap]=1
RESERVED[infotopam]=1
RESERVED[install]=1
RESERVED[installer]=1
RESERVED[instmodsh]=1
RESERVED[iofile.d]=1
RESERVED[iofileb.d]=1
RESERVED[iopattern]=1
RESERVED[iopending]=1
RESERVED[ioreg]=1
RESERVED[iosnoop]=1
RESERVED[iostat]=1
RESERVED[iotop]=1
RESERVED[ip2cc5.30]=1
RESERVED[ip2cc5.34]=1
RESERVED[ip2cc]=1
RESERVED[ipconfig]=1
RESERVED[ipcount]=1
RESERVED[ipcrm]=1
RESERVED[ipcs]=1
RESERVED[ippfind]=1
RESERVED[ipptool]=1
RESERVED[iptab5.30]=1
RESERVED[iptab5.34]=1
RESERVED[iptab]=1
RESERVED[irb]=1
RESERVED[isort]=1
RESERVED[jamf]=1
RESERVED[jar]=1
RESERVED[jarsigner]=1
RESERVED[jasper]=1
RESERVED[java]=1
RESERVED[javac]=1
RESERVED[javadoc]=1
RESERVED[javah]=1
RESERVED[javap]=1
RESERVED[javaws]=1
RESERVED[jbigtopnm]=1
RESERVED[jcmd]=1
RESERVED[jconsole]=1
RESERVED[jcontrol]=1
RESERVED[jdb]=1
RESERVED[jdeps]=1
RESERVED[jenv]=1
RESERVED[jhat]=1
RESERVED[jhsdb]=1
RESERVED[jimage]=1
RESERVED[jinfo]=1
RESERVED[jiv]=1
RESERVED[jjs]=1
RESERVED[jlink]=1
RESERVED[jmap]=1
RESERVED[jmc]=1
RESERVED[jo]=1
RESERVED[jobs]=1
RESERVED[join]=1
RESERVED[jot]=1
RESERVED[jpackage]=1
RESERVED[jpegtopnm]=1
RESERVED[jpegtran]=1
RESERVED[jpgicc]=1
RESERVED[jps]=1
RESERVED[jq]=1
RESERVED[jrunscript]=1
RESERVED[jsadebugd]=1
RESERVED[jshell]=1
RESERVED[json_pp]=1
RESERVED[json_xs]=1
RESERVED[jsonschema]=1
RESERVED[jstack]=1
RESERVED[jstat]=1
RESERVED[jstatd]=1
RESERVED[jvisualvm]=1
RESERVED[jxlinfo]=1
RESERVED[kadmin]=1
RESERVED[kcc]=1
RESERVED[kcditto]=1
RESERVED[kdcsetup]=1
RESERVED[kdestroy]=1
RESERVED[kextcache]=1
RESERVED[kextfind]=1
RESERVED[kextlibs]=1
RESERVED[kextload]=1
RESERVED[kextstat]=1
RESERVED[kextunload]=1
RESERVED[kextutil]=1
RESERVED[keyring]=1
RESERVED[keytool]=1
RESERVED[kgetcred]=1
RESERVED[kill.d]=1
RESERVED[kill]=1
RESERVED[killall]=1
RESERVED[kinit]=1
RESERVED[klist]=1
RESERVED[kmutil]=1
RESERVED[kpasswd]=1
RESERVED[ksh]=1
RESERVED[kswitch]=1
RESERVED[ktrace]=1
RESERVED[ktutil]=1
RESERVED[kubectl]=1
RESERVED[lam]=1
RESERVED[last]=1
RESERVED[lastcomm]=1
RESERVED[lastwords]=1
RESERVED[latency]=1
RESERVED[launchctl]=1
RESERVED[launchd]=1
RESERVED[layerutil]=1
RESERVED[ld]=1
RESERVED[ldapadd]=1
RESERVED[ldapdelete]=1
RESERVED[ldapexop]=1
RESERVED[ldapmodify]=1
RESERVED[ldapmodrdn]=1
RESERVED[ldappasswd]=1
RESERVED[ldapsearch]=1
RESERVED[ldapurl]=1
RESERVED[ldapwhoami]=1
RESERVED[leaftoppm]=1
RESERVED[leaks]=1
RESERVED[leave]=1
RESERVED[less]=1
RESERVED[lessecho]=1
RESERVED[lex]=1
RESERVED[libnetcfg]=1
RESERVED[libtool]=1
RESERVED[link]=1
RESERVED[linkicc]=1
RESERVED[lipo]=1
RESERVED[lispmtopgm]=1
RESERVED[lldb]=1
RESERVED[llvm-g++]=1
RESERVED[llvm-gcc]=1
RESERVED[ln]=1
RESERVED[loads.d]=1
RESERVED[locale]=1
RESERVED[localedef]=1
RESERVED[locate]=1
RESERVED[lockstat]=1
RESERVED[log]=1
RESERVED[logger]=1
RESERVED[login]=1
RESERVED[logname]=1
RESERVED[logresolve]=1
RESERVED[look]=1
RESERVED[lorder]=1
RESERVED[lp]=1
RESERVED[lpadmin]=1
RESERVED[lpc]=1
RESERVED[lpinfo]=1
RESERVED[lpmove]=1
RESERVED[lpoptions]=1
RESERVED[lpq]=1
RESERVED[lpr]=1
RESERVED[lprm]=1
RESERVED[lpstat]=1
RESERVED[ls]=1
RESERVED[lsappinfo]=1
RESERVED[lsbom]=1
RESERVED[lskq]=1
RESERVED[lsm]=1
RESERVED[lsmp]=1
RESERVED[lsof]=1
RESERVED[lsvfs]=1
RESERVED[lwp-dump]=1
RESERVED[lwp-mirror]=1
RESERVED[lz4]=1
RESERVED[lz4c]=1
RESERVED[lz4cat]=1
RESERVED[lzcat]=1
RESERVED[lzcmp]=1
RESERVED[lzdiff]=1
RESERVED[lzegrep]=1
RESERVED[lzfgrep]=1
RESERVED[lzgrep]=1
RESERVED[lzless]=1
RESERVED[lzma]=1
RESERVED[lzmadec]=1
RESERVED[lzmainfo]=1
RESERVED[lzmore]=1
RESERVED[m4]=1
RESERVED[macbinary]=1
RESERVED[macerror]=1
RESERVED[machine]=1
RESERVED[macptopbm]=1
RESERVED[mail]=1
RESERVED[mailq]=1
RESERVED[mailx]=1
RESERVED[make]=1
RESERVED[man]=1
RESERVED[mandoc]=1
RESERVED[manpath]=1
RESERVED[manweb]=1
RESERVED[mariadb]=1
RESERVED[mariadbd]=1
RESERVED[mate]=1
RESERVED[mbstream]=1
RESERVED[mcxquery]=1
RESERVED[mcxrefresh]=1
RESERVED[md5]=1
RESERVED[md5sum]=1
RESERVED[mdatopbm]=1
RESERVED[mddiagnose]=1
RESERVED[mdfind]=1
RESERVED[mdimport]=1
RESERVED[mdls]=1
RESERVED[mdutil]=1
RESERVED[mecab]=1
RESERVED[mesg]=1
RESERVED[mg]=1
RESERVED[mgrtopbm]=1
RESERVED[mib2c]=1
RESERVED[mibcopy.py]=1
RESERVED[mibdump.py]=1
RESERVED[mig]=1
RESERVED[mkbom]=1
RESERVED[mkdir]=1
RESERVED[mkfifo]=1
RESERVED[mkfile]=1
RESERVED[mklocale]=1
RESERVED[mknod]=1
RESERVED[mkpassdb]=1
RESERVED[mktemp]=1
RESERVED[mm2gv]=1
RESERVED[mnthome]=1
RESERVED[mol]=1
RESERVED[molecule]=1
RESERVED[more]=1
RESERVED[mount]=1
RESERVED[mount_9p]=1
RESERVED[mount_acfs]=1
RESERVED[mount_afp]=1
RESERVED[mount_apfs]=1
RESERVED[mount_ftp]=1
RESERVED[mount_hfs]=1
RESERVED[mount_lifs]=1
RESERVED[mount_nfs]=1
RESERVED[mount_udf]=1
RESERVED[mp2bug]=1
RESERVED[mpioutil]=1
RESERVED[mq]=1
RESERVED[mrftopbm]=1
RESERVED[msgattrib]=1
RESERVED[msgcat]=1
RESERVED[msgcmp]=1
RESERVED[msgcomm]=1
RESERVED[msgconv]=1
RESERVED[msgen]=1
RESERVED[msgexec]=1
RESERVED[msgfilter]=1
RESERVED[msgfmt]=1
RESERVED[msggrep]=1
RESERVED[msginit]=1
RESERVED[msgmerge]=1
RESERVED[msgunfmt]=1
RESERVED[msguniq]=1
RESERVED[msql2mysql]=1
RESERVED[mtree]=1
RESERVED[mtvtoppm]=1
RESERVED[mv]=1
RESERVED[myisamchk]=1
RESERVED[myisamlog]=1
RESERVED[myisampack]=1
RESERVED[mysql]=1
RESERVED[mysql_ldb]=1
RESERVED[mysqladmin]=1
RESERVED[mysqlcheck]=1
RESERVED[mysqld]=1
RESERVED[mysqldump]=1
RESERVED[mysqlshow]=1
RESERVED[mysqlslap]=1
RESERVED[mysqltest]=1
RESERVED[mytop]=1
RESERVED[nano]=1
RESERVED[nbdst]=1
RESERVED[nc]=1
RESERVED[ncal]=1
RESERVED[ncctl]=1
RESERVED[ncdestroy]=1
RESERVED[ncinit]=1
RESERVED[nclist]=1
RESERVED[ndp]=1
RESERVED[neato]=1
RESERVED[neotoppm]=1
RESERVED[net-server]=1
RESERVED[netbiosd]=1
RESERVED[netstat]=1
RESERVED[nettop]=1
RESERVED[newaliases]=1
RESERVED[newfs_apfs]=1
RESERVED[newfs_hfs]=1
RESERVED[newfs_udf]=1
RESERVED[newgrp]=1
RESERVED[newproc.d]=1
RESERVED[newsyslog]=1
RESERVED[nfs4mapid]=1
RESERVED[nfsd]=1
RESERVED[nfsiod]=1
RESERVED[nfsstat]=1
RESERVED[ngettext]=1
RESERVED[ngettext]=1
RESERVED[nice]=1
RESERVED[nl]=1
RESERVED[nlcontrol]=1
RESERVED[nm]=1
RESERVED[nmedit]=1
RESERVED[node]=1
RESERVED[nohup]=1
RESERVED[nologin]=1
RESERVED[nop]=1
RESERVED[notifyd]=1
RESERVED[notifyutil]=1
RESERVED[npm]=1
RESERVED[nproc]=1
RESERVED[npx]=1
RESERVED[nscurl]=1
RESERVED[nslookup]=1
RESERVED[nsupdate]=1
RESERVED[numfmt]=1
RESERVED[nvram]=1
RESERVED[objdump]=1
RESERVED[ocspcheck]=1
RESERVED[ocspd]=1
RESERVED[od]=1
RESERVED[odutil]=1
RESERVED[open]=1
RESERVED[opendiff]=1
RESERVED[opensnoop]=1
RESERVED[openssl]=1
RESERVED[openssl]=1
RESERVED[orbd]=1
RESERVED[osacompile]=1
RESERVED[osage]=1
RESERVED[osalang]=1
RESERVED[osascript]=1
RESERVED[otctl]=1
RESERVED[otool]=1
RESERVED[pack200]=1
RESERVED[pagesize]=1
RESERVED[pagestuff]=1
RESERVED[palmtopnm]=1
RESERVED[pamaltsat]=1
RESERVED[pamarith]=1
RESERVED[pambayer]=1
RESERVED[pamcat]=1
RESERVED[pamchannel]=1
RESERVED[pamcomp]=1
RESERVED[pamcrater]=1
RESERVED[pamcut]=1
RESERVED[pamdepth]=1
RESERVED[pamdice]=1
RESERVED[pamedge]=1
RESERVED[pamendian]=1
RESERVED[pamenlarge]=1
RESERVED[pamexec]=1
RESERVED[pamfile]=1
RESERVED[pamfind]=1
RESERVED[pamfix]=1
RESERVED[pamflip]=1
RESERVED[pamfunc]=1
RESERVED[pamgauss]=1
RESERVED[pamhue]=1
RESERVED[pamlevels]=1
RESERVED[pamlookup]=1
RESERVED[pamoil]=1
RESERVED[pampick]=1
RESERVED[pampop9]=1
RESERVED[pamrecolor]=1
RESERVED[pamrestack]=1
RESERVED[pamrubber]=1
RESERVED[pamscale]=1
RESERVED[pamseq]=1
RESERVED[pamshuffle]=1
RESERVED[pamslice]=1
RESERVED[pamsplit]=1
RESERVED[pamstack]=1
RESERVED[pamstretch]=1
RESERVED[pamsumm]=1
RESERVED[pamsummcol]=1
RESERVED[pamtable]=1
RESERVED[pamtilt]=1
RESERVED[pamtoavs]=1
RESERVED[pamtofits]=1
RESERVED[pamtogif]=1
RESERVED[pamtohdiff]=1
RESERVED[pamtopam]=1
RESERVED[pamtopfm]=1
RESERVED[pamtopng]=1
RESERVED[pamtopnm]=1
RESERVED[pamtoqoi]=1
RESERVED[pamtosrf]=1
RESERVED[pamtosvg]=1
RESERVED[pamtotga]=1
RESERVED[pamtotiff]=1
RESERVED[pamtouil]=1
RESERVED[pamtris]=1
RESERVED[pamundice]=1
RESERVED[pamwipeout]=1
RESERVED[pango-list]=1
RESERVED[pango-view]=1
RESERVED[par.pl]=1
RESERVED[par5.30.pl]=1
RESERVED[par5.34.pl]=1
RESERVED[parl5.30]=1
RESERVED[parl5.34]=1
RESERVED[parl]=1
RESERVED[parldyn]=1
RESERVED[passwd]=1
RESERVED[paste]=1
RESERVED[patch]=1
RESERVED[patch]=1
RESERVED[patchwork]=1
RESERVED[pathchk]=1
RESERVED[pax]=1
RESERVED[pbcopy]=1
RESERVED[pbmclean]=1
RESERVED[pbmlife]=1
RESERVED[pbmmake]=1
RESERVED[pbmmask]=1
RESERVED[pbmnoise]=1
RESERVED[pbmpage]=1
RESERVED[pbmpscale]=1
RESERVED[pbmreduce]=1
RESERVED[pbmtext]=1
RESERVED[pbmtextps]=1
RESERVED[pbmto10x]=1
RESERVED[pbmto4425]=1
RESERVED[pbmtoascii]=1
RESERVED[pbmtoatk]=1
RESERVED[pbmtobbnbg]=1
RESERVED[pbmtocis]=1
RESERVED[pbmtocmuwm]=1
RESERVED[pbmtoepsi]=1
RESERVED[pbmtoepson]=1
RESERVED[pbmtoescp2]=1
RESERVED[pbmtog3]=1
RESERVED[pbmtogem]=1
RESERVED[pbmtogo]=1
RESERVED[pbmtoicon]=1
RESERVED[pbmtolj]=1
RESERVED[pbmtoln03]=1
RESERVED[pbmtolps]=1
RESERVED[pbmtomacp]=1
RESERVED[pbmtomda]=1
RESERVED[pbmtomgr]=1
RESERVED[pbmtomrf]=1
RESERVED[pbmtonokia]=1
RESERVED[pbmtopgm]=1
RESERVED[pbmtopi3]=1
RESERVED[pbmtopk]=1
RESERVED[pbmtoplot]=1
RESERVED[pbmtoppa]=1
RESERVED[pbmtopsg3]=1
RESERVED[pbmtoptx]=1
RESERVED[pbmtowbmp]=1
RESERVED[pbmtox10bm]=1
RESERVED[pbmtoxbm]=1
RESERVED[pbmtoybm]=1
RESERVED[pbmtozinc]=1
RESERVED[pbmupc]=1
RESERVED[pbpaste]=1
RESERVED[pc1toppm]=1
RESERVED[pcdindex]=1
RESERVED[pcdovtoppm]=1
RESERVED[pcre2grep]=1
RESERVED[pcre2test]=1
RESERVED[pcregrep]=1
RESERVED[pcretest]=1
RESERVED[pcsctest]=1
RESERVED[pcxtoppm]=1
RESERVED[pdisk]=1
RESERVED[periodic]=1
RESERVED[perl5.30.3]=1
RESERVED[perl5.30]=1
RESERVED[perl5.30]=1
RESERVED[perl5.34]=1
RESERVED[perl]=1
RESERVED[perlbug]=1
RESERVED[perldoc]=1
RESERVED[perlivp]=1
RESERVED[perlthanks]=1
RESERVED[perror]=1
RESERVED[pfctl]=1
RESERVED[pfmtopam]=1
RESERVED[pgmabel]=1
RESERVED[pgmbentley]=1
RESERVED[pgmcrater]=1
RESERVED[pgmedge]=1
RESERVED[pgmenhance]=1
RESERVED[pgmhist]=1
RESERVED[pgmkernel]=1
RESERVED[pgmmake]=1
RESERVED[pgmmedian]=1
RESERVED[pgmnoise]=1
RESERVED[pgmnorm]=1
RESERVED[pgmoil]=1
RESERVED[pgmramp]=1
RESERVED[pgmslice]=1
RESERVED[pgmtexture]=1
RESERVED[pgmtofs]=1
RESERVED[pgmtolispm]=1
RESERVED[pgmtopbm]=1
RESERVED[pgmtopgm]=1
RESERVED[pgmtoppm]=1
RESERVED[pgmtosbig]=1
RESERVED[pgmtost4]=1
RESERVED[pgrep]=1
RESERVED[pi1toppm]=1
RESERVED[pi3topbm]=1
RESERVED[pico]=1
RESERVED[piconv5.30]=1
RESERVED[piconv5.34]=1
RESERVED[piconv]=1
RESERVED[picttoppm]=1
RESERVED[ping6]=1
RESERVED[ping]=1
RESERVED[pinky]=1
RESERVED[pip-sync]=1
RESERVED[pip3.10]=1
RESERVED[pip3.11]=1
RESERVED[pip3.12]=1
RESERVED[pip3.9]=1
RESERVED[pip3]=1
RESERVED[pip3]=1
RESERVED[pipenv]=1
RESERVED[pjtoppm]=1
RESERVED[pkg-config]=1
RESERVED[pkgbuild]=1
RESERVED[pkginfo]=1
RESERVED[pkgutil]=1
RESERVED[pkill]=1
RESERVED[pktopbm]=1
RESERVED[pl2pm-5.30]=1
RESERVED[pl2pm5.30]=1
RESERVED[pl2pm5.34]=1
RESERVED[pl2pm]=1
RESERVED[pl]=1
RESERVED[plockstat]=1
RESERVED[pluginkit]=1
RESERVED[plutil]=1
RESERVED[pmset]=1
RESERVED[pngfix]=1
RESERVED[pngtogd2]=1
RESERVED[pngtogd]=1
RESERVED[pngtopam]=1
RESERVED[pngtopnm]=1
RESERVED[pnmalias]=1
RESERVED[pnmarith]=1
RESERVED[pnmcat]=1
RESERVED[pnmcomp]=1
RESERVED[pnmconvol]=1
RESERVED[pnmcrop]=1
RESERVED[pnmcut]=1
RESERVED[pnmdepth]=1
RESERVED[pnmenlarge]=1
RESERVED[pnmfile]=1
RESERVED[pnmflip]=1
RESERVED[pnmgamma]=1
RESERVED[pnmhisteq]=1
RESERVED[pnmhistmap]=1
RESERVED[pnmindex]=1
RESERVED[pnminterp]=1
RESERVED[pnminvert]=1
RESERVED[pnmmargin]=1
RESERVED[pnmmontage]=1
RESERVED[pnmnlfilt]=1
RESERVED[pnmnoraw]=1
RESERVED[pnmnorm]=1
RESERVED[pnmpad]=1
RESERVED[pnmpaste]=1
RESERVED[pnmpsnr]=1
RESERVED[pnmquant]=1
RESERVED[pnmremap]=1
RESERVED[pnmrotate]=1
RESERVED[pnmscale]=1
RESERVED[pnmshear]=1
RESERVED[pnmsmooth]=1
RESERVED[pnmsplit]=1
RESERVED[pnmstitch]=1
RESERVED[pnmtile]=1
RESERVED[pnmtoddif]=1
RESERVED[pnmtofits]=1
RESERVED[pnmtojbig]=1
RESERVED[pnmtojpeg]=1
RESERVED[pnmtopalm]=1
RESERVED[pnmtopclxl]=1
RESERVED[pnmtopng]=1
RESERVED[pnmtopnm]=1
RESERVED[pnmtops]=1
RESERVED[pnmtorast]=1
RESERVED[pnmtorle]=1
RESERVED[pnmtosgi]=1
RESERVED[pnmtosir]=1
RESERVED[pnmtotiff]=1
RESERVED[pnmtoxwd]=1
RESERVED[pod2html]=1
RESERVED[pod2man]=1
RESERVED[pod2readme]=1
RESERVED[pod2text]=1
RESERVED[pod2usage]=1
RESERVED[podchecker]=1
RESERVED[podselect]=1
RESERVED[policytool]=1
RESERVED[port-tclsh]=1
RESERVED[port]=1
RESERVED[portf]=1
RESERVED[portindex]=1
RESERVED[portmirror]=1
RESERVED[postalias]=1
RESERVED[postcat]=1
RESERVED[postconf]=1
RESERVED[postdrop]=1
RESERVED[postfix]=1
RESERVED[postkick]=1
RESERVED[postlock]=1
RESERVED[postlog]=1
RESERVED[postmap]=1
RESERVED[postmulti]=1
RESERVED[postqueue]=1
RESERVED[postsuper]=1
RESERVED[pp5.30]=1
RESERVED[pp5.34]=1
RESERVED[pp]=1
RESERVED[ppdc]=1
RESERVED[ppdhtml]=1
RESERVED[ppdi]=1
RESERVED[ppdmerge]=1
RESERVED[ppdpo]=1
RESERVED[ppm3d]=1
RESERVED[ppmchange]=1
RESERVED[ppmcie]=1
RESERVED[ppmcolors]=1
RESERVED[ppmdcfont]=1
RESERVED[ppmdim]=1
RESERVED[ppmdist]=1
RESERVED[ppmdither]=1
RESERVED[ppmdmkfont]=1
RESERVED[ppmdraw]=1
RESERVED[ppmfade]=1
RESERVED[ppmflash]=1
RESERVED[ppmforge]=1
RESERVED[ppmglobe]=1
RESERVED[ppmhist]=1
RESERVED[ppmlabel]=1
RESERVED[ppmmake]=1
RESERVED[ppmmix]=1
RESERVED[ppmnorm]=1
RESERVED[ppmntsc]=1
RESERVED[ppmpat]=1
RESERVED[ppmquant]=1
RESERVED[ppmrainbow]=1
RESERVED[ppmrelief]=1
RESERVED[ppmrough]=1
RESERVED[ppmshadow]=1
RESERVED[ppmshift]=1
RESERVED[ppmspread]=1
RESERVED[ppmtoacad]=1
RESERVED[ppmtoascii]=1
RESERVED[ppmtobmp]=1
RESERVED[ppmtoeyuv]=1
RESERVED[ppmtogif]=1
RESERVED[ppmtoicr]=1
RESERVED[ppmtoilbm]=1
RESERVED[ppmtojpeg]=1
RESERVED[ppmtoleaf]=1
RESERVED[ppmtolj]=1
RESERVED[ppmtomap]=1
RESERVED[ppmtomitsu]=1
RESERVED[ppmtompeg]=1
RESERVED[ppmtoneo]=1
RESERVED[ppmtopcx]=1
RESERVED[ppmtopgm]=1
RESERVED[ppmtopi1]=1
RESERVED[ppmtopict]=1
RESERVED[ppmtopj]=1
RESERVED[ppmtopjxl]=1
RESERVED[ppmtoppm]=1
RESERVED[ppmtopuzz]=1
RESERVED[ppmtorgb3]=1
RESERVED[ppmtosixel]=1
RESERVED[ppmtospu]=1
RESERVED[ppmtoterm]=1
RESERVED[ppmtotga]=1
RESERVED[ppmtouil]=1
RESERVED[ppmtoxpm]=1
RESERVED[ppmtoyuv]=1
RESERVED[ppmtv]=1
RESERVED[ppmwheel]=1
RESERVED[pppd]=1
RESERVED[pr]=1
RESERVED[prance]=1
RESERVED[praudit]=1
RESERVED[priclass.d]=1
RESERVED[pridist.d]=1
RESERVED[printenv]=1
RESERVED[printf]=1
RESERVED[profiles]=1
RESERVED[protoc]=1
RESERVED[prove-5.30]=1
RESERVED[prove5.30]=1
RESERVED[prove5.34]=1
RESERVED[prove]=1
RESERVED[prune]=1
RESERVED[ps]=1
RESERVED[pscale]=1
RESERVED[psicc]=1
RESERVED[psidtopgm]=1
RESERVED[psm]=1
RESERVED[pstopnm]=1
RESERVED[ptar-5.30]=1
RESERVED[ptar5.30]=1
RESERVED[ptar5.34]=1
RESERVED[ptar]=1
RESERVED[ptardiff]=1
RESERVED[ptargrep]=1
RESERVED[ptx]=1
RESERVED[purge]=1
RESERVED[pwd]=1
RESERVED[pwd_mkdb]=1
RESERVED[pwpolicy]=1
RESERVED[py.test]=1
RESERVED[pydoc3.10]=1
RESERVED[pydoc3.11]=1
RESERVED[pydoc3.12]=1
RESERVED[pydoc3.9]=1
RESERVED[pydoc3]=1
RESERVED[pyenv]=1
RESERVED[pygmentize]=1
RESERVED[pysemver]=1
RESERVED[pytest]=1
RESERVED[python3.10]=1
RESERVED[python3.11]=1
RESERVED[python3.12]=1
RESERVED[python3.9]=1
RESERVED[python3]=1
RESERVED[python3]=1
RESERVED[pzstd]=1
RESERVED[qlmanage]=1
RESERVED[qoitopam]=1
RESERVED[qprofdiff]=1
RESERVED[qrttoppm]=1
RESERVED[quota]=1
RESERVED[quotacheck]=1
RESERVED[quotaoff]=1
RESERVED[quotaon]=1
RESERVED[racoon]=1
RESERVED[rails]=1
RESERVED[rake]=1
RESERVED[ranlib]=1
RESERVED[rarpd]=1
RESERVED[rasttopnm]=1
RESERVED[rawtopgm]=1
RESERVED[rawtoppm]=1
RESERVED[rcmysql]=1
RESERVED[rdjpgcom]=1
RESERVED[rdoc]=1
RESERVED[read]=1
RESERVED[readlink]=1
RESERVED[realpath]=1
RESERVED[realpath]=1
RESERVED[reboot]=1
RESERVED[renice]=1
RESERVED[replace]=1
RESERVED[repquota]=1
RESERVED[reset]=1
RESERVED[reset]=1
RESERVED[resolveip]=1
RESERVED[rev]=1
RESERVED[revolver]=1
RESERVED[rgb3toppm]=1
RESERVED[ri]=1
RESERVED[rlatopam]=1
RESERVED[rletopnm]=1
RESERVED[rm]=1
RESERVED[rmdir]=1
RESERVED[rmic]=1
RESERVED[rmid]=1
RESERVED[rotatelogs]=1
RESERVED[route]=1
RESERVED[rpc.lockd]=1
RESERVED[rpc.statd]=1
RESERVED[rpcbind]=1
RESERVED[rpcgen]=1
RESERVED[rpcinfo]=1
RESERVED[rs]=1
RESERVED[rst2man.py]=1
RESERVED[rst2odt.py]=1
RESERVED[rst2s5.py]=1
RESERVED[rst2xml.py]=1
RESERVED[rsync]=1
RESERVED[rtadvd]=1
RESERVED[rtmpdump]=1
RESERVED[rtmpgw]=1
RESERVED[rtmpsrv]=1
RESERVED[rtmpsuck]=1
RESERVED[ruby]=1
RESERVED[runcon]=1
RESERVED[rust-gdb]=1
RESERVED[rust-lldb]=1
RESERVED[rustc]=1
RESERVED[rustdoc]=1
RESERVED[rview]=1
RESERVED[rvim]=1
RESERVED[rwbypid.d]=1
RESERVED[rwbytype.d]=1
RESERVED[rwsnoop]=1
RESERVED[sa]=1
RESERVED[sample]=1
RESERVED[sampleproc]=1
RESERVED[say]=1
RESERVED[sbigtopgm]=1
RESERVED[sc_auth]=1
RESERVED[sc_usage]=1
RESERVED[scalar]=1
RESERVED[sccmap]=1
RESERVED[schemagen]=1
RESERVED[scp]=1
RESERVED[screen]=1
RESERVED[script]=1
RESERVED[scselect]=1
RESERVED[scutil]=1
RESERVED[sdef]=1
RESERVED[sdiff]=1
RESERVED[sdp]=1
RESERVED[sdx]=1
RESERVED[security]=1
RESERVED[securityd]=1
RESERVED[sed]=1
RESERVED[seeksize.d]=1
RESERVED[segedit]=1
RESERVED[sendmail]=1
RESERVED[seq]=1
RESERVED[serialver]=1
RESERVED[serverinfo]=1
RESERVED[servertool]=1
RESERVED[setkey]=1
RESERVED[setquota]=1
RESERVED[setregion]=1
RESERVED[setuids.d]=1
RESERVED[sfdp]=1
RESERVED[sfltool]=1
RESERVED[sft]=1
RESERVED[sftp]=1
RESERVED[sgitopnm]=1
RESERVED[sh]=1
RESERVED[sha1sum]=1
RESERVED[sha224sum]=1
RESERVED[sha256sum]=1
RESERVED[sha384sum]=1
RESERVED[sha512sum]=1
RESERVED[shar]=1
RESERVED[sharing]=1
RESERVED[shasum5.30]=1
RESERVED[shasum5.34]=1
RESERVED[shasum]=1
RESERVED[shazam]=1
RESERVED[shellcheck]=1
RESERVED[shlock]=1
RESERVED[shortcuts]=1
RESERVED[showmount]=1
RESERVED[shred]=1
RESERVED[shuf]=1
RESERVED[shutdown]=1
RESERVED[sigdist.d]=1
RESERVED[sips]=1
RESERVED[sirtopnm]=1
RESERVED[size]=1
RESERVED[skywalkctl]=1
RESERVED[slapacl]=1
RESERVED[slapadd]=1
RESERVED[slapauth]=1
RESERVED[slapcat]=1
RESERVED[slapconfig]=1
RESERVED[slapdn]=1
RESERVED[slapindex]=1
RESERVED[slappasswd]=1
RESERVED[slapschema]=1
RESERVED[slaptest]=1
RESERVED[sldtoppm]=1
RESERVED[sleep]=1
RESERVED[slogin]=1
RESERVED[slugify]=1
RESERVED[smbd]=1
RESERVED[smbutil]=1
RESERVED[smimesign]=1
RESERVED[sndiskmove]=1
RESERVED[snfsdefrag]=1
RESERVED[snmpconf]=1
RESERVED[snmpd]=1
RESERVED[snmpdelta]=1
RESERVED[snmpdf]=1
RESERVED[snmpget]=1
RESERVED[snmpinform]=1
RESERVED[snmpset]=1
RESERVED[snmpstatus]=1
RESERVED[snmptable]=1
RESERVED[snmptest]=1
RESERVED[snmptrap]=1
RESERVED[snmptrapd]=1
RESERVED[snmpusm]=1
RESERVED[snmpvacm]=1
RESERVED[snmpwalk]=1
RESERVED[snquota]=1
RESERVED[sntp]=1
RESERVED[sntpd]=1
RESERVED[sort]=1
RESERVED[spctl]=1
RESERVED[spctoppm]=1
RESERVED[spfd5.30]=1
RESERVED[spfd5.34]=1
RESERVED[spfd]=1
RESERVED[spfquery]=1
RESERVED[spindump]=1
RESERVED[splain5.30]=1
RESERVED[splain5.34]=1
RESERVED[splain]=1
RESERVED[split]=1
RESERVED[spottopgm]=1
RESERVED[spray]=1
RESERVED[sputoppm]=1
RESERVED[sqlite3]=1
RESERVED[srftopam]=1
RESERVED[ssh-add]=1
RESERVED[ssh-agent]=1
RESERVED[ssh-keygen]=1
RESERVED[ssh]=1
RESERVED[sshd]=1
RESERVED[sso_util]=1
RESERVED[sst_dump]=1
RESERVED[st4topgm]=1
RESERVED[stapler]=1
RESERVED[stat]=1
RESERVED[stdbuf]=1
RESERVED[stl2gts]=1
RESERVED[streamzip]=1
RESERVED[stringdups]=1
RESERVED[strings]=1
RESERVED[strip]=1
RESERVED[stty]=1
RESERVED[su]=1
RESERVED[sudo]=1
RESERVED[sum]=1
RESERVED[svgtopam]=1
RESERVED[sw_vers]=1
RESERVED[swcutil]=1
RESERVED[swift]=1
RESERVED[swiftc]=1
RESERVED[symbols]=1
RESERVED[sync]=1
RESERVED[sysctl]=1
RESERVED[syslog]=1
RESERVED[syslogd]=1
RESERVED[tab2space]=1
RESERVED[tabs]=1
RESERVED[tabs]=1
RESERVED[tabulate]=1
RESERVED[tac]=1
RESERVED[tail]=1
RESERVED[tailspin]=1
RESERVED[talk]=1
RESERVED[tar]=1
RESERVED[taskinfo]=1
RESERVED[taskpolicy]=1
RESERVED[tccutil]=1
RESERVED[tclsh8.5]=1
RESERVED[tclsh]=1
RESERVED[tcpdump]=1
RESERVED[tcsh]=1
RESERVED[tee]=1
RESERVED[telnet]=1
RESERVED[terraform]=1
RESERVED[test-yaml]=1
RESERVED[test]=1
RESERVED[textutil]=1
RESERVED[tfenv]=1
RESERVED[tftp]=1
RESERVED[tgatoppm]=1
RESERVED[thermal]=1
RESERVED[tic]=1
RESERVED[tic]=1
RESERVED[tidy]=1
RESERVED[tiff2icns]=1
RESERVED[tiffcp]=1
RESERVED[tiffdump]=1
RESERVED[tiffinfo]=1
RESERVED[tiffset]=1
RESERVED[tiffsplit]=1
RESERVED[tifftopnm]=1
RESERVED[tiffutil]=1
RESERVED[tificc]=1
RESERVED[time]=1
RESERVED[timeout]=1
RESERVED[timerfires]=1
RESERVED[tjbench]=1
RESERVED[tkcon]=1
RESERVED[tkmib]=1
RESERVED[tkpp5.30]=1
RESERVED[tkpp5.34]=1
RESERVED[tkpp]=1
RESERVED[tmdiagnose]=1
RESERVED[tmutil]=1
RESERVED[tnameserv]=1
RESERVED[toe]=1
RESERVED[toe]=1
RESERVED[top]=1
RESERVED[tops]=1
RESERVED[topsyscall]=1
RESERVED[topsysproc]=1
RESERVED[touch]=1
RESERVED[tox]=1
RESERVED[tput]=1
RESERVED[tput]=1
RESERVED[tqdm]=1
RESERVED[tr]=1
RESERVED[trace]=1
RESERVED[traceroute]=1
RESERVED[transform]=1
RESERVED[transicc]=1
RESERVED[tred]=1
RESERVED[treereg]=1
RESERVED[trimforce]=1
RESERVED[true]=1
RESERVED[truncate]=1
RESERVED[truncate]=1
RESERVED[tset]=1
RESERVED[tset]=1
RESERVED[tsort]=1
RESERVED[tty]=1
RESERVED[twine]=1
RESERVED[twopi]=1
RESERVED[type]=1
RESERVED[ul]=1
RESERVED[ulimit]=1
RESERVED[umask]=1
RESERVED[umount]=1
RESERVED[umtool]=1
RESERVED[unalias]=1
RESERVED[uname]=1
RESERVED[uncompress]=1
RESERVED[unexpand]=1
RESERVED[unflatten]=1
RESERVED[unifdef]=1
RESERVED[unifdefall]=1
RESERVED[uniq]=1
RESERVED[units]=1
RESERVED[unlink]=1
RESERVED[unlz4]=1
RESERVED[unlzma]=1
RESERVED[unpack200]=1
RESERVED[unvis]=1
RESERVED[unxz]=1
RESERVED[unzip]=1
RESERVED[unzipsfx]=1
RESERVED[unzstd]=1
RESERVED[uptime]=1
RESERVED[usernoted]=1
RESERVED[users]=1
RESERVED[uttype]=1
RESERVED[uuchk]=1
RESERVED[uucico]=1
RESERVED[uuconv]=1
RESERVED[uucp]=1
RESERVED[uudecode]=1
RESERVED[uuencode]=1
RESERVED[uuidgen]=1
RESERVED[uulog]=1
RESERVED[uuname]=1
RESERVED[uupick]=1
RESERVED[uusched]=1
RESERVED[uustat]=1
RESERVED[uuto]=1
RESERVED[uux]=1
RESERVED[uuxqt]=1
RESERVED[vault]=1
RESERVED[vi]=1
RESERVED[view]=1
RESERVED[vifs]=1
RESERVED[vim]=1
RESERVED[vimdiff]=1
RESERVED[vimtutor]=1
RESERVED[vipw]=1
RESERVED[virtualenv]=1
RESERVED[vis]=1
RESERVED[visudo]=1
RESERVED[vm_stat]=1
RESERVED[vmaf]=1
RESERVED[vmmap]=1
RESERVED[vpnd]=1
RESERVED[vpnkit]=1
RESERVED[vsdbutil]=1
RESERVED[vtool]=1
RESERVED[vwebp]=1
RESERVED[w]=1
RESERVED[wait4path]=1
RESERVED[wait]=1
RESERVED[wall]=1
RESERVED[watch]=1
RESERVED[wbmptopbm]=1
RESERVED[wc]=1
RESERVED[wdk]=1
RESERVED[wdutil]=1
RESERVED[webpinfo]=1
RESERVED[webpmux]=1
RESERVED[webpng]=1
RESERVED[wfsctl]=1
RESERVED[wget]=1
RESERVED[what]=1
RESERVED[whatis]=1
RESERVED[wheel3.10]=1
RESERVED[wheel3.11]=1
RESERVED[wheel3.12]=1
RESERVED[wheel3.9]=1
RESERVED[wheel3]=1
RESERVED[whereis]=1
RESERVED[which]=1
RESERVED[who]=1
RESERVED[whoami]=1
RESERVED[whois]=1
RESERVED[wish8.5]=1
RESERVED[wish]=1
RESERVED[write]=1
RESERVED[wrjpgcom]=1
RESERVED[wsdump.py]=1
RESERVED[wsgen]=1
RESERVED[wsimport]=1
RESERVED[xar]=1
RESERVED[xargs]=1
RESERVED[xartutil]=1
RESERVED[xattr]=1
RESERVED[xbmtopbm]=1
RESERVED[xcdebug]=1
RESERVED[xcodebuild]=1
RESERVED[xcrun]=1
RESERVED[xcscontrol]=1
RESERVED[xctrace]=1
RESERVED[xed]=1
RESERVED[xgettext]=1
RESERVED[ximtoppm]=1
RESERVED[xip]=1
RESERVED[xjc]=1
RESERVED[xml2man]=1
RESERVED[xmlcatalog]=1
RESERVED[xmllint]=1
RESERVED[xpath5.30]=1
RESERVED[xpath5.34]=1
RESERVED[xpath]=1
RESERVED[xpmtoppm]=1
RESERVED[xsanctl]=1
RESERVED[xsltproc]=1
RESERVED[xsubpp5.30]=1
RESERVED[xsubpp5.34]=1
RESERVED[xsubpp]=1
RESERVED[xwdtopnm]=1
RESERVED[xxd]=1
RESERVED[xz]=1
RESERVED[xzcat]=1
RESERVED[xzcmp]=1
RESERVED[xzdec]=1
RESERVED[xzdiff]=1
RESERVED[xzegrep]=1
RESERVED[xzfgrep]=1
RESERVED[xzgrep]=1
RESERVED[xzless]=1
RESERVED[xzmore]=1
RESERVED[yaa]=1
RESERVED[yacc]=1
RESERVED[yamllint]=1
RESERVED[yapf-diff]=1
RESERVED[yapf]=1
RESERVED[yapp5.30]=1
RESERVED[yapp5.34]=1
RESERVED[yapp]=1
RESERVED[yat2m]=1
RESERVED[ybmtopbm]=1
RESERVED[yes]=1
RESERVED[yuvtoppm]=1
RESERVED[yuy2topam]=1
RESERVED[z3]=1
RESERVED[zcat]=1
RESERVED[zcmp]=1
RESERVED[zdiff]=1
RESERVED[zdump]=1
RESERVED[zegrep]=1
RESERVED[zeisstopnm]=1
RESERVED[zfgrep]=1
RESERVED[zforce]=1
RESERVED[zgrep]=1
RESERVED[zic]=1
RESERVED[zip]=1
RESERVED[zipcloak]=1
RESERVED[zipdetails]=1
RESERVED[zipgrep]=1
RESERVED[zipinfo]=1
RESERVED[zipnote]=1
RESERVED[zipsplit]=1
RESERVED[zless]=1
RESERVED[zmore]=1
RESERVED[znew]=1
RESERVED[zprint]=1
RESERVED[zsh]=1
RESERVED[zstd]=1
RESERVED[zstdcat]=1
RESERVED[zstdgrep]=1
RESERVED[zstdless]=1
RESERVED[zstdmt]=1
RESERVED[zunit]=1

# This list was generated with commands below plus some manual processing
#
# ```
# echo $PATH
#
# entries=(
#   /bin
#   /opt/local/bin
#   /opt/local/sbin
#   /sbin
#   /usr/bin
#   /usr/local/bin
#   /usr/sbin
# )
#
# for entry in "${entries[@]}"; do
#   ls $entry/?
#   ls $entry/??
#   ls $entry/???
#   ls $entry/????
#   ls $entry/?????
#   ls $entry/??????
#   ls $entry/???????
#   ls $entry/????????
#   ls $entry/?????????
#   ls $entry/??????????
# done
# ```
