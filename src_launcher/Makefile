rwildcard=$(foreach d,$(wildcard $(1:=/*)),$(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))

SRCDIR=$(CURDIR)/src
BUILDDIR=$(CURDIR)/build
OBJDIR=$(BUILDDIR)/obj

CXX = g++
CROSSCXX_WIN32 = i686-w64-mingw32-
CROSSCXX_WIN32LUAJITLIB = $(CURDIR)/libs/win32/lua51.dll
CROSSCXX_WIN32FLAGS = -I $(SRCDIR) -I $(SRCDIR)/external/ --std=c++17 `pkg-config --cflags luajit` -static
CROSSCXX_WIN64 = x86_64-w64-mingw32-
CROSSCXX_WIN64LUAJITLIB = $(CURDIR)/libs/win64/lua51.dll
CROSSCXX_WIN64FLAGS = -I $(SRCDIR) -I $(SRCDIR)/external/ --std=c++17 `pkg-config --cflags luajit` -static
CROSSCXXPREFIX =
CXXNAME = $(CXX)
CXXFLAGS = `pkg-config --cflags --libs luajit` -g -I $(SRCDIR) -I $(SRCDIR)/external/ --std=c++17 -O3
SOURCES = $(call rwildcard,./src/,*.cpp)
OBJECTS = $(patsubst %,$(OBJDIR)/%,$(notdir $(SOURCES:%.cpp=%.o)))

all: $(BUILDDIR) $(OBJDIR) $(BUILDDIR)/PLUSKAIZO

$(BUILDDIR) :
	mkdir -p $@

$(OBJDIR) : | $(BUILDDIR)
	mkdir -p $@

$(OBJDIR)/%.o: $(SRCDIR)/%.cpp
	$(CXXNAME) $(CXXFLAGS) -MMD -c $< -o $@
	
-include $(OBJDIR)/*.d

$(BUILDDIR)/PLUSKAIZO: $(OBJECTS) | $(BUILDDIR)
	$(CXXNAME) $(CXXFLAGS) -o $@ $(OBJECTS)
	
clean:
	rm $(OBJDIR)/*.o
	rm $(OBJDIR)/*.d

$(OBJDIR)/winicon.o: $(OBJDIR) $(SRCDIR)/windows/icon.rc
	$(CROSSCXXPREFIX)windres $(SRCDIR)/windows/icon.rc -o $(OBJDIR)/winicon.o

crosswin64: CXXNAME=$(CROSSCXX_WIN64)$(CXX)
crosswin64: CROSSCXXPREFIX=$(CROSSCXX_WIN64)
crosswin64: $(BUILDDIR) $(OBJDIR) $(OBJDIR)/winicon.o $(BUILDDIR)/PLUSKAIZO-x86_64.exe

$(BUILDDIR)/PLUSKAIZO-x86_64.exe: $(OBJECTS) | $(BUILDDIR)
	$(CXXNAME) -o $(BUILDDIR)/PLUSKAIZO-x86_64.exe $(OBJECTS) $(OBJDIR)/winicon.o $(CROSSCXX_WIN64FLAGS) $(CROSSCXX_WIN64LUAJITLIB)

crosswin32: CXXNAME=$(CROSSCXX_WIN32)$(CXX)
crosswin32: CROSSCXXPREFIX=$(CROSSCXX_WIN32)
crosswin32: $(BUILDDIR) $(OBJDIR) $(OBJDIR)/winicon.o $(BUILDDIR)/PLUSKAIZO-x86.exe

$(BUILDDIR)/PLUSKAIZO-x86.exe: $(OBJECTS) | $(BUILDDIR)
	$(CXXNAME) -o $(BUILDDIR)/PLUSKAIZO-x86.exe $(OBJECTS) $(OBJDIR)/winicon.o $(CROSSCXX_WIN32FLAGS) $(CROSSCXX_WIN32LUAJITLIB)

