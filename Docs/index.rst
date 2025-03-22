LibTSMClass
===========

The LibTSMClass library allows for writing objected-oriented code in lua! There are many OOP /
class libraries out there for lua, but none of them had all the features which we needed for
TradeSkillMaster, were easily imported into WoW, and were sufficiently performant.

Example
-------

A basic example of the library is below::

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


Contents
--------

.. toctree::
   :maxdepth: 1

   Home <self>
   features
   notes
   api
