VERSION=1.18.3
OS=linux
ARCH=amd64

cd $HOME
wget https://storage.googleapis.com/golang/go$VERSION.$OS-$ARCH.tar.gz
tar -xvf go$VERSION.$OS-$ARCH.tar.gz
mv go go-$VERSION
sudo mv go-$VERSION /usr/local

echo "GOPATH=$HOME/projects/go" >> ~/.zshrc
echo "PATH=$PATH:$HOME/projects/go/bin" >> ~/.zshrc
echo "PATH=$PATH:/usr/local/go-$VERSION/bin" >> ~/.zshrc
