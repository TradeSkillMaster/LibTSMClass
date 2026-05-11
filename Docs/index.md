# LibTSMClass

The [LibTSMClass](https://github.com/TradeSkillMaster/LibTSMClass) library allows for writing
object-oriented code in lua! There are many OOP / class libraries out there for lua, but none of
them had all the features which we needed for TradeSkillMaster, were easily imported into WoW, and
were sufficiently performant.

## Example

```lua
local LibTSMClass = LibStub("LibTSMClass")
local MyClass = LibTSMClass.DefineClass("MyClass")

function MyClass:__init(value)
   self._value = value
end

function MyClass:GetValue()
   return self._value
end

function MyClass:SetValue(value)
   self._value = value
end

local MySubClass = LibTSMClass.DefineClass("MySubClass", MyClass)

function MySubClass:AddValue(value)
   self:SetValue(self:GetValue() + value)
end

local obj = MySubClass(4)
print(obj:GetValue()) -- 4
obj:SetValue(10)
print(obj:GetValue()) -- 10
obj:AddValue(5)
print(obj:GetValue()) -- 15
```
