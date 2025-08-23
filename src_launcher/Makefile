rwildcard=$(foreach d,$(wildcard $(1:=/*)),$(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))

SRCDIR=$(CURDIR)/src
BUILDDIR=$(CURDIR)/build
OBJDIR=$(BUILDDIR)/obj

CXX = clang++
CXXFLAGS = `pkg-config --cflags --libs luajit` -g -I ./src/ -I ./src/external/ --std=c++17
SOURCES = $(call rwildcard,./src/,*.cpp)
OBJECTS = $(patsubst %,$(OBJDIR)/%,$(notdir $(SOURCES:%.cpp=%.o)))

all: $(BUILDDIR) $(OBJDIR) $(BUILDDIR)/PLUSKAIZO

$(BUILDDIR) :
	mkdir -p $@

$(OBJDIR) : | $(BUILDDIR)
	mkdir -p $@

$(OBJDIR)/%.o: $(SRCDIR)/%.cpp
	$(CXX) $(CXXFLAGS) -MMD -c $< -o $@
	
-include $(OBJDIR)/*.d

$(BUILDDIR)/PLUSKAIZO: $(OBJECTS) | $(BUILDDIR)
	$(CXX) $(CXXFLAGS) -o $@ $(OBJECTS)
	
clean:
	rm $(OBJDIR)/*.o
	rm $(OBJDIR)/*.d
	

