#    ┏┓┏┳┓┳┓ ┏┓
#    ┃┃ ┃ ┃┃ ┣
#    ┗┻ ┻ ┻┗┛┗┛
#
#-------- A qtile config by bugs ---------#

#---------------------- Import needed libraries ----------------------#
import os
import subprocess
import threading
from libqtile import bar, extension, hook, layout, qtile, widget
from libqtile.config import Click, Drag, Group, Key, Match, Screen, ScratchPad, DropDown
from libqtile.lazy import lazy

#---------------------- Define programs ----------------------#
mod         = "mod4"                       # Sets mod key to SUPER/WINDOWS
alt         = "mod1"                       # Sets the alt key to left-alt key
myTerm      = "ghostty"                    # My terminal of choice
myBrowser   = "chromium"                   # My browser of choice
myEditor    = "ghostty -e nvim"            # My editor of choice
myLauncher  = "rofi -show drun"            # My launcher of choice

#---------------------- Define useful functions ----------------------#

# Allows you to input a name when adding treetab section.
@lazy.layout.function
def add_treetab_section(layout):
    prompt = qtile.widgets_map["prompt"]
    prompt.start_input("Section name: ", layout.cmd_add_section)

# A function for hide/show all the windows in a group
@lazy.function
def minimize_all(qtile):
    for win in qtile.current_group.windows:
        if hasattr(win, "toggle_minimize"):
            win.toggle_minimize()

# A function for toggling between MAX and MONADTALL layouts
@lazy.function
def maximize_by_switching_layout(qtile):
    current_layout_name = qtile.current_group.layout.name
    if current_layout_name == 'monadtall':
        qtile.current_group.layout = 'max'
    elif current_layout_name == 'max':
        qtile.current_group.layout = 'monadtall'

# Run paru in a background thread, then refresh the updates widget
def run_paru_and_refresh(qtile):
    def task():
        # run update in a blocking way, but inside a THREAD
        subprocess.run([myTerm, "-e", "yay"])

        # refresh widget
        try:
            qtile.widgets_map["updates"].timer_setup()
        except KeyError:
            pass

    threading.Thread(target=task, daemon=True).start()

#---------------------- Define keybinds ----------------------#
keys = [
    # The essentials
    Key([mod], "Return", lazy.spawn(myTerm), desc="Terminal"),
    Key([mod], "d", lazy.spawn(myLauncher), desc='Run Launcher'),
    Key([mod], "w", lazy.spawn(myBrowser), desc='Web browser'),
    Key([mod], "e", lazy.spawn(myEditor), desc='Text editor'),
    Key([mod], "b", lazy.hide_show_bar(position='all'), desc="Toggles the bar to show/hide"),
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    Key([mod], "q", lazy.window.kill(), desc="Kill focused window"),
    Key([mod, "shift"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod], "semicolon", lazy.spawn("rofiunicode"), desc="Rofi emoji menu"),
    Key([mod], "f1", lazy.spawn("mounter"), desc="Drive mounter menu"),
    Key([mod], "f2", lazy.spawn("unmounter"), desc="Drive umounter menu"),
    Key([mod], "f3", lazy.spawn("wallpapermenu"), desc="Rofi wallpaper menu"),
    Key([mod], "f4", lazy.spawn("dunst_action_menu"), desc="Rofi dunst action menu applet"),
    Key([], "Print", lazy.spawn("maimshot"), desc="Screenshot menu"),
    Key([mod, alt], "x", lazy.spawn("pmenu"), desc="Logout menu"),
    Key([mod], "r", lazy.spawncmd(), desc="Spawn a command using a prompt widget"),

    # Window management
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "space", lazy.layout.next(), desc="Move window focus to other window"),

    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    Key([mod, "shift"], "h",
        lazy.layout.shuffle_left(),
        lazy.layout.move_left().when(layout=["treetab"]),
        desc="Move window to the left/move tab left in treetab"),

    Key([mod, "shift"], "l",
        lazy.layout.shuffle_right(),
        lazy.layout.move_right().when(layout=["treetab"]),
        desc="Move window to the right/move tab right in treetab"),

    Key([mod, "shift"], "j",
        lazy.layout.shuffle_down(),
        lazy.layout.section_down().when(layout=["treetab"]),
        desc="Move window down/move down a section in treetab"
    ),
    Key([mod, "shift"], "k",
        lazy.layout.shuffle_up(),
        lazy.layout.section_up().when(layout=["treetab"]),
        desc="Move window downup/move up a section in treetab"
    ),

    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key([mod, "shift"], "space", lazy.layout.toggle_split(), desc="Toggle between split and unsplit sides of stack"),

    # Treetab prompt
    Key([mod, "shift"], "a", add_treetab_section, desc='Prompt to add new section in treetab'),

    # Grow/shrink windows left/right.
    # This is mainly for the 'monadtall' and 'monadwide' layouts
    # although it does also work in the 'bsp' and 'columns' layouts.
    Key([mod], "equal",
        lazy.layout.grow_left().when(layout=["bsp", "columns"]),
        lazy.layout.grow().when(layout=["monadtall", "monadwide"]),
        desc="Grow window to the left"
    ),
    Key([mod], "minus",
        lazy.layout.grow_right().when(layout=["bsp", "columns"]),
        lazy.layout.shrink().when(layout=["monadtall", "monadwide"]),
        desc="Grow window to the left"
    ),

    # Grow windows up, down, left, right.  Only works in certain layouts.
    # Works in 'bsp' and 'columns' layout.
    Key([mod, "control"], "h", lazy.layout.grow_left(), desc="Grow window to the left"),
    Key([mod, "control"], "l", lazy.layout.grow_right(), desc="Grow window to the right"),
    Key([mod, "control"], "j", lazy.layout.grow_down(), desc="Grow window down"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow window up"),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),
    Key([mod], "m", lazy.layout.maximize(), desc='Toggle between min and max sizes'),
    Key([mod], "t", lazy.window.toggle_floating(), desc='toggle floating'),
    Key([mod], "f", maximize_by_switching_layout(), lazy.window.toggle_fullscreen(), desc='toggle fullscreen'),
    Key([mod, "shift"], "m", minimize_all(), desc="Toggle hide/show all windows on current group"),

    # Switch focus of monitors
    Key([mod], "period", lazy.next_screen(), desc='Move focus to next monitor'),
    Key([mod], "comma", lazy.prev_screen(), desc='Move focus to prev monitor'),

    # Scratchpad's bind
    Key(["control"], "1", lazy.group['SPTERM'].dropdown_toggle('Term')),
    Key(["control"], "2", lazy.group['SPCALC'].dropdown_toggle('Calculator')),
    Key(["control"], "3", lazy.group['SPWALL'].dropdown_toggle('WallSelector')),
    Key(["control"], "4", lazy.group['SPFM'].dropdown_toggle('FileManager')),


    # Volume & brightness controls
    Key([], "XF86AudioRaiseVolume", lazy.spawn("volume up"), desc="Increase volume"),
    Key([], "XF86AudioLowerVolume", lazy.spawn("volume down"), desc="Decrease volume"),
    Key([], "XF86AudioMute", lazy.spawn("volume mute"), desc="Toggle mute"),
    Key([], "XF86MonBrightnessUp", lazy.spawn("backlight up"), desc="Increase brightness"),
    Key([], "XF86MonBrightnessDown", lazy.spawn("backlight down"), desc="Decrease brightness"),
]

#---------------------- Groups ----------------------#

# Group properties
groups = []
group_names = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
group_labels = ["", "", "", "", "", "", "", "", "", ""]
group_layouts = ["monadtall", "monadtall", "monadtall", "monadtall", "monadtall", "monadtall", "monadtall", "monadtall", "monadtall", "monadtall"]

# Add regular groups
for i in range(len(group_names)):
    groups.append(
        Group(
            name=group_names[i],
            layout=group_layouts[i].lower(),
            label=group_labels[i],
        )
    )

# Add scratchpads separately (outside the loop since they're not tied to each group)
groups.extend([
    ScratchPad("SPWALL", [DropDown("WallSelector", "nsxiv /home/bugs/walls/", x=0.25, y=0.05, width=0.5, height=0.7, on_focus_lost_hide=False)]),
    ScratchPad("SPFM", [DropDown("FileManager", "ghostty -e yazi", x=0.2, y=0.02, width=0.55, height=0.75, on_focus_lost_hide=False)]),
    ScratchPad("SPCALC", [DropDown("Calculator", "ghostty -e bc", x=0.2, y=0.02, width=0.50, height=0.50, on_focus_lost_hide=False)]),
    ScratchPad("SPTERM", [DropDown("Term", "ghostty -e zsh", x=0.2, y=0.02, width=0.50, height=0.50, on_focus_lost_hide=False)]),
])

# Only bind keys for regular groups (not scratchpads)
for i in group_names:
    keys.extend(
        [
            Key(
                [mod],
                i,
                lazy.group[i].toscreen(),
                desc="Switch to group {}".format(i),
            ),
            Key(
                [mod, "shift"],
                i,
                lazy.window.togroup(i, switch_group=False),
                desc="Move focused window to group {}".format(i),
            ),
        ]
    )

#---------------------- Layout management ----------------------#
layout_theme = { "border_width": 2,
                 "margin": 10,
                 "border_focus": "#7DCFFF",
                 "border_normal": "#292E42"
                }

layouts = [
    layout.MonadTall(**layout_theme),
    layout.Tile(**layout_theme),
    layout.Max(**layout_theme),
    layout.Bsp(**layout_theme),
    #layout.Floating(**layout_theme)
    #layout.MonadWide(**layout_theme),
    #layout.RatioTile(**layout_theme),
    #layout.VerticalTile(**layout_theme),
    #layout.Matrix(**layout_theme),
    #layout.Stack(**layout_theme, num_stacks=2),
    #layout.Columns(**layout_theme),
    #layout.TreeTab(
    #     font = "GeistMonoNerdFontPropo",
    #     fontsize = 11,
    #     border_width = 0,
    #     bg_color = "#1A1B26",
    #     active_bg = "#FF9E64",
    #     active_fg = "#1A1B26",
    #     inactive_bg = "#292E42",
    #     inactive_fg = "#C0CAF5",
    #     padding_left = 8,
    #     padding_x = 8,
    #     padding_y = 6,
    #     sections = ["ONE", "TWO", "THREE"],
    #     section_fontsize = 10,
    #     section_fg = "#1ABC9C",
    #     section_top = 15,
    #     section_bottom = 15,
    #     level_shift = 8,
    #     vspace = 3,
    #     panel_width = 240
    #     ),
    #layout.Zoomy(**layout_theme),
]



#---------------------- Widgets ----------------------#
widget_defaults = dict(
    font="GeistMonoNerdFontPropo Bold",
    fontsize=14,
    padding=0,
    background="#1A1B26",
)

extension_defaults = widget_defaults.copy()

def init_widgets_list():
    widgets_list = [
        widget.Spacer(
            length=15,
            background='#1A1B26',
        ),
        widget.Image(
            filename='~/.config/qtile/assets/launcher_icon.png',
            margin = 2,
            background='#1A1B26',
            mouse_callbacks={'Button1': lambda: qtile.cmd_spawn('pmenu')},
        ),
        widget.Image(
            filename='~/.config/qtile/assets/curve_right.png',
        ),
        widget.GroupBox(
            font="Symbols Nerd Font",
            fontsize=24,
            borderwidth=3,
            highlight_method='block',
            active='#FF9E64',
            block_highlight_text_color="#BB9AF7",
            highlight_color='#7AA2F7',
            inactive='#1A1B26',
            foreground='#C0CAF5',
            background='#292E42',
            this_current_screen_border='#292E42',
            this_screen_border='#292E42',
            other_current_screen_border='#292E42',
            other_screen_border='#292E42',
            urgent_border='#292E42',
            rounded=True,
            disable_drag=True,
        ),
        widget.Spacer(
            length=8,
            background='#292E42',
        ),
        widget.Image(
            filename='~/.config/qtile/assets/slant_right.png',
        ),
        widget.CurrentLayout(
            mode = 'icon',
            custom_icon_paths=["~/.config/qtile/assets/layout"],
            background='#292E42',
            scale=0.50,
        ),
        widget.Spacer(
            length=4,
            background='#292E42',
        ),
        widget.CurrentLayout(
            mode='text',
            fontsize = 14,
            background='#292E42',
            foreground='#9D7CD8',
        ),
        widget.Image(
            filename='~/.config/qtile/assets/curve_left.png',
        ),
        widget.TextBox(
            text=" ",
            font="Symbols Nerd Font",
            fontsize=20,
            background='#1A1B26',
            foreground='#1ABC9C',
            mouse_callbacks={'Button1': lambda: qtile.cmd_spawn(myLauncher)},
        ),
        widget.TextBox(
            fmt='Search',
            background='#1A1B26',
            font="GeistMono Nerd Font Propo Bold",
            fontsize=14,
            foreground='#1ABC9C',
            mouse_callbacks={'Button1': lambda: qtile.cmd_spawn(myLauncher)},
        ),
        widget.Image(
            filename='~/.config/qtile/assets/right_half_circle.png',
        ),
        widget.WindowName(
            font="GeistMono Nerd Font Propo Bold",
            fontsize=14,
            empty_group_string="Desktop",
            max_chars=130,
            background='#292E42',
            foreground='#7DCFFF',
        ),
        widget.Image(
            filename='~/.config/qtile/assets/left_half_circle.png',
        ),
        widget.Systray(
            background='#1A1B26',
            fontsize=2,
        ),
        widget.TextBox(
            text=' ',
            background='#1A1B26',
        ),
        widget.Image(
            filename='~/.config/qtile/assets/curve_right.png',
            background='#292E42',
        ),
        widget.TextBox(
            text="󰛀 ",
            font="Symbols Nerd Font",
            fontsize=20,
            background='#292E42',
            foreground='#FF9E64',
            mouse_callbacks = {
                'Button1': lazy.function(run_paru_and_refresh)
            },
        ),
        widget.GenPollText(
            name = 'updates',
            func = lambda: subprocess.check_output(['pacupdates']).decode('utf-8').strip(),
            update_interval = 3600,
            background='#292E42',
            foreground='#7AA2F7',
            padding = 2,
            mouse_callbacks = {
                'Button1': lazy.function(run_paru_and_refresh)
            },
        ),
        widget.Image(
            filename='~/.config/qtile/assets/slant_left.png',
        ),
        widget.TextBox(
            text="󰘚",
            font="Symbols Nerd Font",
            fontsize=20,
            background='#292E42',
            foreground='#FF9E64',
        ),
        widget.Memory(
            background='#292E42',
            format='{MemUsed: .0f}{mm}',
            foreground='#7AA2F7',
            font="GeistMono Nerd Font Propo Bold",
            fontsize=14,
            update_interval=5,
        ),
        widget.Image(
            filename='~/.config/qtile/assets/slant_left.png',
        ),
        widget.Spacer(
            length=8,
            background='#292E42',
        ),
        widget.TextBox(
            text="󰁹",
            font="Symbols Nerd Font",
            fontsize=20,
            background='#292E42',
            foreground='#FF9E64',
        ),
        widget.Battery(
            font="GeistMono Nerd Font Propo Bold",
            format='{percent: 2.0%} {char}',
            discharge_char='',
            empty_char='󰈿',
            charge_char='',
            full_char='󰉁',
            not_charging_char='',
            fontsize=14,
            background='#292E42',
            foreground='#7AA2F7',
            charging_foreground='#73DACA',
            low_foreground='#DB4B4B',
            notify_below=17,
            notification_timeout=0
        ),
        widget.Image(
            filename='~/.config/qtile/assets/slant_left.png',
        ),
        widget.Spacer(
            length=8,
            background='#292E42',
        ),
        widget.TextBox(
            text="",
            font="Symbols Nerd Font",
            fontsize=20,
            background='#292E42',
            foreground='#FF9E64',
        ),
        widget.Volume(
            font="GeistMono Nerd Font Propo Bold",
            fontsize=14,
            background='#292E42',
            foreground='#7AA2F7',
            unmute_format=" {volume}%",
            mute_format="M",
        ),
        widget.Image(
            filename='~/.config/qtile/assets/slant_left.png',
            background='#292E42',
        ),
        widget.TextBox(
            text=" ",
            font="Symbols Nerd Font",
            fontsize=20,
            background='#292E42',
            foreground='#FF9E64',
            mouse_callbacks = {
                'Button1': lambda: qtile.cmd_spawn('notify-date')
            },
        ),
        widget.Clock(
            format='%I:%M %p',
            background='#292E42',
            foreground='#7AA2F7',
            font="GeistMono Nerd Font Propo Bold",
            fontsize=14,
            mouse_callbacks = {
                'Button1': lambda: qtile.cmd_spawn('notify-date')
            },
        ),
        widget.Spacer(
            length=18,
            background='#292E42',
        ),
    ]
    return widgets_list

def init_widgets_screen1():
    widgets_screen1 = init_widgets_list()
    return widgets_screen1


def init_screens():
    return [Screen(top=bar.Bar(widgets=init_widgets_screen1(), margin=[8, 12, 0, 12], size=44))]

screens = init_screens()

#---------------------- Mouse binds ----------------------#
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]


#---------------------- Misc settings & floating layout ----------------------#
dgroups_key_binder = None
dgroups_app_rules = []  # type: list
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False
floating_layout=layout.Floating(
    border_focus="#FF9E64",
    border_width=2,
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),   # gitk
        Match(wm_class="dialog"),         # dialog boxes
        Match(wm_class="download"),       # downloads
        Match(wm_class="error"),          # error msgs
        Match(wm_class="file_progress"),  # file progress boxes
        Match(wm_class='kdenlive'),       # kdenlive
        Match(wm_class="makebranch"),     # gitk
        Match(wm_class="maketag"),        # gitk
        Match(wm_class="notification"),   # notifications
        Match(wm_class='pinentry-gtk-2'), # GPG key password entry
        Match(wm_class="ssh-askpass"),    # ssh-askpass
        Match(wm_class="toolbar"),        # toolbars
        Match(wm_class="Yad"),            # yad boxes
        Match(title="branchdialog"),      # gitk
        Match(title='Confirmation'),      # tastyworks exit box
        Match(title='Qalculate!'),        # qalculate-gtk
        Match(title="pinentry"),          # GPG key password entry
        Match(title="tastycharts"),       # tastytrade pop-out charts
        Match(title="tastytrade"),        # tastytrade pop-out side gutter
        Match(title="tastytrade - Portfolio Report"), # tastytrade pop-out allocation
        Match(wm_class="tasty.javafx.launcher.LauncherFxApp"), # tastytrade settings
    ]
)
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True

# When using the Wayland backend, this can be used to configure input devices.
wl_input_rules = None

@hook.subscribe.startup_once
def start_once():
    home = os.path.expanduser('~')
    subprocess.call([home + '/.config/qtile/autostart.sh'])

# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"
