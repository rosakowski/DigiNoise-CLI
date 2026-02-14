.PHONY: build install uninstall clean install-menu

BINARY_NAME := diginoise
MENU_BAR_NAME := DigiNoiseMenuBar
INSTALL_PATH := /usr/local/bin
BUILD_PATH := .build/release/$(BINARY_NAME)
MENU_BAR_BINARY := .build/release/$(MENU_BAR_NAME)
APP_PATH := /Applications/$(MENU_BAR_NAME).app

build:
	swift build -c release

install: build
	@echo "Installing $(BINARY_NAME) to $(INSTALL_PATH)..."
	@cp $(BUILD_PATH) $(INSTALL_PATH)/$(BINARY_NAME)
	@chmod +x $(INSTALL_PATH)/$(BINARY_NAME)
	@echo "Installing launchd service..."
	@$(INSTALL_PATH)/$(BINARY_NAME) install
	@echo ""
	@echo "Installing Menu Bar app..."
	@rm -rf $(APP_PATH)
	@mkdir -p $(APP_PATH)/Contents/MacOS
	@mkdir -p $(APP_PATH)/Contents/Resources
	@cp $(MENU_BAR_BINARY) $(APP_PATH)/Contents/MacOS/
	@chmod +x $(APP_PATH)/Contents/MacOS/$(MENU_BAR_NAME)
	@cp Sources/MenuBar/Resources/Info.plist $(APP_PATH)/Contents/
	@echo "✅ DigiNoise installed!"
	@echo ""
	@echo "🚀 Launching menu bar app..."
	@open $(APP_PATH)
	@sleep 1
	@echo ""
	@echo "You should see 📡 in your menu bar! Click it to control DigiNoise."

install-menu: build
	@echo "Installing Menu Bar app..."
	@rm -rf $(APP_PATH)
	@mkdir -p $(APP_PATH)/Contents/MacOS
	@mkdir -p $(APP_PATH)/Contents/Resources
	@cp $(MENU_BAR_BINARY) $(APP_PATH)/Contents/MacOS/
	@chmod +x $(APP_PATH)/Contents/MacOS/$(MENU_BAR_NAME)
	@cp Sources/MenuBar/Resources/Info.plist $(APP_PATH)/Contents/
	@echo "Menu bar app installed to $(APP_PATH)"
	@echo "Launch: open $(APP_PATH)"

uninstall:
	@echo "Uninstalling..."
	-$(INSTALL_PATH)/$(BINARY_NAME) uninstall 2>/dev/null || true
	@rm -f $(INSTALL_PATH)/$(BINARY_NAME)
	@rm -rf $(APP_PATH)
	@echo "❌ Uninstalled"

clean:
	rm -rf .build
