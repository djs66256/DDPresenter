#!/bin/sh

if [ -d ~/Library/Developer/Xcode/Templates/Project\ Templates/DDPresenter ]; then
    rm -rf ~/Library/Developer/Xcode/Templates/Project\ Templates/DDPresenter
fi

mkdir -p ~/Library/Developer/Xcode/Templates/Project\ Templates/DDPresenter/
cp -r ./Templates/* ~/Library/Developer/Xcode/Templates/Project\ Templates/DDPresenter
