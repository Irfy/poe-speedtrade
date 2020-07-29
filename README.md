# PoE-SpeedTrade

An ad-hoc, no-configuration script for speeding up trading in Path of Exile and preventing repetitive strain injury in susceptible individuals.

Not really a finished product, but I get asked about it very often, thus the repository. Beware, there's no GUI either.

There are two categories of hotkeys:

1. Multiple commands in one hotkey (F1-F5):
   * e.g. F2 combines /oos /remaining and /hideout <charname> under a single key press
2. Multiple mouse actions in one hotkey (F6+):
   * e.g. F9, while held, ctrl-clicks items from inventory in sequence, moving the mouse as needed (this is the most sought-after part of this script)

Both of these, as far as I can tell, "in principle" break PoE's Terms of Service, so I do not take any responsibility if you get banned.

# YOU HAVE BEEN WARNED

That being said, I've been using this script in various iterations for about 5 years now.

## Installation

There's nothing to "install". Get the main poe-speedtrade.ahk script file and run it.

Optionally, add it to your Windows Startup start-menu folder if you want it always to be ready. The script is limited to PoE's window class so it won't interfere with other applications.

If you know what you're doing, you can always `git clone https://github.com/Irfy/poe-speedtrade` and manage your local changes and pull any updates (of which there is very little).

If you have your own ad-hoc hotkeys and would like to include them, you can create a file ./include/_includes.ahk and either put the code there (included automatically) or #include your script from there.

You'll need [AutoHotkey](https://www.autohotkey.com/) to run the script -- older versions of AHK should work fine too, but a recent one is always recommended.

## Usage

The best documentation is code itself. Have a look at the hotkeys set up under the HOTKEYS section in the source file and test them out, disable those you don't want, etc.

You will get the best mileage from F6 and F9. Maybe F2 and F5. F7 is a must for 6-socketing/linking (pause every now and then to prevent temporary server-kick).

If you decide to use hotkeys F2-F5, you'll need to enter your current league's character name (variable `primary` near the top). If you use two accounts to have two PoE clients running in parallel, enter the second account's current league's character name in the appropriate place too (variable `secondary`).

Note: ^F5 means Ctrl-F5 and +F5 means Shift-F5, etc.

## Contributing

Feel free to create pull requests as you see fit, or create issues to complain.

## License

[MIT](https://choosealicense.com/licenses/mit/)
