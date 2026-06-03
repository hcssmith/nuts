
# systemd unit install locations
SYSTEMD_USER_DIR := $(HOME)/.config/systemd/user
SYSTEMD_SYSTEM_DIR := /etc/systemd/system

# User units
UNITS := $(wildcard *.service *.socket *.target *.timer *.path)
SCRIPTS := x11-launch
ENABLE_UNITS := graphical-session.target dwm x11 dunst picom wallpaper wallpaper.timer dmenu-cache-clear statusbar slock

LOCAL_BIN := $(HOME)/.local/bin

# System units (need sudo)
SYSTEM_UNITS := slock-suspend.service

.PHONY: all install uninstall reload enable disable list

all: install reload

install: install-user install-scripts install-system

install-user:
	@echo "Installing systemd user units..."
	@mkdir -p "$(SYSTEMD_USER_DIR)"
	@for unit in $(UNITS); do \
		echo "  -> $$unit"; \
		install -m 0644 "$$unit" "$(SYSTEMD_USER_DIR)/$$unit"; \
	done

install-scripts:
	@echo "Installing helper scripts..."
	@mkdir -p "$(LOCAL_BIN)"
	@for script in $(SCRIPTS); do \
		echo "  -> $$script"; \
		install -m 0755 "$$script" "$(LOCAL_BIN)/$$script"; \
	done

install-system:
	@echo "Installing systemd system units (requires sudo)..."
	@sed 's/REPLACE_ME/$(USER)/g' slock-suspend.service | sudo tee "$(SYSTEMD_SYSTEM_DIR)/slock-suspend.service" > /dev/null
	@sudo chmod 0644 "$(SYSTEMD_SYSTEM_DIR)/slock-suspend.service"

uninstall: uninstall-user uninstall-scripts uninstall-system

uninstall-user:
	@echo "Removing systemd user units..."
	@for unit in $(UNITS); do \
		echo "  -> $$unit"; \
		rm -f "$(SYSTEMD_USER_DIR)/$$unit"; \
	done
	@$(MAKE) reload

uninstall-scripts:
	@echo "Removing helper scripts..."
	@for script in $(SCRIPTS); do \
		echo "  -> $$script"; \
		rm -f "$(LOCAL_BIN)/$$script"; \
	done

uninstall-system:
	@echo "Removing systemd system units (requires sudo)..."
	@sudo rm -f "$(SYSTEMD_SYSTEM_DIR)/slock-suspend.service"
	@sudo systemctl daemon-reload

reload:
	@echo "Reloading systemd daemons..."
	@systemctl --user daemon-reexec
	@systemctl --user daemon-reload
	@sudo systemctl daemon-reload

enable:
	@echo "Enabling systemd user units..."
	@for unit in $(ENABLE_UNITS); do \
		systemctl --user enable "$$unit"; \
	done
	@echo "Enabling systemd system units (requires sudo)..."
	@sudo systemctl enable slock-suspend.service

disable:
	@echo "Disabling systemd user units..."
	@for unit in $(UNITS); do \
		echo "  -> $$unit"; \
		systemctl --user disable "$$unit"; \
	done
	@echo "Disabling systemd system units (requires sudo)..."
	@sudo systemctl disable slock-suspend.service

list:
	@echo "Units in this directory:"
	@for unit in $(UNITS); do \
		echo "  - $$unit"; \
	done
