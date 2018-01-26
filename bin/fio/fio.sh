fio || sudo yum install -y fio

size=256m
directory=tmp
numjobs=1
resbase=results 

rm -rf $resbase

for bs in 4k 8k 16k 32k 64k 128k 256k 512k
#for bs in 256k 512k
do
  rm -rf $directory
  mkdir -p $directory 
  
  set -x

  echo "--------$bs--------"
  resdir=$resbase/$bs
  mkdir -p $resdir
  
  fio --ioengine=libaio --numjobs=$numjobs --iodepth=1 --invalidate=1 --direct=1 --size=$size --group_reporting --directory=$directory --bs=$bs --output=$resdir/sequential-read.txt --name=sequential-read --rw=read
  fio --ioengine=libaio --numjobs=$numjobs --iodepth=1 --invalidate=1 --direct=1 --size=$size --group_reporting --directory=$directory --bs=$bs --output=$resdir/sequential-write.txt --name=sequential-write --rw=write
  fio --ioengine=libaio --numjobs=$numjobs --iodepth=1 --invalidate=1 --direct=1 --size=$size --group_reporting --directory=$directory --bs=$bs --output=$resdir/sequential-readwrite.txt --name=sequential-readwrite --rw=readwrite
  fio --ioengine=libaio --numjobs=$numjobs --iodepth=1 --invalidate=1 --direct=1 --size=$size --group_reporting --directory=$directory --bs=$bs --output=$resdir/random-readwrite.txt --name=random-r50w50 --rw=randrw --rwmixread=50
done
