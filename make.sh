#!/bin/sh

cd `dirname $0`

mkdir -pv bin || exit 1
mkdir -pv tmp || exit 1

################################
# binディレクトリに生成
################################

copy_cmd()
{
    NAME=$1
    if [ ! -x bin/$NAME -o src/$NAME -nt bin/$NAME -o src/ttr -nt bin/$NAME ]; then
        echo "build $NAME"
        if [ "$NAME" = "ttr" ]; then
            sh src/ttr-bootstrap --build --cross --include src src/ttr > tmp/ttr || exit 1
            chmod 755 tmp/ttr || exit 1
            ./tmp/ttr --build --cross --include src src/ttr > tmp/build-ttr || exit 1
            diff -u ./tmp/ttr ./tmp/build-ttr || exit 1
            rm tmp/ttr
            mv tmp/build-ttr bin/ttr
            cp bin/ttr src/ttr-bootstrap
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

################################
# テストケースを実行
################################

mkdir -p test/ttr/actual

RESULT=0
for f in `ls test/ttr/cases`; do
    if [ -f test/ttr/cases/$f ]; then

        r=0

        if [ ! -e test/ttr/expected/$f.translated ]; then
            touch test/ttr/expected/$f.translated
        fi
        if [ ! -e test/ttr/expected/$f.result ]; then
            touch test/ttr/expected/$f.result
        fi

        if [ "$r" = 0 ]; then
            cat test/ttr/cases/$f | ttr --build --cross --include test/ttr/cases/lib > test/ttr/actual/$f.translated.1
            if ! diff test/ttr/expected/$f.translated test/ttr/actual/$f.translated.1 >/dev/null; then
                r=1
                /bin/echo -e "\e[31m./test/ttr/cases/$f NG\e[0m"
                diff -u test/ttr/expected/$f.translated test/ttr/actual/$f.translated.1
            fi
        fi

        if [ "$r" = 0 ]; then
            ttr test/ttr/cases/$f --build --cross --include test/ttr/cases/lib > test/ttr/actual/$f.translated.2
            if ! diff test/ttr/expected/$f.translated test/ttr/actual/$f.translated.2 >/dev/null; then
                r=1
                /bin/echo -e "\e[31m./test/ttr/cases/$f NG\e[0m"
                diff -u test/ttr/expected/$f.translated test/ttr/actual/$f.translated.2
            fi
        fi

        if [ "$r" = 0 ]; then
            cat test/ttr/cases/$f | ttr --include test/ttr/cases/lib > test/ttr/actual/$f.result.1
            if ! diff test/ttr/expected/$f.result test/ttr/actual/$f.result.1 >/dev/null; then
                r=1
                /bin/echo -e "\e[31m./test/ttr/cases/$f NG\e[0m"
                diff -u test/ttr/expected/$f.result test/ttr/actual/$f.result.1
            fi
        fi

        if [ "$r" = 0 ]; then
            ttr test/ttr/cases/$f --include test/ttr/cases/lib > test/ttr/actual/$f.result.2
            if ! diff test/ttr/expected/$f.result test/ttr/actual/$f.result.2 >/dev/null; then
                r=1
                /bin/echo -e "\e[31m./test/ttr/cases/$f NG\e[0m"
                diff -u test/ttr/expected/$f.result test/ttr/actual/$f.result.2
            fi
        fi

        if [ "$r" = 0 ]; then
            /bin/echo -e "\e[34m./test/ttr/cases/$f OK\e[0m"
        else
            RESULT=1
        fi

    fi
done

if [ "$RESULT" = 0 ]; then
    /bin/echo -e "\e[34mSucceeded.\e[0m"
else
    /bin/echo -e "\e[31mFailed.\e[0m"
fi

exit $RESULT

