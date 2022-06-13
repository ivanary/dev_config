!/usr/bin/env bash

# shellcheck disable=SC2006

# 项目名
project="ivanary"

# 版本文件路径
VerPath=./pkg/version

# 发布版本目录
Dist=./dist/${project}

# main文件
Main="cmd/main.go"

GitCommit=$(git rev-parse --short HEAD || echo unsupported)
Branch=$(git symbolic-ref --short -q HEAD)
GoVersion=$(go version)
BuildData=$(date "+%Y-%m-%d %H:%M:%S")
ReleaseTag=$(git describe --tags `git rev-list --tags --max-count=1`  2> /dev/null || echo "")
CurrentVersion=`cat VERSION`

VERSION=${CurrentVersion}
if [[ -n "${ReleaseTag}" ]]; then
  VERSION=${ReleaseTag}
fi

export GOPROXY="https://goproxy.cn,direct"

# GOOS=linux GOARCH=amd64
CGO_ENABLED=0 go build -mod=vendor -o $Dist -ldflags "-X $VerPath.Version=$CurrentVersion
                                -X '$VerPath.BuildDate=`date "+%Y-%m-%d %H:%M:%S"`'
                                -X $VerPath.Branch=$Branch
                                -X '$VerPath.GoVersion=`go version`'
                                -X $VerPath.GitCommit=$GitCommit
                                -X $VerPath.BuildUser='`whoami`@`hostname`'" ${Main}

if [ $? -ne 0 ]; then
    echo "build is failed"
else
    echo "build finish !!"
    echo "Build user:" `whoami`@`hostname`
    echo "Version:" $CurrentVersion
    echo "Go version:" $GoVersion
    echo "Git commit:" $GitCommit
    echo "Branch:" $Branch
    echo "Build data:" $BuildData
fi


