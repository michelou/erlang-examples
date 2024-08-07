#!/usr/bin/env bash
#
# Copyright (c) 2018-2024 Stéphane Micheloud
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
    $DEBUG && echo "$DEBUG_LABEL $1" 1>&2
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

    if $TIMER; then
        local TIMER_END=$(date +'%s')
        local duration=$((TIMER_END - TIMER_START))
        echo "Total execution time: $(date -d @$duration +'%H:%M:%S')" 1>&2
    fi
    debug "EXITCODE=$EXITCODE"
    exit $EXITCODE
}

args() {
    [[ $# -eq 0 ]] && HELP=true && return 1

    for arg in "$@"; do
        case "$arg" in
        ## options
        -debug)       DEBUG=true ;;
        -help)        HELP=true ;;
        -timer)       TIMER=true ;;
        -verbose)     VERBOSE=true ;;
        -*)
            error "Unknown option $arg"
            EXITCODE=1 && return 0
            ;;
        ## subcommands
        clean)   CLEAN=true ;;
        compile) COMPILE=true ;;
        help)    HELP=true ;;
        lint)    LINT=true ;;
        run)     COMPILE=true && RUN=true ;;
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
    $TIMER && TIMER_START=$(date +"%s")
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
        if $DEBUG; then
            debug "rm -rf \"$TARGET_DIR\""
        elif $VERBOSE; then
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
    $DEBUG && erlc_flags="-v $erlc_flags"

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
    if $DEBUG; then
        debug "\"$ERLC_CMD\" $erlc_flags $source_files"
    elif $VERBOSE; then
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
    elif $mingw || $msys; then
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

    if $DEBUG; then
        debug "\"$ERL_CMD\" $erlc_opts"
    elif $VERBOSE; then
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

CLEAN=false
COMPILE=false
DEBUG=false
HELP=false
LINT=false
RUN=false
TIMER=false
VERBOSE=false

COLOR_START="[32m"
COLOR_END="[0m"

cygwin=false
mingw=false
msys=false
darwin=false
case "$(uname -s)" in
    CYGWIN*) cygwin=true ;;
    MINGW*)  mingw=true ;;
    MSYS*)   msys=true ;;
    Darwin*) darwin=true
esac
unset CYGPATH_CMD
PSEP=":"
TARGET_EXT=
if $cygwin || $mingw || $msys; then
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

$HELP && help && cleanup

if $CLEAN; then
    clean || cleanup 1
fi
if $LINT; then
    lint || cleanup 1
fi
if $COMPILE; then
    compile || cleanup 1
fi
if $RUN; then
    run || cleanup 1
fi
cleanup
