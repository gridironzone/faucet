FROM alpine:edge

ENV REPO_PATH   /faucet
ENV PACKAGES    go make git libc-dev bash
ENV GOPATH      /root/go
ENV PATH        $GOPATH/bin:$PATH
ENV IRIS_PATH   $GOPATH/src/github.com/irisnet

COPY . $REPO_PATH

RUN mkdir -p $IRIS_PATH &&\
    apk add --no-cache $PACKAGES python3-dev &&\
    go get github.com/golang/dep/cmd/dep &&\
    cd $IRIS_PATH &&\
    git clone https://github.com/irisnet/irishub.git &&\
    cd irishub && git checkout -b master origin/develop &&\
    dep ensure -vendor-only &&\
    make build_linux &&\
    mv build/* /usr/local/bin/ &&\
    cd $REPO_PATH &&\
    pip3 install -r requirements.txt &&\
    apk del $PACKAGES &&\
    rm -fr $GOPATH/src/

WORKDIR $REPO_PATH
EXPOSE 4000

CMD ["python3","main.py"]
