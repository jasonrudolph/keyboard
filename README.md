## Toward a more useful keyboard

Steve Losh's [Modern Space Cadet][modern-space-cadet] is an inspiration.
It opened my eyes to the fact that there's a more useful keyboard hidden inside the vanilla QWERTY package that most of us have tolerated for all these years.
This repo represents my nascent quest to unleash that more useful keyboard.

At first, this might sound no different than the typical Emacs/Vim/\<Every-Other-Editor> tweakfest.
But it is.
I'm not talking about honing my editor-of-choice.
I'm not talking about pimping out my shell.
I want a more useful keyboard _everywhere_.
Whether I'm in my editor, in the terminal, in the browser, or in Keynote,
I want a more useful keyboard.

And ideally, I want the _same_ (more useful) keyboard in every app.
Ubiquitous keyboarding.
Muscle memory.
[Don't make me think][don't-make-me-think].

How do I go to the beginning of the line in this app?
The same way I go to the beginning of the line in _every_ app!
Don't make me think.

How do I go to the top of the file/screen/page in this app?
The same way I...
Well, you get the point.

## Some assembly required

In its current state, my more-useful keyboard is built on top of a few tools, and some custom keymappings for those tools (all of which are described below).
Where possible, this repo houses the configuration files that power my more-useful keyboard.
In the places where the customization requires manual steps, I describe those steps.

Below you'll find a step-by-step guide for building this more-useful keyboard from scratch.

## More useful (for me)

> **cus·tom·ize** (_verb_): to modify or build according to individual or personal specifications or preference [[dictionary.com][customize]]

Any customization is, by definition, personal.
While I find that these customizations yield a more-useful keyboard for me, they might not feel like a win for you.

These customizations currently provide a fraction of what I want from my more-useful keyboard.
I find it to be a very useful fraction, but I don't consider it complete by any means.

Here's what it provides so far:

![Karabiner Change Key Configuration - 01](screenshots/karabiner-change-key-config-01.png)

![Karabiner Change Key Configuration - 02](screenshots/karabiner-change-key-config-02.png)

![Karabiner Change Key Configuration - 03](screenshots/karabiner-change-key-config-03.png)

![Karabiner Change Key Configuration - 04](screenshots/karabiner-change-key-config-04.png)

## Dependencies

This setup is honed and tested with the following dependencies.

- OS X El Capitan, 10.11
- [Seil 12.0][seil]
- [Karabiner 10.14][karabiner]
- [SizeUp 1.6][sizeup] (optional)

## The Setup

### Grab the bits

```sh
git clone https://github.com/jasonrudolph/keyboard.git

cd keyboard

mkdir -p ~/Library/Application\ Support/Karabiner

# Prepare custom settings for Karabiner
ln -s $PWD/karabiner/private.xml \
  ~/Library/Application\ Support/Karabiner/private.xml

ln -s $PWD/karabiner/ext \
  ~/Library/Application\ Support/Karabiner/ext
```

### Install the apps

- Install [Seil][seil]
- Install [Karabiner][karabiner]
- Install [SizeUp][sizeup] (optional)

### Put _control_ and _escape_ on the home row

#### Goals

- Tap **caps lock** for **escape**
- Hold **caps lock** for **control**
- Access the default **caps lock** behavior in those rare cases where it's helpful

#### Making it happen

1. Launch Seil.
2. Enable the "Change Caps Lock" option, and map **caps lock** to keycode 80.
   (80 is **F19**. I don't have a physical **F19** key, so this setting will not
   conflict with any existing keys.)
   [[screenshot][seil-screenshot]]
3. Launch Karabiner.
4. In the "Change Key" tab, enable the "F19 to Escape/Control" option.
   [[screenshot][karabiner-change-key-screenshot-01]]
5. In the "Change Key" tab, enable the "Double-tap Left Shift for CapsLock" option.
6. In the "Key Repeat" tab, change the "[Key Overlaid Modifier] Timeout" to
   300ms. (As [recommended][modern-space-cadet-key-repeat] by Steve Losh, I find
   that this avoids accidentally triggering **escape** when you meant to trigger
   **control**.)
   [[screenshot][karabiner-key-repeat-screenshot]]

### Unleash (S)uper (D)uper mode

#### Goals

- Enable navigation (up/down/left/right) via the home row
- Enable word navigation (option+left/right) via the home row
- Enable other commonly-used actions on or near the home row

#### Making it happen

1. Launch Karabiner.
2. In the "Change Key" tab, enable the "(S)uper (D)uper Mode" option.
   [[screenshot][karabiner-change-key-screenshot-02]]

### Control SizeUp from the home row

#### Goals

- Quickly arrange and resize windows in common configurations, using keyboard
  shortcuts that are on or near the home row

#### Making it happen

1. Launch Karabiner.
2. In the "Change Key" tab, enable the "SizeUp Mode" option.
   [[screenshot][karabiner-change-key-screenshot-03]]

### Format text as Markdown

#### Goals

- Perform common Markdown-formatting tasks anywhere that you're editing text
  (e.g. in a GitHub comment, in your editor, in your email client)

#### Making it happen

1. Launch Karabiner.
2. In the "Change Key" tab, enable the "Markdown Mode" option.
   [[screenshot][karabiner-change-key-screenshot-04]]

## TODO

- Document usage of "Hyper" key
- Incorporate [Keyboard Maestro][keyboard-maestro] configuration
- Add `./script/setup` command to automate the manual setup steps


[customize]: http://dictionary.reference.com/browse/customize
[don't-make-me-think]: http://en.wikipedia.org/wiki/Don't_Make_Me_Think
[keyboard-maestro]: http://keyboardmaestro.com
[karabiner]: http://pqrs.org/macosx/karabiner/
[karabiner-change-key-screenshot-01]: screenshots/karabiner-change-key-config-01.png
[karabiner-change-key-screenshot-02]: screenshots/karabiner-change-key-config-02.png
[karabiner-change-key-screenshot-03]: screenshots/karabiner-change-key-config-03.png
[karabiner-change-key-screenshot-04]: screenshots/karabiner-change-key-config-04.png
[karabiner-key-repeat-screenshot]: screenshots/karabiner-key-repeat-config.png
[modern-space-cadet]: http://stevelosh.com/blog/2012/10/a-modern-space-cadet
[modern-space-cadet-key-repeat]: http://stevelosh.com/blog/2012/10/a-modern-space-cadet/#controlescape
[seil]: https://pqrs.org/macosx/keyremap4macbook/seil.html.en
[seil-screenshot]: screenshots/seil-config.png
[sizeup]: http://www.irradiatedsoftware.com/sizeup/
