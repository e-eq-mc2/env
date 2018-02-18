for i in 1 2 4 8 16 32 64 128 256 512 1024
do 
  zero_padded=$(echo $i | xargs printf "%04d\n")
  dd if=/dev/urandom of=random_${zero_padded}MB.dat count=$(expr 1024 \* $i) bs=1024
done
