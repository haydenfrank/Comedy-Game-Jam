.SILENT:

# Target name and tools
TARGET := game.love
ZIP := zip
LOVE := love

.PHONY: all build run clean

all: build

build:
	@rm -f $(TARGET)
	@$(ZIP) -9 -r $(TARGET) main.lua conf.lua src gfx -x "*.git*" "*.DS_Store"
	@echo Built $(TARGET)

run: build
	@$(LOVE) $(TARGET)

clean:
	@rm -f $(TARGET)
	@echo Removed $(TARGET)
