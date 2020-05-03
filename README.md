rm -rf ~/Library/Developer/Xcode/DerivedData 
sudo xcode-select --switch /Applications/Xcode.app
xcode-select --print-path
carthage update --platform iOS
pod env
