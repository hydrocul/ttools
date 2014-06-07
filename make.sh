#!/bin/sh

cd `dirname $0`

mkdir -pv bin || exit 1
mkdir -pv tmp || exit 1

copy_cmd()
{
    NAME=$1
    if [ ! -e bin/$NAME -o src/$NAME -nt bin/$NAME ]; then
        echo "build $NAME"
        if grep '^\s*##tempdir' src/$NAME >/dev/null; then
            cat src/$NAME | bin/tempdir --build-cross > tmp/$NAME
            SRC=tmp/$NAME
        else
            SRC=src/$NAME
        fi
        cat $SRC | perl -e '
            sub process_line {
                ($line) = @_;
                if ($line =~ /^\s*##include\s+([-_.a-zA-Z0-9]+)\s*$/) {
                    $fname = $1;
                    $hash = `cat src/$fname | md5sum | cut -b-32`;
                    $hash =~ s/^\s*(.*?)\s*$/$1/;
                    print "cat <<\\$hash > \$WORKING_DIR/$fname\n";
                    open(FP, "<", "src/$fname") or die "Cannot open bin/$fname";
                    process_line($_) while (<FP>);
                    close FP;
                    print "$hash\n";
                } else {
                    print $line;
                }
            }
            process_line($_) while (<STDIN>);
        ' > bin/$NAME || exit 1
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

