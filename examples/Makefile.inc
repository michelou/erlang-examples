ifeq ($(OS),Windows_NT)
ifndef ERLANG_HOME
$(error Variable ERLANG_HOME is not set)
endif
ifndef MSYS_HOME
$(error Variable MSYS_HOME is not set)
endif

TARGET_EXT  = .exe
PSEP        = ;
ERLANG_BIN  = $(subst \,/,$(ERLANG_HOME))/bin
MSYS_PATH   = $(subst \,/,$(MSYS_HOME))
#
CXX         = $(MSYS_PATH)/mingw64/bin/g++.exe
ECHO        = $(MSYS_PATH)/usr/bin/echo.exe
ERL         = $(ERLANG_BIN)/erl.exe
ERLC        = $(ERLANG_BIN)/erlc.exe
FIND        = $(MSYS_PATH)/usr/bin/find.exe
MKDIR       = $(MSYS_PATH)/usr/bin/mkdir.exe
RM          = $(MSYS_PATH)/usr/bin/rm.exe
TEST        = $(MSYS_PATH)/usr/bin/test.exe
TOUCH       = $(MSYS_PATH)/usr/bin/touch.exe
else
TARGET_EXT  =
PSEP        = :
CP          = cp
ECHO        = echo
ERL         = erl
ERLC        = erlc
FIND        = find
MKDIR       = mkdir
RM          = rm
TEST        = test
TOUCH       = touch
endif
