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
            sh src/ttr-bootstrap --build --cross --include src src/$NAME > tmp/$NAME || exit 1
            chmod 755 tmp/$NAME || exit 1
            ./tmp/ttr --build --cross --include src src/$NAME > tmp/build-$NAME || exit 1
            rm tmp/ttr
            mv tmp/build-$NAME bin/$NAME
            cp bin/$NAME src/ttr-bootstrap
        else
            ./bin/ttr --build --cross --include src src/$NAME > tmp/build-$NAME || exit 1
            mv tmp/build-$NAME bin/$NAME
        fi
        chmod -v 755 bin/$NAME || exit 1
    fi
}

copy_cmd ttr

for f in `ls src`; do
    if [ -f src/$f -a $f != ttr -a $f != ttr-bootstrap ]; then
        if ! echo $f | grep '\.' >/dev/null; then
            copy_cmd $f
        fi
    fi
done

rm bin/scanx 2>/dev/null
rm bin/parj 2>/dev/null

exit 0

