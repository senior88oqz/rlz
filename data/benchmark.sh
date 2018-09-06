#!/bin/sh
for filename in ./raw/*.txt; do
    echo "Processing $filename..." >> benchmark.log
    for level in 1 6 9; do
        echo "gzip level $level" >> benchmark.log
        # (time gzip -$level -c $filename > "${filename}_${level}.gz") 2>> benchmark.log
        (time gzip -$level $filename) &>> benchmark.log
        du -k ${filename}.gz >> benchmark.log
        (time gunzip "${filename}.gz") &>> benchmark.log
        echo "----------------------" >> benchmark.log

        for thread in 1 2 3 4; do
            echo "parallel gzip(pigz) level: $level thread: $thread" >> benchmark.log
            # (time gzip -$level -c $filename > "${filename}_${level}.gz") 2>> benchmark.log
            (time pigz -$level -p $thread $filename) &>> benchmark.log
            du -k ${filename}.gz >> benchmark.log
            (time unpigz -p $thread "${filename}.gz") &>> benchmark.log
            echo "----------------------" >> benchmark.log
        done
        echo "bzip2 level $level" >> benchmark.log
        (time bzip2 -$level $filename) &>> benchmark.log
        du -k ${filename}.bz2 >> benchmark.log
        (time bunzip2 "${filename}.bz2") &>> benchmark.log
        echo "----------------------" >> benchmark.log

        echo "lzma level $level" >> benchmark.log
        (time lzma -$level $filename) &>> benchmark.log
        du -k ${filename}.lzma >> benchmark.log
        (time unlzma "${filename}.lzma") &>> benchmark.log
        echo "----------------------" >> benchmark.log
    done
    echo "***************************" >> benchmark.log
done
