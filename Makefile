
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

all: $(LOVEBUILDDIR) love

love-zip: love
mac-zip: macapp
	cd $(LOVEBUILDDIR) && zip -r ./$(LOVEMACZIPNAME) ./PLUSKAIZO.app
win32-zip: win32-release
	cd $(LOVEBUILDDIR) && zip -r ./$(LOVEWIN32ZIPNAME) ./win32
linux64-zip: linux64-release
	cd $(LOVEBUILDDIR) && zip -r ./$(LOVELINUX64ZIPNAME) ./linux64

clean:
	rm -r $(LOVEBUILDDIR)

${LOVEBUILDDIR} :
	mkdir -p $@

${LOVEBUILDBINDIR} : | ${LOVEBUILDDIR}
	mkdir -p $@

$(LOVEZIP): $(LOVEBUILDBINDIR)
	zip -r $(LOVEZIP) ./ -x "./love-bin/**" -x "./build/**" -x "./.git/**" -x "*.DS_Store" -x "./.vscode/**"

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
