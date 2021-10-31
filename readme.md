# Automated Desktop Setup

## What

A script that allows to configure any new macOS and/or Linux desktops in a blink of an eye. It is configured via csv/txt files (script can run different sets of data).

When passing a csv file (with the structure defined below), user is prompted for confirmation on each step. When passing a txt file, the commands in the file will be run without prompting the user.

For security reasons, and mainly to check the csv/txt will work properly, **the script runs in dryrun (fake) mode by default**.

![brew-dryrun-example](./images/brew-dryrun-example.png)

## Why

Everytime I use a computer for the first time, I spend some hours setting up all the options. This script will now allow me to be up and running in a few minutes. 

## Installation

From a new computer without developer tools, git, ... just download this repo as a zip and uncompress the file. Then change the data files at your will. Structure of these files is explained below.

### Warning 

If you want to give this script a try, review the code before running it, change or remove things you don’t want or need. You should just need to update the csv/txt files, as described below. The script _per se_ don't run anything on your computer without data from those csv/txt files. In any case, if you want to use my settings without changing, **USE AT YOUR OWN RISK!**

## Structure of a CSV file

CSV files contain comments and commands, in the following structure:

* What: describes the content of the line, so the script know what to do with it. Possible values are:
    * `#` Big title
    * `##` Smaller title
    * `b` Brew formula
    * `k` Brew cask
    * `c` Command
    * `d` macOS defaults
    * `r` Run command without asking
* Text: used as title or the question prompted to the user, or the name of the brew formula/cask
* Default answer: boolean (true|false) defines the default action when user replies with Enter (or in silent mode)
* Defaults rule or Command to be run for 'Yes' reply
* Command to be run for 'No' reply

Each line MUST contain 5 columns separated by comma. If first column doesn't include one of the keycodes described above, it will just be skipped.

## Structure of a txt file

txt files will be evaluated, so anything you put there is run without prompting the user for confirmation. Still, if you run the script in dryrun mode, the txt file is not actually executing real commands. 

## Required / Optional arguments

Main `.setup.sh` script needs a csv or txt file passed with a `-f` argument:


```bash
./.setup.sh -f data/brew-formulae.csv
```

The script will detect the type and run the csv parser or txt parser automagically.

You can also pass a `-s` optional argument, that will run the whole set of commands without prompting the user for confirmation.

Reminder, for security reasons, and mainly to check the csv/txt will work properly, **the script runs in dryrun (fake) mode by default**. To make it work for real you MUST pass the `-r` argument.

## Run

The idea behind the batch script and csv/txt files is that you only have to configure data files, and can have as many as you want without having to edit the script.

In my case, I run the script in this order:

1. Install [Homebrew](https://brew.sh/), formulae and casks, using `data/brew-formulae.csv`.
2. Configure macOS defaults, using `data/defaults-macos.csv`.
3. Clone my [dotfiles](https://github.com/zigotica/tilde/) as a [bare repo](https://www.atlassian.com/git/tutorials/dotfiles), using `data/dotfiles.txt`.
4. Enjoy

### Install Homebrew formulae

When setting up a new Mac (or even Linux distribution), you may want to start by instaling all the development dependencies with Homebrew formulae (note the `-r` argument to run it for real):

```bash
./.setup.sh -f data/brew-formulae.csv -r
```

The script will prompt giving you some options on each step (you can run without prompts if using `-s` argument).

### Sensible macOS defaults

For a new Mac, next step would be setting some sensible macOS defaults (note the `-r` argument to run it for real):

```bash
./.setup.sh -f data/defaults-macos.csv -r
```

The script will prompt giving you some options on each step (you can run without prompts if using `-s` argument).

### Download and install dotfiles

You can use a txt file to add a few custom commands without the need to edit the main script. Then you can run the script with these arguments (note the `-r` argument to run it for real):

```bash
./.setup.sh -f data/dotfiles.txt -r
```

Being a txt file, the script will NOT prompt for options.

With all these, you should be ready to go and enjoy your new computer.

## Feedback

[Issue reports](https://github.com/zigotica/automated-desktop-setup/issues) and [suggestions](https://github.com/zigotica/automated-desktop-setup/pulls) are welcome. Thank you.

## Credits

Big thanx to [Mathias Bynens](https://github.com/mathiasbynens/dotfiles/) and [thoughtbot, inc](https://github.com/thoughtbot/laptop/) for their .dotfiles projects. Also [Luke Smith](https://github.com/LukeSmithxyz/LARBS) for the idea of running a set of commands by reading from a csv file.
