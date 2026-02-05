.PHONY: build install uninstall clean install-menu

BINARY_NAME := diginoise
MENU_BAR_NAME := DigiNoiseMenuBar
INSTALL_PATH := /usr/local/bin
BUILD_PATH := .build/release/$(BINARY_NAME)
MENU_BAR_PATH := .build/release/$(MENU_BAR_NAME).app

build:
	swift build -c release

install: build
	@echo "Installing $(BINARY_NAME) to $(INSTALL_PATH)..."
	@cp $(BUILD_PATH) $(INSTALL_PATH)/$(BINARY_NAME)
	@chmod +x $(INSTALL_PATH)/$(BINARY_NAME)
	@echo "Installing launchd service..."
	@$(INSTALL_PATH)/$(BINARY_NAME) install
	@echo "✅ CLI installation complete!"
	@echo "Run '$(BINARY_NAME) start' to begin generating noise"
	@echo ""
	@echo "To install the menu bar app, run: make install-menu"

install-menu: build
	@echo "Installing Menu Bar app..."
	@cp -R $(MENU_BAR_PATH) /Applications/
	@echo "✅ Menu Bar app installed to /Applications/$(MENU_BAR_NAME).app"
	@echo "Launch it from Applications or Spotlight"

uninstall:
	@echo "Uninstalling..."
	-$(INSTALL_PATH)/$(BINARY_NAME) uninstall 2>/dev/null || true
	@rm -f $(INSTALL_PATH)/$(BINARY_NAME)
	@rm -rf /Applications/$(MENU_BAR_NAME).app
	@echo "❌ Uninstalled"

clean:
	rm -rf .build
