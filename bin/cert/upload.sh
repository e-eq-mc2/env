set -x

aws iam delete-server-certificate --server-certificate-name OreOreCA

dir=CA1
aws iam upload-server-certificate --server-certificate-name OreOreCert \
                                  --certificate-body file://$dir/cacert.pem \
                                  --private-key file://$dir/private/cakey_decrypt.pem \
                                  --certificate-chain file://CA0/cacert.pem


