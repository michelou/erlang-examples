#!/usr/bin/env bash
#
# Copyright (c) 2018-2025 Stéphane Micheloud
#
# Licensed under the MIT License.
#

##############################################################################
## Subroutines

getHome() {
    local source="${BASH_SOURCE[0]}"
    while [[ -h "$source" ]]; do
        local linked="$(readlink "$source")"
        local dir="$( cd -P $(dirname "$source") && cd -P $(dirname "$linked") && pwd )"
        source="$dir/$(basename "$linked")"
    done
    ( cd -P "$(dirname "$source")" && pwd )
}

debug() {
    local DEBUG_LABEL="[46m[DEBUG][0m"
    [[ $DEBUG -eq 1 ]] && echo "$DEBUG_LABEL $1" 1>&2
}

warning() {
    local WARNING_LABEL="[46m[WARNING][0m"
    echo "$WARNING_LABEL $1" 1>&2
}

error() {
    local ERROR_LABEL="[91mError:[0m"
    echo "$ERROR_LABEL $1" 1>&2
}

# use variables EXITCODE, TIMER_START
cleanup() {
    [[ $1 =~ ^[0-1]$ ]] && EXITCODE=$1

    if [[ $TIMER -eq 1 ]]; then
        local TIMER_END=$(date +'%s')
        local duration=$((TIMER_END - TIMER_START))
        echo "Total execution time: $(date -d @$duration +'%H:%M:%S')" 1>&2
    fi
    debug "EXITCODE=$EXITCODE"
    exit $EXITCODE
}

args() {
    [[ $# -eq 0 ]] && HELP=1 && return 1

    for arg in "$@"; do
        case "$arg" in
        ## options
        -debug)       DEBUG=1 ;;
        -help)        HELP=1 ;;
        -timer)       TIMER=1 ;;
        -verbose)     VERBOSE=1 ;;
        -*)
            error "Unknown option $arg"
            EXITCODE=1 && return 0
            ;;
        ## subcommands
        clean)   CLEAN=1 ;;
        compile) COMPILE=1 ;;
        help)    HELP=1 ;;
        lint)    LINT=1 ;;
        run)     COMPILE=1 && RUN=1 ;;
        *)
            error "Unknown subcommand $arg"
            EXITCODE=1 && return 0
            ;;
        esac
    done
    debug "Options    : PROJECT_CONFIG=$PROJECT_CONFIG TIMER=$TIMER VERBOSE=$VERBOSE"
    debug "Subcommands: CLEAN=$CLEAN COMPILE=$COMPILE HELP=$HELP RUN=$RUN"
    debug "Variables  : ERLANG_HOME=$ERLANG_HOME"
    debug "Variables  : GIT_HOME=$GIT_HOME"
    # See http://www.cyberciti.biz/faq/linux-unix-formatting-dates-for-display/
    [[ $TIMER -eq 1 ]] && TIMER_START=$(date +"%s")
}

help() {
    cat << EOS
Usage: $BASENAME { <option> | <subcommand> }

  Options:
    -debug       print commands executed by this script
    -timer       print total execution time
    -verbose     print progress messages

  Subcommands:
    clean        delete generated files
    compile      compile Erlang source files
    help         print this help message
    lint         analyze Erlang source files with Elvis
    run          execute the generated executable
EOS
}

clean() {
    if [[ -d "$TARGET_DIR" ]]; then
        if [[ $DEBUG -eq 1 ]]; then
            debug "rm -rf \"$TARGET_DIR\""
        elif [[ $VERBOSE -eq 1 ]]; then
            echo "Delete directory \"${TARGET_DIR/$ROOT_DIR\//}\"" 1>&2
        fi
        rm -rf "$TARGET_DIR"
        [[ $? -eq 0 ]] || ( EXITCODE=1 && return 0 )
    fi
    if [[ -f "$ROOT_DIR/erl_crash.dump" ]]; then
        rm -f "$ROOT_DIR/erl_crash.dump"
        [[ $? -eq 0 ]] || ( EXITCODE=1 && return 0 )
    fi
}

lint() {
    echo "Not yet implemented"
}

compile() {
    [[ -d "$TARGET_DIR" ]] || mkdir -p "$TARGET_DIR"

    local erlc_flags="-o \"$(mixed_path $TARGET_DIR)\""
    [[ $DEBUG -eq 1 ]] && erlc_flags="-v $erlc_flags"

    local source_files=
    local n=0
    for f in $(find "$SOURCE_MAIN_DIR/" -type f -name "*.erl" 2>/dev/null); do
        source_files="$source_files \"$f\""
        n=$((n + 1))
    done
    if [[ $n -eq 0 ]]; then
        warning "No Erlang source file found"
        return 1
    fi
    local s=; [[ $n -gt 1 ]] && s="s"
    local n_files="$n Erlang source file$s"
    if [[ $DEBUG -eq 1 ]]; then
        debug "\"$ERLC_CMD\" $erlc_flags $source_files"
    elif [[ $VERBOSE -eq 1 ]]; then
        echo "Compile $n_files to directory \"${TARGET_DIR/$ROOT_DIR\//}\"" 1>&2
    fi
    eval "\"$ERLC_CMD\" $erlc_flags $source_files"
    if [[ $? -ne 0 ]]; then
        error "Failed to compile $n_files to directory \"${TARGET_DIR/$ROOT_DIR\//}\""
        cleanup 1
    fi
}

mixed_path() {
    if [[ -x "$CYGPATH_CMD" ]]; then
        $CYGPATH_CMD -am "$*"
    elif [[ $(($mingw + $msys)) -gt 0 ]]; then
        echo "$*" | sed 's|/|\\\\|g'
    else
        echo "$*"
    fi
}

run() {
    local beam_file="$TARGET_DIR/$MODULE_NAME.beam"
    if [[ ! -f "$beam_file" ]]; then
        error "Executable \"${beam_file/$ROOT_DIR\//}\" not found"
        cleanup 1
    fi
    local erlc_opts="-noshell -pa \"$TARGET_DIR\" -s \"$MODULE_NAME\" \"$EXPORT_NAME\" -s init stop"

    if [[ $DEBUG -eq 1 ]]; then
        debug "\"$ERL_CMD\" $erlc_opts"
    elif [[ $VERBOSE -eq 1 ]]; then
        echo "Execute Erlang program \"$MODULE_NAME\"" 1>&2
    fi
    eval "\"$ERL_CMD\" $erlc_opts"
    if [[ $? -ne 0 ]]; then
        error "Failed to execute Erlang program \"$MODULE_NAME\"" 1>&2
        cleanup 1
    fi
}

##############################################################################
## Environment setup

BASENAME=$(basename "${BASH_SOURCE[0]}")

EXITCODE=0

ROOT_DIR="$(getHome)"

SOURCE_DIR="$ROOT_DIR/src"
SOURCE_MAIN_DIR="$SOURCE_DIR/main/erlang"
TARGET_DIR="$ROOT_DIR/target"

MODULE_NAME=factorial
EXPORT_NAME=start

## We refrain from using `true` and `false` which are Bash commands
## (see https://man7.org/linux/man-pages/man1/false.1.html)
CLEAN=0
COMPILE=0
DEBUG=0
HELP=0
LINT=0
RUN=0
TIMER=0
VERBOSE=0

COLOR_START="[32m"
COLOR_END="[0m"

cygwin=0
mingw=0
msys=0
darwin=0
case "$(uname -s)" in
    CYGWIN*) cygwin=1 ;;
    MINGW*)  mingw=1 ;;
    MSYS*)   msys=1 ;;
    Darwin*) darwin=1
esac
unset CYGPATH_CMD
PSEP=":"
TARGET_EXT=
if [[ $(($cygwin + $mingw + $msys)) -gt 0 ]]; then
    CYGPATH_CMD="$(which cygpath 2>/dev/null)"
	PSEP=";"
    TARGET_EXT=".exe"
    ERL_CMD="$(mixed_path $ERLANG_HOME)/bin/erl.exe"
    ERLC_CMD="$(mixed_path $ERLANG_HOME)/bin/erlc.exe"
else
    ERL_CMD=erl
    ERLC_CMD=erlc
fi

args "$@"
[[ $EXITCODE -eq 0 ]] || cleanup 1

##############################################################################
## Main

[[ $HELP -eq 1 ]] && help && cleanup

if [[ $CLEAN -eq 1 ]]; then
    clean || cleanup 1
fi
if [[ $LINT -eq 1 ]]; then
    lint || cleanup 1
fi
if [[ $COMPILE -eq 1 ]]; then
    compile || cleanup 1
fi
if [[ $RUN -eq 1 ]]; then
    run || cleanup 1
fi
cleanup
