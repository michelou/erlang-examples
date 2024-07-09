##
## Copyright (c) 2018-2024 Stéphane Micheloud
##
## Licensed under the MIT License.
##
##############################################################################

include ../Makefile.inc

##############################################################################
## main rules

SOURCE_FILES=$(wildcard src/main/erlang/*.erl)

MODULE_NAME=hello
EXPORT_NAME=start

TARGET_DIR=target

all: build

build: $(SOURCE_FILES)
	@$(TEST) -d "$(TARGET_DIR)" || "$(MKDIR)" -p "$(TARGET_DIR)"
	"$(ERLC)" -o "$(TARGET_DIR)" $<

run: build
	"$(ERL)" -noshell -pa "$(TARGET_DIR)" -s "$(MODULE_NAME)" "$(EXPORT_NAME)" -s init stop

clean:
	"$(RM)" -rf "$(TARGET_DIR)"
	#@$(TEST) -f "erl_crash.dump" && "$(RM)" "erl_crash.dump"

help:
	@$(ECHO) "Usage: make all|build|clean|executable|help|run"
	@$(ECHO) ""
	@$(ECHO) "  Subcommands:"
	@$(ECHO) "    all    alias for build"
	@$(ECHO) "    build  compile Erlang source files"
	@$(ECHO) "    clean  delete generated files"
	@$(ECHO) "    help   print this help message"
	@$(ECHO) "    run    execute main program \"$(MODULE_NAME)\""

##############################################################################
## phony

.PHONY: all build clean help run

.SUFFIXES:
.SUFFIXES: .beam .erl .exe
