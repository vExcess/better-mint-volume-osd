# Better Mint Volume OSD
Improved volume OSD for Linux Mint

## Why I don't like Mint's Volume OSD
1) Mint's volume display doesn't show the numerical level the volume is at.
2) Mint's volume controller doesn't let you change the increment your volume changes by (it's stuck at 5).
3) Mint's volume display doesn't let you drag on the volume bar to change the volume.

My volume OSD fixes all of the above issues.

## How my OSD is worse
1) My OSD takes longer to open (less efficient).
2) My OSD doesn't have a transparent background (couldn't figure out how to do this).
3) My OSD doesn't support different themes (it is only dark mode).
5) My OSD grabs the user's focus when it opens (Don't think I can fix this one since I'm using SDL, but it's not a major issue).

If you know how to fix these issues or have a reasonable feature request let me know.

Can I really say that mine is better if it's worse in more ways than it is better? I dunno. I'm gonna call it better anyways.

## Development
Requires [Git](https://git-scm.com/) and [Dart](https://dart.dev/) and [jvbuild](https://github.com/vExcess/jvbuild) to be installed.

```sh
# clone repo
git clone https://github.com/vExcess/better-mint-volume-osd.git
# enter project directory
cd better-mint-volume-osd/
# install dependencies
jvbuild install
# build project
jvbuild build
```

If `jvbuild build` throws `Bad state: Generating AOT kernel dill failed` just try it again. Idk why you sometimes need to run the build twice the first time you compile a project.

## Usage
### Install the deb package
Install the deb package in the `jvbuild-out` directory. You can build the deb package yourself by running `jvbuild package` after running `jvbuild build`.

### Setup the volume shortcuts
In System Settings -> Keyboard -> Shortcuts create the following 3 shortcuts:

- Name: `Volume_up`, Command: `btrmintvol +`
- Name: `Volume_down`, Command: `btrmintvol -`
- Name: `Volume_mute`, Command: `btrmintvol m`

Bind these shortcuts to the keys you use to increment, decrement, and mute/unmute your audio volume. Creating these new shortcuts should undo the bindings from the default audio shortcuts.

### Personalization (optional)
Open `~/.btrmintvol/config.yaml` in any text editor. You can change the audio increment in the config file. For example
```yaml
increment: 4
```

### Complete
You can now use keyboard shortcuts to adjust your audio volume to your liking!

## Screenshot
![screenshot](https://github.com/vExcess/better-mint-volume-osd/blob/main/thumbnail.png?raw=true)