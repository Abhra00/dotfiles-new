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
import colors

#---------------------- Define programs ----------------------#
mod         = "mod4"            # Sets mod key to SUPER/WINDOWS
alt         = "mod1"            # Sets the alt key to left-alt key
myTerm      = "ghostty"         # My terminal of choice
myBrowser   = "firefox"         # My browser of choice
myEditor    = "emacsclient"     # My editor of choice
myLauncher  = "rofi -show drun" # My launcher of choice

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
        subprocess.run([myTerm, "-e", "paru"])

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
group_labels = ["dev", "sys", "www", "doc", "vbox", "chat", "mus", "vid", "gfx", "misc"]
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

#---------------------- Select colors ----------------------#
colors = colors.Palenight


#---------------------- Layout management ----------------------#
layout_theme = { "border_width": 1,
                 "margin": 10,
                 "border_focus": colors[5],
                 "border_normal": colors[0]
                }

layouts = [
    layout.MonadTall(**layout_theme),
    layout.MonadWide(**layout_theme),
    layout.Tile(**layout_theme),
    layout.Max(**layout_theme),
    #layout.Bsp(**layout_theme),
    #layout.Floating(**layout_theme)
    #layout.RatioTile(**layout_theme),
    #layout.VerticalTile(**layout_theme),
    #layout.Matrix(**layout_theme),
    #layout.Stack(**layout_theme, num_stacks=2),
    #layout.Columns(**layout_theme),
    #layout.TreeTab(
    #     font = "IosevkaNerdFontPropo",
    #     fontsize = 11,
    #     border_width = 0,
    #     bg_color = colors[0],
    #     active_bg = colors[8],
    #     active_fg = colors[2],
    #     inactive_bg = colors[1],
    #     inactive_fg = colors[0],
    #     padding_left = 8,
    #     padding_x = 8,
    #     padding_y = 6,
    #     sections = ["ONE", "TWO", "THREE"],
    #     section_fontsize = 10,
    #     section_fg = colors[7],
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
    font="IosevkaNerdFontPropo",
    fontsize = 12,
    padding = 0,
    background=colors[0]
)

extension_defaults = widget_defaults.copy()

def init_widgets_list():
    widgets_list = [
        widget.Spacer(length = 8),
        widget.TextBox(
                 fmt = ' ',
                 fontsize = 35,
                 foreground = colors[6],
                 mouse_callbacks = {'Button1': lambda: qtile.cmd_spawn("emacs")},
                 ),
        widget.Prompt(
                 font = "IosevkaNerdFontPropo",
                 fontsize=14,
                 foreground = colors[5]
        ),
        widget.GroupBox(
                 fontsize = 12,
                 margin_y = 5,
                 margin_x = 14,
                 padding_y = 0,
                 padding_x = 2,
                 borderwidth = 3,
                 active = colors[1],
                 inactive = colors[9],
                 rounded = False,
                 hide_unused = True,
                 highlight_color = colors[0],
                 highlight_method = "line",
                 this_current_screen_border = colors[4],
                 this_screen_border = colors [4],
                 other_current_screen_border = colors[1],
                 other_screen_border = colors[1],
                 ),
        widget.TextBox(
                 text = '|',
                 font = "IosevkaNerdFontPropo",
                 foreground = colors[1],
                 padding = 2,
                 fontsize = 14
                 ),
        widget.LaunchBar(
                 progs = [("🦊", "firefox", "Firefox web browser"),
                          ("👻", "ghostty", "Ghostty terminal"),
                          ("📁", "thunar", "Thunar file manager"),
                          ("🎦", "obs", "Video Recorder")
                         ],
                 fontsize = 12,
                 padding = 6,
                 foreground = colors[3],
                 ),
        widget.TextBox(
                 text = '|',
                 font = "IosevkaNerdFontPropo",
                 foreground = colors[1],
                 padding = 2,
                 fontsize = 14
                 ),
        widget.CurrentLayout(
                 foreground = colors[1],
                 padding = 5
                 ),
        widget.TextBox(
                 text = '|',
                 font = "IosevkaNerdFontPropo",
                 foreground = colors[1],
                 padding = 2,
                 fontsize = 14
                 ),
        widget.WindowName(
                 foreground = colors[6],
                 padding = 8,
                 max_chars = 40
                 ),
        widget.GenPollText(
                 name = 'updates',
                 func = lambda: subprocess.check_output(['pacupdates']).decode('utf-8').strip(),
                 update_interval = 3600,
                 foreground = colors[2],
                 padding = 2,
                 mouse_callbacks = {
                     'Button1': lazy.function(run_paru_and_refresh)
                     },
                 ),
        widget.TextBox(
                 text = '|',
                 font = "IosevkaNerdFontPropo",
                 foreground = colors[1],
                 padding = 2,
                 fontsize = 14
                 ),
        widget.Battery(
                 format='󰁹 Fairy Dust: {percent:2.0%} {char}',
                 charge_char='CHR',
                 discharge_char='DIS',
                 empty_char='EMP',
                 full_char='FUL',
                 unknown_char='UKN',
                 not_charging_char = 'NOT',
                 foreground = colors[3],
                 update_interval=30,
                 padding = 2,
                 ),
        widget.TextBox(
                 text = '|',
                 font = "IosevkaNerdFontPropo",
                 foreground = colors[1],
                 padding = 2,
                 fontsize = 14
                 ),
        widget.CPU(
                 foreground = colors[4],
                 padding = 2,
                 mouse_callbacks = {'Button1': lambda: qtile.cmd_spawn(myTerm + ' -e btop')},
                 format = '󰘚 Tea: {load_percent}%',
                 ),
        widget.TextBox(
                 text = '|',
                 font = "IosevkaNerdFontPropo",
                 foreground = colors[1],
                 padding = 2,
                 fontsize = 14
                 ),
        widget.Memory(
                 foreground = colors[2],
                 padding = 2,
                 mouse_callbacks = {'Button1': lambda: qtile.cmd_spawn(myTerm + ' -e btop')},
                 format = '{MemUsed:.0f}{mm}',
                 fmt = ' Hot Loads: {}',
                 ),
        widget.TextBox(
                 text = '|',
                 font = "IosevkaNerdFontPropo",
                 foreground = colors[1],
                 padding = 2,
                 fontsize = 14
                 ),
        widget.DF(
                 update_interval = 60,
                 foreground = colors[5],
                 padding = 2,
                 mouse_callbacks = {'Button1': lambda: qtile.cmd_spawn('notify-disk')},
                 partition = '/',
                 format = '{uf}{m} free',
                 fmt = ' Penger Folder: {}',
                 visible_on_warn = False,
                 ),
        widget.TextBox(
                 text = '|',
                 font = "IosevkaNerdFontPropo",
                 foreground = colors[1],
                 padding = 2,
                 fontsize = 14
                 ),
        widget.Volume(
                 foreground = colors[7],
                 padding = 2,
                 fmt = ' Boom Box: {}',
                 ),
        widget.TextBox(
                 text = '|',
                 font = "IosevkaNerdFontPropo",
                 foreground = colors[1],
                 padding = 2,
                 fontsize = 14
                 ),
        widget.Clock(
                 foreground = colors[8],
                 padding = 2,
                 mouse_callbacks = {'Button1': lambda: qtile.cmd_spawn('notify-date')},
                 format = "󰥔 %a, %b %d - %H:%M",
                 ),
        widget.Systray(padding = 6),
        widget.Spacer(length = 8),

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
floating_layout = layout.Floating(
    border_focus=colors[8],
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
