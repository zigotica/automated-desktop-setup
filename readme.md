# Automated Desktop Setup

## What

A script that allows to configure any new macOS and/or Linux desktops in a blink of an eye. It is configured via csv/txt files (script can run different sets of data).

When passing a csv file (with the structure defined below), user is prompted for confirmation on each step. When passing a txt file, the commands in the file will be run without prompting the user.

For security reasons, and mainly to check the csv/txt will work properly, **the script runs in dryrun (fake) mode by default**.

![brew-dryrun-example](./images/brew-dryrun-example.png)

## Why

Everytime I use a computer for the first time, I spend some hours setting up all the options. This script will now allow me to be up and running in a few minutes. 

## Installation

From a new computer without developer tools, git, ... first thing to do is make sure you have command line tools installed and all software is already up to date:

```bash
xcode-select --install
sudo softwareupdate -l
```

Then, just download this repo as a zip and uncompress the file. Then change the data files at your will. Structure of these files is explained below.

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

In my case, I run the scripts in this order (better restart Terminal after each of them):

1. If you are using an ARM64 mac (M1, M1 Pro, M1 Max, ...) you will have to enable Rosetta for Terminal (at least at the time of this writting, end of 2021). To do so, select the Terminal app from Finder, right click, Get info, check the Open using Rosetta checkbox. Quit the Terminal, everytime it opens again it will be using Rosetta.
2. Install [Homebrew](https://brew.sh/)
3. Install a decent version of Bash.
4. Install formulae, casks and fonts, using `data/brew-formulae.csv`, `data/brew-casks.csv` and `data/brew-fonts.csv` files.
5. Configure macOS defaults, using `data/defaults-macos.csv`.
6. Download and install dotfiles
7. Create personal and work folders and clone repos into them.
8. Enjoy!

### Install and configure Homebrew

Homebrew is the best way so far to install all development dependencies, other software and even fonts. In this first step we will just install Homebrew from the Terminal:

```bash
sudo curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash
```

At the end of installation you will see a message that reads similar to this:

```bash
==> Next steps
- Add Homebrew to your PATH...
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/yournickname/.zprofile
```

Homebrew is installed in `/opt/homebrew/` (ARM) or `/usr/local/` (Intel), the message above can be slightly different. Just copy the message and run it. In my case, since I am using bash, I run:

```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.bash_profile
```

Also, if using an ARM chip, brew needs to be prepended with `arch -arm64`, so I also run this:

```bash
echo 'alias brew="arch -arm64 brew"' >> ~/.bash_profile
```

Now restart Terminal and `brew` should be installed properly. Just check with:

```bash
brew doctor
```

### Install a decent version of Bash

MacOS bash version is really outdated:

```bash
brew install bash
```

Restart Terminal again. Now we need to make sure MacOS runs our installed version, not the old one:

```bash
echo "/opt/homebrew/bin/bash" | sudo tee -a /etc/shells
```

Finally, we need to inform the OS to use that specific shell:

```bash
chsh -s /opt/homebrew/bin/bash
```

Now restart Terminal for a final time. To make sure we are using the correct version of bash, you can run:

```bash
which bash
```

It should return something like `/opt/homebrew/bin/bash`. Otherwise check the process above.

The rest of the process is automated using the main script and data files.

### Install Homebrew formulae, casks and fonts

The script will prompt giving you some options on each step (you can run without prompts if using `-s` argument) to install the core formulae (note the `-r` argument to run it for real):

```bash
./.setup.sh -f data/brew-formulae.csv -r
```

You can then optionally install casks:

```bash
./.setup.sh -f data/brew-casks.csv -r
```

and/or fonts:

```bash
./.setup.sh -f data/brew-fonts.csv -r
```

### Sensible macOS defaults

For a new Mac, next step would be setting some sensible macOS defaults (note the `-r` argument to run it for real):

```bash
./.setup.sh -f data/defaults-macos.csv -r
```

The script will prompt giving you some options on each step (you can run without prompts if using `-s` argument).

### Download and install dotfiles

The strategy will depend on the way you actually backup your dotfiles. In my case, I clone my [dotfiles](https://github.com/zigotica/tilde/) as a [bare repo](https://www.atlassian.com/git/tutorials/dotfiles) because I don't like the symlinks approach.

You can use a txt file to add a few custom commands without the need to edit the main script. Then you can run the script with these arguments (note the `-r` argument to run it for real):

```bash
./.setup.sh -f data/dotfiles.txt -r
```

Being a txt file, the script will NOT prompt for options.

### Clone repos

I am also using the script to create personal and work folders and clone repos into them:

```bash
./.setup.sh -f data/repos.txt -r
```

With all these, you should be ready to go and enjoy your new computer.

## Feedback

[Issue reports](https://github.com/zigotica/automated-desktop-setup/issues) and [suggestions](https://github.com/zigotica/automated-desktop-setup/pulls) are welcome. Thank you.

## Credits

Big thanx to [Mathias Bynens](https://github.com/mathiasbynens/dotfiles/) and [thoughtbot, inc](https://github.com/thoughtbot/laptop/) for their .dotfiles projects. Also [Luke Smith](https://github.com/LukeSmithxyz/LARBS) for the idea of running a set of commands by reading from a csv file.
