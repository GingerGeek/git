#!/bin/sh
#
# Run Git performance in parallel
#

. ${0%/*}/lib.sh

case "$CI_OS_NAME" in
windows*) cmd //c mklink //j t\\.prove "$(cygpath -aw "$cache_dir/.prove")";;
*) ln -s "$cache_dir/.prove" t/.prove;;
esac


run_tests=t

case "$jobname" in
linux-gcc)
	export GIT_TEST_DEFAULT_INITIAL_BRANCH_NAME=main
	;;
linux-TEST-vars)
	export GIT_TEST_SPLIT_INDEX=yes
	export GIT_TEST_MERGE_ALGORITHM=recursive
	export GIT_TEST_FULL_IN_PACK_ARRAY=true
	export GIT_TEST_OE_SIZE=10
	export GIT_TEST_OE_DELTA_SIZE=5
	export GIT_TEST_COMMIT_GRAPH=1
	export GIT_TEST_COMMIT_GRAPH_CHANGED_PATHS=1
	export GIT_TEST_MULTI_PACK_INDEX=1
	export GIT_TEST_MULTI_PACK_INDEX_WRITE_BITMAP=1
	export GIT_TEST_ADD_I_USE_BUILTIN=0
	export GIT_TEST_DEFAULT_INITIAL_BRANCH_NAME=master
	export GIT_TEST_WRITE_REV_INDEX=1
	export GIT_TEST_CHECKOUT_WORKERS=2
	;;
linux-clang)
	export GIT_TEST_DEFAULT_HASH=sha1
	;;
linux-sha256)
	export GIT_TEST_DEFAULT_HASH=sha256
	;;
pedantic)
	# Don't run the tests; we only care about whether Git can be
	# built.
	export DEVOPTS=pedantic
	run_tests=
	;;
esac

if test -n "$run_tests"
then
    # Todo, slice this up!
	group "Run performance tests" make -j${CI_MAKECONCURRENCY} --quiet -C t/perf/ all ||
	handle_failed_tests
else
	echo "Performance Tests are skipped, this job didn't need to run!"
	exit 1
fi
check_unignored_build_artifacts
