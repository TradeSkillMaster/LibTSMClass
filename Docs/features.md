# Features

## Class Definition

To define a new class, simply use the `LibTSMClass.DefineClass()` method of the library:
```lua
local MyClass = LibTSMClass.DefineClass("MyClass")
```

This function takes at least one argument, which is the name of the class. This class name is primarily used to make debugging easier, by leveraging it in the `__tostring()` metamethod for both the class and instances of the class.

## Instantiation

The class can be called as a function to create an instance of the class.

```lua
local classInst = MyClass()
```

If a table containing existing attributes already exists, it can be converted into an instance of the class via the `LibTSMClass.ConstructWithTable()` method.

```lua
local tbl = { existingValue = 2 }
local classInst = LibTSMClass.ConstructWithTable(tbl, MyClass)
print(classInst.existingValue) -- prints 2
```

## Static Attributes

Static fields are allowed on all classes and can be accessed by instances of the class. Note that modifying the value of a static field on an instance of the class creates a new property on the instance and does not modify the class's static value.

```lua
MyClass.staticValue = 31
print(MyClass.staticValue) -- prints 31
local classInst = MyClass()
print(classInst.staticValue) -- prints 31
classInst.staticValue = 2
print(classInst.staticValue) -- prints 2
print(MyClass.staticValue) -- prints 31
```

## Method Definition

Classes define their methods by simply defining the functions on the class object which was previously created.

```lua
function MyClass.SayHi(self)
	print("Hello from MyClass!")
end
function MyClass.GetValue(self)
	return self._value
end
```

## Static Class Functions

Static class functions (not instance methods) can be defined via the `__static` property.

```lua
function MyClass.__static.GetSecretNumber()
	return 802
end
print(MyClass.GetSecretNumber()) -- prints 802
```

## Constructor

The constructor is a special class method with a name of `__init()` and is called whenever a class is instantiated. Any arguments passed when instantiating the class will be passed along to the constructor. Note that the constructor should never return any values.

```lua
function MyClass.__init(self, value)
	self._value = value
end
function MyClass.GetValue(self)
	return self._value
end
local classInst = MyClass(42)
print(classInst:GetValue()) -- prints 42
```

## Inheritance

Classes can be sub-classed by specifying their base class when defining them. Any methods which are defined on the base class can then be overridden. The subclass is also allowed to access any methods or properties of its base class.

```lua
local MySubClass = LibTSMClass.DefineClass("MySubClass", MyClass)
function MySubClass.SayHi(self)
	print("Hello from MySubClass")
end
```

## Accessing the Base Class

In order to explicitly access a method or attribute of the parent class, the `__super` attribute can be used. This is generally used to call the parent class's implementation of a given method. Note that the `__super` attribute can only be accessed from within a class method. This attribute can be used multiple times to continue to walk up the chain of parent classes for cases where there is more than one level of sub-classing.

```lua
function MySubClass.SayHiAll(self)
	print("Hello from MySubClass")
end
function MySubClass.GetValue(self)
	return self.__super:GetValue() + 2
end
```

Note that `__super` may also be used on class objects themselves, including outside of any class methods.

```lua
MyClass.staticValue = 2
MySubClass.staticValue = 5
print(MySubClass.__super.staticValue) -- prints 2
```

Another mechanism for accessing an explicit parent class from a subclass is by using the special `__as` instance method. This can be especially useful when there is a long chain of inheritance.

```lua
function MySubClass.GetValue(self)
	return self:__as(MyClass):GetValue() + 2
end
```

## Private Class Methods

Classes can define `private` methods which can only be accessed by the class itself. In other words, these methods can only be called from within another method of the same class or within a static function of the class. Private methods are defined by creating them against the `__private` property of the class.

```lua
function MyClass.__private._HashRound(self, x, y)
	return x * 44 + x * y
end
function MyClass.PoorlyHash(self, x)
	return self:_HashRound(x - 1, x + 1)
end
```

## Protected Class Methods

Classes can define `protected` methods which behave like private methods, but can also be accessed by subclasses of the class. Protected methods are defined by creating them against the `__protected` property of the class (in a similar manner to example above for private methods).

## Other Useful Attributes

## `__tostring()`

Every class and instance has a special `__tostring()` method which can be used to convert it to a string. This is generally useful for debugging. Classes can override this method in order to provide a custom implementation.

```lua
function MySubClass.__tostring(self)
	return "MySubClass with a value of "..self._value
end
local classInst = MyClass(0)
print(classInst) -- prints "MyClass:00B8C688"
print(MySubClass) -- prints "class:MySubClass"
local subClassInst = MySubClass(3)
print(subClassInst) -- prints "MySubClass with a value of 3"
```

## `__name`

The `__name` attribute is provided on all classes to look up the name of the class.

```lua
print(MyClass.__name) -- prints "MyClass"
```

## `__dump()`

All instances have a special `__dump()` method which can be used to pretty-print the fields of class for debugging. Similarly to `__tostring()`, the default implementation may be overridden in order to provide a custom implementation.

```lua
local classInst = MyClass(0)
classInst:__dump()
-- MyClass:00B8C688 {
--     _value = 0
-- }
```

## `__class`

The special `__class` field is provided on every instance in order to introspect the class to which the instance belongs.

```lua
local classInst = MyClass(0)
print(classInst.__class) -- prints "class:MyClass"
```

## `__isa()`

In order to test whether or not an instance belongs to a given class, the `__isa` method is provided on all instances.

```lua
local classInst = MyClass(3)
print(classInst:__isa(MyClass)) -- prints true
print(classInst:__isa(MySubClass)) -- prints false
```

## `__closure()`

A class with private or protected methods may want to allow calling those methods from outside of another method of the class, which would generally not be allowed. This can be accomplished using the `__closure` method.

```lua
function MyClass.__private._EventHandler(self, eventName)
	print("Handling event: "..eventName)
end
local classInst = MyClass(3)
Event.RegisterHandler(classInst:__closure("_EventHandler"))
```

## Virtual Methods

One of the most powerful features of LibTSMClass is support for virtual class methods. What this means is that within a base class method, an instance of a class is still treated as its an instance of its actual class, not the base class. This is best demonstrated with an example:

```lua
function MyClass.GetMagicNumber(self)
	return 99
end
function MyClass.PrintMagicNumber(self)
	print(self:GetMagicNumber())
end
function MySubClass.GetMagicNumber(self)
	return 88
end
local subClassInst = MySubClass(0)
subClassInst:PrintMagicNumber() -- prints 88
```

## Abstract Classes

An abstract class is one which can't be directly instantiated. Other than this restriction, abstract classes behave exactly the same as normal classes, including the ability to be sub-classed. This is useful in order to define a common interface which multiple child classes are expected to adhere to. An abstract class is defined by passing an extra argument when defining the class as shown below:
```lua
local AbstractClass = LibTSMClass.DefineClass("AbstractClass", nil, "ABSTRACT")

local ImplClass = LibTSMClass.DefineClass("ImplClass", AbstractClass)
```

## Abstract Class Methods

Abstract classes may define abstract methods which subclasses are required to implement. This is done by defining an empty function against the `__abstract` table. Note that this function doesn't strictly need to be empty, but is never called (or even stored anywhere within LibTSMClass). Abstract class methods are **always implicitly protected**, so must be overridden as such.

```lua
function AbstractClass.__abstract._GetResult(self)
end

function AbstractClass.AddNumber(self, num)
	return num + self:_GetResult()
end

function ImplClass.__protected._GetResult(self)
	return 10
end

local inst = ImplClass()
print(inst:AddNumber(2)) -- prints 12
```
