#!/bin/sh

cd `dirname $0`

mkdir -pv bin || exit 1
mkdir -pv tmp || exit 1

copy_cmd()
{
    NAME=$1
    if [ ! -x bin/$NAME -o src/$NAME -nt bin/$NAME -o src/ttr -nt bin/$NAME ]; then
        echo "build $NAME"
        if [ "$NAME" = "ttr" ]; then
            perl src/ttr-bootstrap --build --cross --include src src/$NAME > tmp/$NAME || exit 1
            chmod 755 tmp/$NAME || exit 1
            ./tmp/ttr --build --cross --include src src/$NAME > bin/$NAME || exit 1
        else
            ./bin/ttr --build --cross --include src src/$NAME > bin/$NAME || exit 1
        fi
        chmod -v 755 bin/$NAME || exit 1
    fi
}

copy_cmd ttr

copy_cmd csv2tsv
copy_cmd git-amend-past-commit
copy_cmd git-show-commit-message
copy_cmd gitf
copy_cmd gitl
copy_cmd gplot2
copy_cmd histogram
copy_cmd index-of
copy_cmd lstsv
copy_cmd random-normal
copy_cmd random-poisson
copy_cmd random-str
copy_cmd random-uniform
copy_cmd scan
copy_cmd ssv2tsv
copy_cmd tsvaddnum
copy_cmd tsvset
copy_cmd trimhtml

rm bin/scanx 2>/dev/null
rm bin/parj 2>/dev/null

