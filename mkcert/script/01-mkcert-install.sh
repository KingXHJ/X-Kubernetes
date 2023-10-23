# URL: https://github.com/FiloSottile/mkcert
# 1 On Linux, first install certutil.
sudo apt install libnss3-tools

# 2 Download the pre-built binaries of mkcert and move it to /usr/local/bin or another directory in your $PATH.
# 注意amd64和arm64的区别
curl -JLO "https://dl.filippo.io/mkcert/latest?for=linux/amd64"
chmod +x mkcert-v*-linux-amd64
sudo cp mkcert-v*-linux-amd64 /usr/local/bin/mkcert