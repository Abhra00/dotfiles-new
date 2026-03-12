#!/usr/bin/env python3

import subprocess

import gi

gi.require_version("Gtk", "3.0")
gi.require_version("AppIndicator3", "0.1")

from gi.repository import (  # type: ignore # noqa: E402
    AppIndicator3,
    GdkPixbuf,
    GLib,
    Gtk,
)

APP_ID = "bluetooth-tray"
ICON_PATH = "/home/bugs/.local/share/bt_icons"

# enable menu icons
Gtk.Settings.get_default().set_property("gtk-menu-images", True)


# ── helpers ─────────────────────────────────────────────


def run(cmd):
    return subprocess.run(cmd, capture_output=True, text=True).stdout.strip()


def bluetooth_power():
    return "Powered: yes" in run(["bluetoothctl", "show"])


def connected_device():
    lines = run(["bluetoothctl", "devices", "Connected"]).splitlines()
    for line in lines:
        parts = line.split(" ", 2)
        if len(parts) == 3:
            return parts[1], parts[2]
    return None, None


def device_battery(mac):
    if not mac:
        return None
    info = run(["bluetoothctl", "info", mac])
    for line in info.splitlines():
        if "Battery Percentage" in line:
            return line.split("(")[1].split(")")[0]
    return None


# ── battery icon ────────────────────────────────────────


def battery_icon(level):
    try:
        level = int(level)
    except (ValueError, TypeError):
        return "🔋"

    if level > 90:
        return "󰁹"
    if level > 70:
        return "󰂀"
    if level > 50:
        return "󰁾"
    if level > 30:
        return "󰁽"
    if level > 10:
        return "󰁻"
    return "󰁺"


# ── icon loader ─────────────────────────────────────────


def load_icon(path):
    try:
        pixbuf = GdkPixbuf.Pixbuf.new_from_file_at_size(path, 16, 16)
        return Gtk.Image.new_from_pixbuf(pixbuf)
    except Exception:
        return Gtk.Image.new_from_icon_name("image-missing", Gtk.IconSize.MENU)


# ── menu item builder ───────────────────────────────────


def styled_item(label, icon_file, sensitive=True):
    item = Gtk.MenuItem()
    box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)

    icon = load_icon(f"{ICON_PATH}/{icon_file}")
    text = Gtk.Label(label=label)
    text.set_xalign(0)

    box.pack_start(icon, False, False, 0)
    box.pack_start(text, True, True, 0)

    item.add(box)
    item.set_sensitive(sensitive)
    item._label = text
    item._icon = icon

    return item


def update_icon(item, icon_file):
    try:
        pixbuf = GdkPixbuf.Pixbuf.new_from_file_at_size(
            f"{ICON_PATH}/{icon_file}", 16, 16
        )
        item._icon.set_from_pixbuf(pixbuf)
    except Exception:
        pass


# ── callbacks ───────────────────────────────────────────


def toggle_power(_):
    cmd = "off" if bluetooth_power() else "on"
    subprocess.Popen(["bluetoothctl", "power", cmd])
    GLib.timeout_add(1200, update)


def open_bluetui(_):
    subprocess.Popen(
        [
            "hyprctl",
            "dispatch",
            "exec",
            "[float;center;size 1100 800] ghostty -e bluetui",
        ]
    )


# ── update loop ─────────────────────────────────────────


def update(_=None):
    powered = bluetooth_power()
    mac, device = connected_device()
    battery = device_battery(mac)

    # ── tray icon + tooltip ──────────────────────────────

    if powered:
        indicator.set_icon_full(f"{ICON_PATH}/bt_on.svg", "Bluetooth")
    else:
        indicator.set_icon_full(f"{ICON_PATH}/bt_off.svg", "Bluetooth")

    if device:
        title = f"{device} [{battery_icon(battery)} {battery}%]" if battery else device
    elif not powered:
        title = "Bluetooth Off"
    else:
        title = "No device connected"
    indicator.set_title(title)

    # ── device row ───────────────────────────────────────

    if not powered:
        # BT is off — communicate that clearly
        device_item._label.set_text("Bluetooth Off")
        update_icon(device_item, "bt_off.svg")

    elif device:
        label = f"{device} [{battery_icon(battery)} {battery}%]" if battery else device
        device_item._label.set_text(label)
        update_icon(device_item, "bt_on.svg")

    else:
        # BT on but nothing paired/connected
        device_item._label.set_text("No device connected")
        update_icon(device_item, "bt_off.svg")

    # ── power toggle label ───────────────────────────────

    if powered:
        power_item._label.set_text("Turn Off Bluetooth")
        update_icon(power_item, "bt_off.svg")
    else:
        power_item._label.set_text("Turn On Bluetooth")
        update_icon(power_item, "bt_on.svg")

    return True  # keep GLib timer alive


# ── tray indicator ──────────────────────────────────────


indicator = AppIndicator3.Indicator.new(
    APP_ID,
    f"{ICON_PATH}/bt_on.svg",
    AppIndicator3.IndicatorCategory.SYSTEM_SERVICES,
)
indicator.set_status(AppIndicator3.IndicatorStatus.ACTIVE)

menu = Gtk.Menu()

header_item = styled_item("Bluetooth", "bt_on.svg", sensitive=False)
menu.append(header_item)

menu.append(Gtk.SeparatorMenuItem())

device_item = styled_item("Loading...", "bt_off.svg", sensitive=False)
menu.append(device_item)

menu.append(Gtk.SeparatorMenuItem())

power_item = styled_item("Toggle Bluetooth", "bt_on.svg")
power_item.connect("activate", toggle_power)
menu.append(power_item)

open_item = styled_item("Open Bluetui", "term.svg")
open_item.connect("activate", open_bluetui)
menu.append(open_item)

menu.append(Gtk.SeparatorMenuItem())

quit_item = styled_item("Quit", "quit.svg")
quit_item.connect("activate", lambda _: Gtk.main_quit())
menu.append(quit_item)

menu.show_all()
indicator.set_menu(menu)


# ── run ─────────────────────────────────────────────────


GLib.timeout_add_seconds(5, update)
update()

Gtk.main()
