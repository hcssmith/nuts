
# systemd unit install locations
SYSTEMD_USER_DIR := $(HOME)/.config/systemd/user
SYSTEMD_SYSTEM_DIR := /etc/systemd/system

# User units
UNITS := $(wildcard *.service *.socket *.target *.timer *.path)
ENABLE_UNITS := graphical-session.target dwm x11 dunst picom wallpaper wallpaper.timer dmenu-cache-clear statusbar slock

# System units (need sudo)
SYSTEM_UNITS := slock-suspend.service

.PHONY: all install uninstall reload enable disable list

all: install reload

install: install-user install-system

install-user:
	@echo "Installing systemd user units..."
	@mkdir -p "$(SYSTEMD_USER_DIR)"
	@for unit in $(UNITS); do \
		echo "  -> $$unit"; \
		install -m 0644 "$$unit" "$(SYSTEMD_USER_DIR)/$$unit"; \
	done

install-system:
	@echo "Installing systemd system units (requires sudo)..."
	@sed 's/REPLACE_ME/$(USER)/g' slock-suspend.service | sudo tee "$(SYSTEMD_SYSTEM_DIR)/slock-suspend.service" > /dev/null
	@sudo chmod 0644 "$(SYSTEMD_SYSTEM_DIR)/slock-suspend.service"

uninstall: uninstall-user uninstall-system

uninstall-user:
	@echo "Removing systemd user units..."
	@for unit in $(UNITS); do \
		echo "  -> $$unit"; \
		rm -f "$(SYSTEMD_USER_DIR)/$$unit"; \
	done
	@$(MAKE) reload

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
