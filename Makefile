
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

all: $(LOVEBUILDDIR) launcher-all
	cd $(CURDIR)/src_launcher && make all
	cp $(CURDIR)/src_launcher/build/PLUSKAIZO $(LOVEBUILDDIR)/PLUSKAIZO

crosslinux64: LAUNCHERLIBS=$(CURDIR)/src_launcher/libs/linux64/*
crosslinux64: $(LOVEBUILDDIR) launcher-all
	cd $(CURDIR)/src_launcher && make crosslinux64
	cp $(CURDIR)/src_launcher/build/PLUSKAIZO-x86_64 $(LOVEBUILDDIR)/PLUSKAIZO

crosswin32: LAUNCHERLIBS=$(CURDIR)/src_launcher/libs/win32/*
crosswin32: $(LOVEBUILDDIR) launcher-all
	cd $(CURDIR)/src_launcher && make crosswin32
	cp $(CURDIR)/src_launcher/build/PLUSKAIZO-x86.exe $(LOVEBUILDDIR)/PLUSKAIZO.exe

crosswin64: LAUNCHERLIBS=$(CURDIR)/src_launcher/libs/win64/*
crosswin64: $(LOVEBUILDDIR) launcher-all
	cd $(CURDIR)/src_launcher && make crosswin64
	cp $(CURDIR)/src_launcher/build/PLUSKAIZO-x64.exe $(LOVEBUILDDIR)/PLUSKAIZO.exe

clean:
	cd $(CURDIR)/src_launcher && make clean
	rm -r $(LOVEBUILDDIR)

launcher-all:
	cp $(LAUNCHERLIBS) $(LOVEBUILDDIR)/
	cp -R $(CURDIR)/src/ $(LOVEBUILDDIR)/src/
	cp -R $(CURDIR)/data/ $(LOVEBUILDDIR)/data/
	cp readme.txt $(LOVEBUILDDIR)/readme.txt
	cp license.txt $(LOVEBUILDDIR)/license.txt
	cp main_notlove.lua $(LOVEBUILDDIR)/main_notlove.lua

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

