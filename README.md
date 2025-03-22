[![Coverage Status](https://coveralls.io/repos/github/TradeSkillMaster/LibTSMClass/badge.svg?branch=main)](https://coveralls.io/github/TradeSkillMaster/LibTSMClass?branch=main)

# LibTSMClass

The LibTSMClass library allows for writing objected-oriented code in lua! There are many OOP / class libraries out there for lua, but none of them had all the features which we needed for TradeSkillMaster, were easily imported into WoW, and were sufficiently performant.

## Documentation

See the docs (TODO: link) for complete documentation and usage.

## Installation

If you're using the [BigWigs packager](https://github.com/BigWigsMods/packager), you can reference LibTSMClass as an external library:

```yaml
externals:
  Libs/LibTSMClass:
    url: https://github.com/TradeSkillMaster/LibTSMClass.git
```

Otherwise, you can download the [latest release directly from GitHub](https://github.com/TradeSkillMaster/LibTSMClass/releases).

## Example

A basic example of the library is below:
```lua
local LibTSMClass = LibStub("LibTSMClass")
local MyClass = LibTSMClass.DefineClass("MyClass")

function MyClass.__init(self, value)
	self._value = value
end

function MyClass.GetValue(self)
	return self._value
end

function MyClass.SetValue(self, value)
	self._value = value
end

local MySubClass = LibTSMClass.DefineClass("MySubClass", MyClass)

function MySubClass.AddValue(self, value)
	self:SetValue(self:GetValue() + value)
end

local obj = MySubClass(4)
print(obj:GetValue()) -- 4
obj:SetValue(10)
print(obj:GetValue()) -- 10
obj:AddValue(5)
print(obj:GetValue()) -- 15
```

## LuaLS Plugin

A [plugin](LuaLSPlugin/LibTSMClassLuaLSPlugin.lua) for [LuaLS](https://github.com/LuaLS/lua-language-server) is provided to allow for better handling of classes defined with LibTSMClass.

## License and Contributes

LibTSMClass is licensed under the MIT license. See LICENSE.txt for more information. If you would like to contribute to LibTSMClass, opening an issue or submitting a pull request against the [LibTSMClass GitHub project](https://github.com/TradeSkillMaster/LibTSMClass) is highly encouraged.
