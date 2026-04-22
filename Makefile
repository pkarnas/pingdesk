APP_NAME = PingDesk
BUILD_DIR = .build/release
APP_BUNDLE = $(BUILD_DIR)/$(APP_NAME).app
CONTENTS_DIR = $(APP_BUNDLE)/Contents
MACOS_DIR = $(CONTENTS_DIR)/MacOS
RESOURCES_DIR = $(CONTENTS_DIR)/Resources

.PHONY: build bundle run install uninstall purge clean

build:
	swift build -c release

bundle: build
	mkdir -p $(MACOS_DIR) $(RESOURCES_DIR)
	cp $(BUILD_DIR)/$(APP_NAME) $(MACOS_DIR)/$(APP_NAME)
	cp Resources/Info.plist $(CONTENTS_DIR)/Info.plist
	cp Resources/PingDesk.icns $(RESOURCES_DIR)/PingDesk.icns
	codesign --force --sign - \
	    --entitlements Resources/PingDesk.entitlements \
	    $(APP_BUNDLE)

run: bundle
	open $(APP_BUNDLE)

install: bundle
	rm -rf /Applications/$(APP_NAME).app
	cp -R $(APP_BUNDLE) /Applications/$(APP_NAME).app

uninstall:
	pkill -x $(APP_NAME) 2>/dev/null || true
	rm -rf /Applications/$(APP_NAME).app

purge: uninstall
	rm -rf ~/Library/Application\ Support/$(APP_NAME)

clean:
	swift package clean
	rm -rf $(APP_BUNDLE)
