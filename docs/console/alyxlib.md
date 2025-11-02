# AlyxLib Commands

These commands specifically pertain to getting information and help with AlyxLib and addons registered with AlyxLib.

!!! note
    Not all addons made with AlyxLib are registered with AlyxLib. It is an optional feature.

**How to read the syntax:**

* The **first word** is always the command name; everything after it is a parameter.
* **Required parameters** are wrapped in `<angle brackets>`.
* **Optional parameters** are wrapped in `[square brackets]`.
* Parameters followed by `...` mean you can supply as many as you want.

## alyxlib_info

Syntax: `alyxlib_info`

Prints AlyxLib version information and number of addons registered with AlyxLib (as of v1.3.0) vs unregistered.

!!! note
	"Init Addons" field may always be 0 if Scalable Init Support is enabled and has priority.

## alyxlib_addons

Syntax: `alyxlib_addons`

Prints a list of addons registered with AlyxLib (as of v1.3.0) and information about them.

## alyxlib_diagnose

Syntax: `alyxlib_diagnose [addon]`

Prints information about AlyxLib and the user (e.g. Single handed, which map, if VR is enabled) which the user can then send to the developer along with their description of the issue to aid in developer debugging.

If an addon is supplied and the addon has registered a diagnostic function, it will be used to diagnose specific addon issues and hopefully provide more information for the developer or suggest fixes to the user.

Example usage:
```
alyxlib_diagnose
alyxlib_diagnose resin
alyxlib_diagnose Resin Watch
alyxlib_diagnose body holster
```

## alyxlib_commands

Syntax: `alyxlib_commands`

Prints all commands/convars registered using AlyxLib's `RegisterAlyxLibCommand` and `RegisterAlyxLibConvar` functions.

This is an easy way to see all commands in alphabetical order with descriptions and default values.