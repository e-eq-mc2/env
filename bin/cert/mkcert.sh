set -x 

dir0=CA0

rm -rf $dir0

#秘密鍵保存ディレクトリ
mkdir -p $dir0/private
 
#失効リスト保存ディレクトリ
mkdir -p $dir0/crl
 
#署名された証明書保存ディレクトリ
mkdir -p $dir0/newcerts
 
#root以外のアクセス不可
chmod 700 $dir0/private

#データベース作成
touch $dir0/index.txt

echo "01" > $dir0/serial

cd $dir0

subj="/C=JP/ST=Tokyo-to/L=Meguro-ku/O=Example company/OU=Example dept./CN=CA0"
openssl req -new -x509 -newkey rsa:2048  -out cacert.pem -days 3650 -keyout private/cakey.pem -subj "$subj"

openssl rsa -in private/cakey.pem -out private/cakey_decrypt.pem

cd ..

dir1=CA1

rm -rf $dir1

#証明書検証用ディレクトリ
mkdir -p $dir1/certs
 
#CA秘密鍵保存ディレクトリ
mkdir -p $dir1/private
 
#失効リスト保存ディレクトリ
mkdir -p $dir1/crl
 
#署名された証明書保存ディレクトリ
mkdir -p $dir1/newcerts
 
#root以外のアクセス不可
chmod 700 $dir1/private
 
#シリアルファイル作成
echo 01 > $dir1/serial
 
#データベース作成
touch $dir1/index.txt

cd $dir1 

subj="/C=JP/ST=Tokyo-to/L=Meguro-ku/O=Example company/OU=Example dept./CN=CA1"
openssl req -config ../openssl_0.cnf -new -newkey rsa:2048  -out cacert_req.pem -days 3650 -keyout private/cakey.pem -subj "$subj"

openssl ca -config ../openssl_1.cnf -days 3650 -out cacert.pem -infiles cacert_req.pem

openssl rsa -in private/cakey.pem -out private/cakey_decrypt.pem

cd ..
openssl verify -purpose sslclient -CAfile $dir0/cacert.pem $dir1/cacert.pem
