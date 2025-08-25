
LOVEBUILDDIR = ./build
LOVEBUILDBINDIR = $(LOVEBUILDDIR)/bin
LOVEZIPNAME = PLUSKAIZO.love
LOVEZIP = $(LOVEBUILDDIR)/$(LOVEZIPNAME)
LOVEWIN32NAME = PLUSKAIZO-Win32
LOVEWIN32ZIPNAME = PLUSKAIZO_Win32.zip
LOVEWIN32 = $(LOVEBUILDBINDIR)/$(LOVEWIN32NAME)
LOVEWIN32ZIP = $(LOVEBUILDDIR)/$(LOVEWIN32ZIPNAME)
LOVELINUX64NAME = PLUSKAIZO-Linux-x86_64
LOVELINUX64ZIPNAME = PLUSKAIZO_Linux_x86_64.zip
LOVELINUX64 = $(LOVEBUILDBINDIR)/$(LOVELINUX64NAME)
LOVELINUX64ZIP = $(LOVEBUILDDIR)/$(LOVELINUX64ZIPNAME)
LOVEMACNAME = PLUSKAIZO.app
LOVEMACZIPNAME = PLUSKAIZO_macOS.zip
LOVEMAC = $(LOVEBUILDBINDIR)/$(LOVEMACNAME)
LOVEMACZIP = $(LOVEBUILDDIR)/$(LOVEMACZIPNAME)

#SRCFILES = $(shell find src -name '*' !  -name '*.git*' ! -name '*.DS_Store' | sed 's@ @\\ @g') #https://stackoverflow.com/a/78880090

SUBBUILDDIR = $(LOVEBUILDDIR)
LAUNCHERLIBS =
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
    LAUNCHERLIBS = $(CURDIR)/src_launcher/libs/linux64/*
endif
ifeq ($(UNAME_S),Darwin)
    LAUNCHERLIBS = $(CURDIR)/src_launcher/libs/macos/*
endif
ifeq ($(OS),Windows_NT)
	ifeq ($(PROCESSOR_ARCHITEW6432),AMD64)
        LAUNCHERLIBS = $(CURDIR)/src_launcher/libs/win64/*
    else
        ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)
            LAUNCHERLIBS = $(CURDIR)/src_launcher/libs/win64/*
        endif
        ifeq ($(PROCESSOR_ARCHITECTURE),x86)
            LAUNCHERLIBS = $(CURDIR)/src_launcher/libs/win32/*
        endif
    endif
endif

all: $(LOVEBUILDDIR) launcher-make-all launcher-all
	cp $(CURDIR)/src_launcher/build/PLUSKAIZO $(LOVEBUILDDIR)/PLUSKAIZO

crosslinux64: LAUNCHERLIBS=$(CURDIR)/src_launcher/libs/linux64/*
crosslinux64: $(SUBBUILDDIR) launcher-all $(CURDIR)/src_launcher/build/PLUSKAIZO-x86_64
	cp $(CURDIR)/src_launcher/build/PLUSKAIZO-x86_64 $(SUBBUILDDIR)/PLUSKAIZO

crosswin32: LAUNCHERLIBS=$(CURDIR)/src_launcher/libs/win32/*
crosswin32: $(SUBBUILDDIR) launcher-all $(CURDIR)/src_launcher/build/PLUSKAIZO-x86.exe
	cp $(CURDIR)/src_launcher/build/PLUSKAIZO-x86.exe $(SUBBUILDDIR)/PLUSKAIZO.exe

crosswin64: LAUNCHERLIBS=$(CURDIR)/src_launcher/libs/win64/*
crosswin64: $(SUBBUILDDIR) launcher-all $(CURDIR)/src_launcher/build/PLUSKAIZO-x86_64.exe
	cp $(CURDIR)/src_launcher/build/PLUSKAIZO-x86_64.exe $(SUBBUILDDIR)/PLUSKAIZO.exe

macapp: LAUNCHERLIBS=$(CURDIR)/src_launcher/libs/macos/*
macapp: SUBBUILDDIR=$(LOVEBUILDDIR)/PLUSKAIZO.app/Contents/MacOS
macapp: $(LOVEBUILDDIR) $(CURDIR)/src_launcher/build/PLUSKAIZO
	mkdir -p $(SUBBUILDDIR)
	mkdir -p $(LOVEBUILDDIR)/PLUSKAIZO.app/Contents/Resources

	cp $(CURDIR)/src_launcher/build/PLUSKAIZO $(LOVEBUILDDIR)/PLUSKAIZO.app/Contents/MacOS/PLUSKAIZO
	cp $(CURDIR)/src_launcher/src/mac/Info.plist $(LOVEBUILDDIR)/PLUSKAIZO.app/Contents/Info.plist
	cp $(CURDIR)/src_launcher/src/mac/run_PLUSKAIZO_mac.sh $(LOVEBUILDDIR)/PLUSKAIZO.app/Contents/MacOS/run_PLUSKAIZO_mac.sh
	cp $(CURDIR)/love-bin/icon.icns $(LOVEBUILDDIR)/PLUSKAIZO.app/Contents/Resources/icon.icns
macapp: launcher-all

win32-release: SUBBUILDDIR=$(LOVEBUILDDIR)/win32
win32-release: $(SUBBUILDDIR) crosswin32 launcher-all

win64-release: SUBBUILDDIR=$(LOVEBUILDDIR)/win64
win64-release: $(SUBBUILDDIR) crosswin64 launcher-all

linux64-release: SUBBUILDDIR=$(LOVEBUILDDIR)/linux64
linux64-release: $(SUBBUILDDIR) crosslinux64 launcher-all

love-zip: love
mac-zip: macapp
	cd $(LOVEBUILDDIR) && zip -r ./$(LOVEMACZIPNAME) ./PLUSKAIZO.app
win32-zip: win32-release
	cd $(LOVEBUILDDIR) && zip -r ./$(LOVEWIN32ZIPNAME) ./win32
linux64-zip: linux64-release
	cd $(LOVEBUILDDIR) && zip -r ./$(LOVELINUX64ZIPNAME) ./linux64

clean:
	rm -r $(LOVEBUILDDIR)
	cd $(CURDIR)/src_launcher && $(MAKE) clean

clean-launcher:
	cd $(CURDIR)/src_launcher && $(MAKE) clean

launcher-all: $(SUBBUILDDIR)
	mkdir -p $(SUBBUILDDIR)
	cp $(LAUNCHERLIBS) $(SUBBUILDDIR)/
	cp -R $(CURDIR)/src/ $(SUBBUILDDIR)/src/
	cp -R $(CURDIR)/data/ $(SUBBUILDDIR)/data/
	cp readme.txt $(SUBBUILDDIR)/readme.txt
	cp license.txt $(SUBBUILDDIR)/license.txt
	cp main_notlove.lua $(SUBBUILDDIR)/main_notlove.lua


$(CURDIR)/src_launcher/build/PLUSKAIZO: launcher-make-all
launcher-make-all:
	cd $(CURDIR)/src_launcher && $(MAKE) all

$(CURDIR)/src_launcher/build/PLUSKAIZO-x86_64: launcher-make-crosslinux64
launcher-make-crosslinux64:
	cd $(CURDIR)/src_launcher && $(MAKE) crosslinux64

$(CURDIR)/src_launcher/build/PLUSKAIZO-x86.exe: launcher-make-crosswin32
launcher-make-crosswin32:
	cd $(CURDIR)/src_launcher && $(MAKE) crosswin32

$(CURDIR)/src_launcher/build/PLUSKAIZO-x86_64.exe: launcher-make-crosswin64
launcher-make-crosswin64:
	cd $(CURDIR)/src_launcher && $(MAKE) crosswin64

${LOVEBUILDDIR} :
	mkdir -p $@

${LOVEBUILDBINDIR} : | ${LOVEBUILDDIR}
	mkdir -p $@

$(LOVEZIP): $(LOVEBUILDBINDIR)
	zip -r $(LOVEZIP) ./ -x "./love-bin/**" -x "./build/**" -x "./.git/**" -x "*.DS_Store" -x "./src_launcher/**" -x "./.vscode/**"

$(LOVEWIN32): $(LOVEBUILDBINDIR) $(LOVEZIP)
	mkdir -p $(LOVEWIN32)

	cat ./love-bin/bin/love-11.5-win32/love.exe $(LOVEZIP) > $(LOVEWIN32)/PLUSKAIZO.exe

	cp ./love-bin/bin/love-11.5-win32/SDL2.dll $(LOVEWIN32)/SDL2.dll
	cp ./love-bin/bin/love-11.5-win32/OpenAL32.dll $(LOVEWIN32)/OpenAL32.dll
	cp ./love-bin/bin/love-11.5-win32/license.txt $(LOVEWIN32)/license-love.txt
	cp ./love-bin/bin/love-11.5-win32/love.dll $(LOVEWIN32)/love.dll
	cp ./love-bin/bin/love-11.5-win32/lua51.dll $(LOVEWIN32)/lua51.dll
	cp ./love-bin/bin/love-11.5-win32/mpg123.dll $(LOVEWIN32)/mpg123.dll
	cp ./love-bin/bin/love-11.5-win32/msvcp120.dll $(LOVEWIN32)/msvcp120.dll
	cp ./love-bin/bin/love-11.5-win32/msvcr120.dll $(LOVEWIN32)/msvcr120.dll

$(LOVEMAC): $(LOVEBUILDBINDIR) $(LOVEZIP)
	cp -R ./love-bin/bin/love.app/ ./build/bin/PLUSKAIZO.app/
	cp $(LOVEZIP) ./build/bin/PLUSKAIZO.app/Contents/Resources/$(LOVEZIPNAME)
	cp ./love-bin/Info.plist ./build/bin/PLUSKAIZO.app/Contents/Info.plist
	cp ./love-bin/icon.icns ./build/bin/PLUSKAIZO.app/Contents/Resources/icon.icns

$(LOVELINUX64): $(LOVEBUILDBINDIR) $(LOVEZIP)
	7zz x ./love-bin/bin/love-11.5-x86_64.AppImage -o$(LOVELINUX64)
	cat $(LOVELINUX64)/bin/love $(LOVEZIP) > $(LOVELINUX64)/bin/PLUSKAIZO
	chmod +x $(LOVELINUX64)/bin/PLUSKAIZO

	rm $(LOVELINUX64)/bin/love
	rm $(LOVELINUX64)/AppRun
	rm $(LOVELINUX64)/love.desktop
	rm $(LOVELINUX64)/love.svg

	cp ./love-bin/run_PLUSKAIZO_linux.sh $(LOVELINUX64)/run_PLUSKAIZO_linux.sh

love-release: $(LOVEBUILDBINDIR) $(LOVEZIP) $(LOVEWIN32) $(LOVEMAC) $(LOVELINUX64)
	cd $(LOVEBUILDBINDIR) && zip -r ../$(LOVEMACZIPNAME) ./$(LOVEMACNAME)
	cd $(LOVEBUILDBINDIR) && zip -r ../$(LOVEWIN32ZIPNAME) ./$(LOVEWIN32NAME)
	cd $(LOVEBUILDBINDIR) && zip -r ../$(LOVELINUX64ZIPNAME) ./$(LOVELINUX64NAME)
	cd $(LOVEBUILDDIR) && rm -r ./bin

love: $(LOVEZIP)
love-win32: $(LOVEWIN32)
love-linux64: $(LOVELINUX64)
love-mac: $(LOVEMAC)
