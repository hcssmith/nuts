
# systemd user unit install location
SYSTEMD_USER_DIR := $(HOME)/.config/systemd/user

# Find all unit files in this directory
UNITS := $(wildcard *.service *.socket *.target *.timer *.path)
ENABLE_UNITS := graphical-session.target

.PHONY: all install uninstall reload enable disable list

all: install reload

install:
	@echo "Installing systemd user units..."
	@mkdir -p "$(SYSTEMD_USER_DIR)"
	@for unit in $(UNITS); do \
		echo "  -> $$unit"; \
		install -m 0644 "$$unit" "$(SYSTEMD_USER_DIR)/$$unit"; \
	done

uninstall:
	@echo "Removing systemd user units..."
	@for unit in $(UNITS); do \
		echo "  -> $$unit"; \
		rm -f "$(SYSTEMD_USER_DIR)/$$unit"; \
	done
	@$(MAKE) reload

reload:
	@echo "Reloading systemd user daemon..."
	@systemctl --user daemon-reexec
	@systemctl --user daemon-reload

enable:
	@echo "Enabling systemd user units..."
	@for unit in $(ENABLE_UNITS); do \
		systemctl --user enable "$$unit"; \
	done

disable:
	@echo "Disabling systemd user units..."
	@for unit in $(UNITS); do \
		echo "  -> $$unit"; \
		systemctl --user disable "$$unit"; \
	done

list:
	@echo "Units in this directory:"
	@for unit in $(UNITS); do \
		echo "  - $$unit"; \
	done
