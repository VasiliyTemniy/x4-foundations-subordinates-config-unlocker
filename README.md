# Subordinates Config Unlocker

Small quality-of-life mod for X4: Foundations.

It unlocks the gate-distance sliders for ships whose default behaviour is
controlled by their commander. This is useful for station traders, build-storage
traders, miners, prospectors, and salvagers when you want tighter control over how
far they may travel without removing their assignment.

## Why

Open the Behaviour tab of any station trader and look at the bottom: **"Max
gate distance to buy: 5 / 10"** — greyed out. The UI draws the slider, knows
its full range, displays the exact value it is refusing to let you change, and
locks it anyway. It is the postman holding up your parcel and explaining that
you cannot have it. There is no balance reason, no UX reason — a subordinate's
trade range is exactly the kind of thing an empire builder wants to tune per
station. This mod unlocks what should never have been locked in the first
place.

## Game version compatibility

- 9.00 release - **supported**
- 9.00 betas and release candidates - **supported**
- 8.00 release - **NOT supported.** The unlock rides on a kuertee UIX callback
  that ships only in the UI Extensions release for game version 9. On an older
  game/UIX build the mod still loads, but the sliders stay locked.

## Dependencies

- **kuertee UI Extensions and HUD** ([link](https://www.nexusmods.com/x4foundations/mods/552)) — provides the
  patched map/default-behaviour UI and its callback API
  (`displayOrderParam_change_paramactive`). The slider unlock runs entirely
  through it. **The V9 release of UIX or newer is required.**
- **SirNukes Mod Support APIs** ([link](https://www.nexusmods.com/x4foundations/mods/503)) — provides the Lua
  loader and the Simple Menu Options used by the Extension Options.

Both are hard dependencies. The mod will not load without them.

Please, **make sure to use the latest Kuertee's UI Extensions mod available for your game version**.
If it was not installed previously and the protected ui mode was "on", you would have to
disable the protected ui mode first. To do that, first you would have to disable all ui
mods, including Kuertee's UI Extensions, then reload the game, then turn off the protected
mode, reload the game again, turn on all the mods you like, reload the game again...
Then you can play! :)

## What It Unlocks

- Trader subordinate distances
- Trade for Build Storage subordinate distances
- Miner subordinate distances
- Prospector subordinate distances
- Salvager subordinate distances

The affected settings are:

- Min / max gate distance to buy or gather
- Min / max gate distance to sell
- Maximum range for salvage subordinates

## Options

Extension Options let you enable or disable each supported subordinate type
separately. Debug logging is also available there.

## Notes

- Ware baskets already have a vanilla override switch in the default behaviour
  UI, so this mod leaves them alone.
- Mining baskets are not changed by this mod.

## Credits

- Built on **kuertee UI Extensions and HUD** and **SirNukes Mod Support APIs**.
- By VasiliyTemniy.

## Source

https://github.com/VasiliyTemniy/x4-foundations-subordinates-config-unlocker
