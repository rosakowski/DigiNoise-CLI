.PHONY: build install uninstall clean

BINARY_NAME := diginoise
INSTALL_PATH := /usr/local/bin
BUILD_PATH := .build/release/$(BINARY_NAME)

build:
	swift build -c release

install: build
	@echo "Installing $(BINARY_NAME) to $(INSTALL_PATH)..."
	@cp $(BUILD_PATH) $(INSTALL_PATH)/$(BINARY_NAME)
	@chmod +x $(INSTALL_PATH)/$(BINARY_NAME)
	@echo "Installing launchd service..."
	@$(INSTALL_PATH)/$(BINARY_NAME) install
	@echo "✅ Installation complete!"
	@echo "Run '$(BINARY_NAME) start' to begin generating noise"

uninstall:
	@echo "Uninstalling..."
	-@$(INSTALL_PATH)/$(BINARY_NAME) uninstall 2>/dev/null || true
	@rm -f $(INSTALL_PATH)/$(BINARY_NAME)
	@echo "❌ Uninstalled"

clean:
	rm -rf .build
