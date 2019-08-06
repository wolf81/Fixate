# Fixate

This addon is meant to reduce some chores in WoW, to simplify the mundane stuff and also try to keep track of the development of your character. This add-on is also meant as a learning tool for myself.

The current provided functionality is as follows:
- AutoRepair: automatically repair your character when it talks to a merchant that can repair.
- EventCapture: automatically create screenshots on important events, like boss kills and level increase.
- JunkTrader: automatically sell junk items

Fixate has a slash menu accessible through either `/fixate` or `/fx`. Currently only a single option is supported `debug`. Calling `fixate debug` will toggle debug mode, providing more detailed logging. 

# Lessons Learned

While writing this AddOn I feel I figured out a few things that I'd like to write down for posterity :)

## Make `Frame` variables file local, not method local

The problem with method local `Frame` variables is that (as far as I can see) they can't be passed to the `OnEvent` handler that is hooked up using `SetScript`. Perhaps often you don't need this `Frame` variable, but perhaps sometimes you may want to unregister some event after an event is processed. In such cases you will need some way to access the `Frame` variable and if the variable is file local, this is no issue. An example of this situation can be seen in the `Fixate.lua` file where the `ADDON_LOADED` even is registered and upon receiving the event is unregistered. 

## Make use of modules to organize code

I like to work in an object oriented way and in Lua a way to achieve this is to use tables as classes. The basic pattern is pretty simple:

```
MyClass = {}
MyClass.__index = MyClass

function MyClass:New()
	local self = {}    
    setmetatable(self, MyClass)
	return self
end
```

## It *seems* one cannot make functions file local in modules

Well, at least not in a usable way. I'd like to keep some functions private, but World of Warcraft would report errors if I declared some function local within a module. 

## Use tables to hook events

For performance reasons it's best to use module tables to hook-up events, especially if a module deals with multiple events. I'd just use the same pattern everywhere regardless, for consistancy. An example of how to use the module table for this purpose is as follows:

```
local frame = CreateFrame('Frame')

function MyClass:Initialize()
	frame:RegisterEvent('PLAYER_LEVEL_UP')
	frame:RegisterEvent('BOSS_KILL')
	frame:SetScript('OnEvent', function(self, event, ...) MyClass[event](...) end)
end

function MyClass:PLAYER_LEVEL_UP(...)
	-- do something ...
end

function MyClass:BOSS_KILL(...)
	-- do something ...
end
```

In the above example `MyClass` has 2 methods to handle 2 different events. And a lookup table is used to access the appropriate event. This is much better performance wise then having a single event handler method that has a large `if-then-else` construction. And the lookup table approach also keeps each different event handler method more succint and to the point.

## Storing data between sessions is really easy

Just add the name of the variable that you want to store to the `Module.toc` file as such:

```
## Interface: ...
## Title : ...
## Notes: ...
## Author: ...
## SavedVariables: My_Defaults
```

Also create the named variable in a lua file as a global variable:

```
My_Defaults = {
	['Debug'] = false
}
```

The global variable will guarantee that the value is initialized on start-up, but if the data was stored in a previous session, the table will also be replaced with the table from last session.

## It's a good idea to have some sort of debug mode

For debugging scripts there are some tools, but I guess the main tool to use would be `print(...)`. However you wouldn't want to release with a whole lot of debug code visible and adding and removing debug code gets old real quickly. Therefore it's a good idea to build a debug mode in your add on that aids in logging.

My approach is as follows:
- There's a global debug switch that is stored between sessions
- The debug switch can be toggled with a slash command `/fx debug`
- There's a `Fixate:DebugPrint(...)` method that prints *only* if debug mode is enabled

## It's a good idea to pretty print feedback from the AddOn

Especially when writing lots of text to the chat window, it can be good to know if the source is your own AddOn or perhaps another one. Because of this, it's a good idea to create some kind of global accessible print function that pretty prints the messages of your AddOn. 

For Fixate the magic happens in `Fixate:Print(...)`. For all print commands send through this function, the text is prefixed with a teal colored text `[Fixate]`. This function is also used by `Fixate:DebugPrint(...)`.


