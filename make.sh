#!/bin/sh

cd `dirname $0`

mkdir -pv bin || exit 1
mkdir -p tmp || exit 1

copy_cmd()
{
    NAME=$1
    if [ ! -e bin/$NAME -o src/$NAME -nt bin/$NAME ]; then
        echo "build $NAME"
        perl src/ttr --build --cross --include src src/$NAME > bin/$NAME || exit 1
        chmod -v 755 bin/$NAME || exit 1
    fi
}

copy_cmd tempdir

copy_cmd csv2tsv
copy_cmd git-amend-past-commit
copy_cmd gitl
copy_cmd gplot2
copy_cmd histogram
copy_cmd index-of
copy_cmd lstsv
copy_cmd random-normal
copy_cmd random-poisson
copy_cmd random-str
copy_cmd random-uniform
copy_cmd scanj
copy_cmd scanx
copy_cmd ssv2tsv
copy_cmd tsvaddnum
copy_cmd tsvset
copy_cmd trimhtml

rm -r tmp

