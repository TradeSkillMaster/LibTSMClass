-- test framework
luaunit = require('Tests.Unit.Include.luaunit')
require('Tests.Unit.Include.wowunit')

-- code under test
require('LibStub.LibStub')
require('LibTSMClass')
LibTSMClass = LibStub("LibTSMClass")



local function GetPrintOutput(func)
	local lines = {}
	local oldPrint = print
	print = function(line, ...)
		assert(select("#", ...) == 0, "Print called with multiple arguments")
		tinsert(lines, line)
	end
	local success, err = pcall(func)
	print = oldPrint
	luaunit.assertIsNil(err)
	luaunit.assertTrue(success)
	return lines
end


TestLibTSMClass = {}
function TestLibTSMClass.TestBasic()
	local Test = LibTSMClass.DefineClass("Test")
	function Test.__init(self)
		if not self.initialized then
			self.initialized = true
			self.value = 2
		end
	end
	function Test.GetValue(self)
		return self.value
	end

	local testInst = Test()
	luaunit.assertTrue(testInst.initialized)
	luaunit.assertEquals(testInst:GetValue(), 2)

	local testInst2 = LibTSMClass.ConstructWithTable({ initialized = true, value = 5 }, Test)
	luaunit.assertTrue(testInst2.initialized)
	luaunit.assertEquals(testInst2:GetValue(), 5)
end

function TestLibTSMClass.TestSubClass()
	local Test = LibTSMClass.DefineClass("Test")
	function Test.__init(self)
		self.initialized = true
		self.n = 2
	end
	function Test.GetMagicNumber(self)
		return 0
	end
	function Test.Echo(self, ...)
		return ...
	end

	local TestSub = LibTSMClass.DefineClass("TestSub", Test)
	function TestSub.__init(self)
		self.__super:__init()
		self.subInitialized = true
	end
	function TestSub.GetMagicNumber(self)
		return self.__super:GetMagicNumber() + 1
	end
	function TestSub.GetText(self)
		return "TEXT"
	end

	luaunit.assertTrue(Test:__isa(Test))
	luaunit.assertTrue(TestSub:__isa(Test))
	luaunit.assertTrue(TestSub:__isa(TestSub))

	local testSubInst = TestSub()
	luaunit.assertTrue(testSubInst:__isa(Test))
	luaunit.assertTrue(testSubInst:__isa(TestSub))
	luaunit.assertTrue(testSubInst.initialized)
	luaunit.assertTrue(testSubInst.subInitialized)

	luaunit.assertEquals(testSubInst.n, 2)
	testSubInst.n = testSubInst.n + 1
	luaunit.assertEquals(testSubInst.n, 3)

	luaunit.assertEquals(testSubInst:GetMagicNumber(), 1)
	luaunit.assertEquals(testSubInst:Echo(22), 22)
	luaunit.assertEquals(testSubInst:GetText(), "TEXT")
end

function TestLibTSMClass.TestStatic()
	local Test = LibTSMClass.DefineClass("Test")
	function Test.__static.GetA()
		return 95
	end
	function Test.__static.GetZ()
		return 52
	end
	Test.staticX = 39

	local TestSub = LibTSMClass.DefineClass("TestSub", Test)
	function TestSub.__static.GetZ()
		return 77
	end
	TestSub.staticX = 9
	TestSub.staticY = 32

	luaunit.assertEquals(Test.GetZ(), 52)
	luaunit.assertEquals(TestSub.GetZ(), 77)
	luaunit.assertEquals(Test.GetA(), 95)
	luaunit.assertEquals(TestSub.GetA(), 95)

	local testInst = Test()
	luaunit.assertEquals(testInst.staticX, 39)
	luaunit.assertEquals(testInst.staticY, nil)

	testInst.staticX = 11
	luaunit.assertEquals(testInst.staticX, 11)
	luaunit.assertEquals(Test.staticX, 39)

	local testSubInst = TestSub()
	luaunit.assertEquals(testSubInst.staticX, 9)
	luaunit.assertEquals(testSubInst.staticY, 32)
end

function TestLibTSMClass.TestVirtual()
	local Test = LibTSMClass.DefineClass("Test")
	function Test.VirtualMethod(self)
		return 111
	end
	function Test.VirtualMethodCaller(self)
		return self:VirtualMethod()
	end
	function Test.VirtualMethodCaller2(self)
		return self:VirtualMethod2()
	end

	local TestSub = LibTSMClass.DefineClass("TestSub", Test)
	function TestSub.VirtualMethod(self)
		return 777
	end
	function TestSub.VirtualMethod2(self)
		return 333
	end

	local testSubInst = TestSub()
	luaunit.assertEquals(testSubInst:VirtualMethod(), 777)
	luaunit.assertEquals(testSubInst:VirtualMethodCaller(), 777)
	luaunit.assertEquals(testSubInst:VirtualMethod2(), 333)
	luaunit.assertEquals(testSubInst:VirtualMethodCaller2(), 333)
end

function TestLibTSMClass.TestAsAndSuper()
	local A, B, C = nil, nil, nil

	A = LibTSMClass.DefineClass("A")
	function A.__tostring(self)
		return "A_STR"
	end
	function A.GetLetter(self)
		return "A"
	end
	function A.ADoTestSuper1(self)
		return self.__super:GetLetter()
	end
	function A.ADoTestSuper2(self)
		return self.__super.__super:GetLetter()
	end
	function A.ADoTestAsA(self)
		return self:__as(A):GetLetter()
	end
	function A.ADoTestAsB(self)
		return self:__as(B):GetLetter()
	end
	function A.ADoTestAsC(self)
		return self:__as(C):GetLetter()
	end

	B = LibTSMClass.DefineClass("B", A)
	function B.__tostring(self)
		return "B_STR"
	end
	function B.GetLetter(self)
		return "B"
	end
	function B.BDoTestSuper1(self)
		return self.__super:GetLetter()
	end
	function B.BDoTestSuper2(self)
		return self.__super.__super:GetLetter()
	end
	function B.BDoTestAsA(self)
		return self:__as(A):GetLetter()
	end
	function B.BDoTestAsB(self)
		return self:__as(B):GetLetter()
	end
	function B.BDoTestAsC(self)
		return self:__as(C):GetLetter()
	end

	C = LibTSMClass.DefineClass("C", B)
	function C.__tostring(self)
		return "C_STR/"..self.__super:__tostring().."/"..self:__as(A):__tostring()
	end
	function C.GetLetter(self)
		return "C"
	end
	function C.CDoTestSuper1(self)
		return self.__super:GetLetter()
	end
	function C.CDoTestSuper2(self)
		return self.__super.__super:GetLetter()
	end
	function C.CDoTestAsA(self)
		return self:__as(A):GetLetter()
	end
	function C.CDoTestAsB(self)
		return self:__as(B):GetLetter()
	end
	function C.CDoTestAsC(self)
		return self:__as(C):GetLetter()
	end

	local testCInst = C()
	luaunit.assertEquals(tostring(testCInst), "C_STR/B_STR/A_STR")
	luaunit.assertEquals(testCInst:GetLetter(), "C")
	luaunit.assertEquals(testCInst:CDoTestSuper1(), "B")
	luaunit.assertEquals(testCInst:CDoTestSuper2(), "A")
	luaunit.assertEquals(testCInst:CDoTestAsA(), "A")
	luaunit.assertEquals(testCInst:CDoTestAsB(), "B")
	luaunit.assertEquals(testCInst:CDoTestAsC(), "C")
	luaunit.assertEquals(testCInst:BDoTestSuper1(), "A")
	luaunit.assertErrorMsgContains("Requested class does not exist", function() testCInst:BDoTestSuper2() end)
	luaunit.assertEquals(testCInst:BDoTestAsA(), "A")
	luaunit.assertEquals(testCInst:BDoTestAsB(), "B")
	luaunit.assertEquals(testCInst:BDoTestAsC(), "C")
	luaunit.assertErrorMsgContains("Requested class does not exist", function() testCInst:ADoTestSuper1() end)
	luaunit.assertErrorMsgContains("Requested class does not exist", function() testCInst:ADoTestSuper2() end)
	luaunit.assertEquals(testCInst:ADoTestAsA(), "A")
	luaunit.assertEquals(testCInst:ADoTestAsB(), "B")
	luaunit.assertEquals(testCInst:ADoTestAsC(), "C")

	local testBInst = B()
	luaunit.assertEquals(tostring(testBInst), "B_STR")
	luaunit.assertEquals(testBInst:GetLetter(), "B")
	luaunit.assertEquals(testCInst:BDoTestSuper1(), "A")
	luaunit.assertErrorMsgContains("Requested class does not exist", function() testBInst:ADoTestSuper2() end)
	luaunit.assertEquals(testBInst:BDoTestAsA(), "A")
	luaunit.assertEquals(testBInst:BDoTestAsB(), "B")
	luaunit.assertErrorMsgContains("Object is not an instance of the requested class (class:C)", function() testBInst:BDoTestAsC() end)

	local testAInst = A()
	luaunit.assertEquals(tostring(testAInst), "A_STR")
	luaunit.assertEquals(testAInst:GetLetter(), "A")
	luaunit.assertErrorMsgContains("The class of this instance has no superclass", function() testAInst:ADoTestSuper1() end)
	luaunit.assertErrorMsgContains("The class of this instance has no superclass", function() testAInst:ADoTestSuper2() end)
	luaunit.assertErrorMsgContains("The class of this instance has no superclass", function() testAInst:ADoTestAsA() end)
	luaunit.assertErrorMsgContains("Object is not an instance of the requested class (class:B)", function() testAInst:ADoTestAsB() end)
	luaunit.assertErrorMsgContains("Object is not an instance of the requested class (class:C)", function() testAInst:ADoTestAsC() end)
end

function TestLibTSMClass.TestAbstractMethod()
	local Test = LibTSMClass.DefineClass("Test", nil, "ABSTRACT")
	function Test.__init(self)
		self.initialized = true
		self.n = 2
	end
	function Test.GetMagicNumber(self)
		return 0
	end
	function Test.GetMagicPhrase(self)
		return self:GetText()
	end
	function Test.__abstract._GetTextImpl()
	end
	function Test.GetText(self)
		return self:_GetTextImpl()
	end

	local TestSub = LibTSMClass.DefineClass("TestSub", Test)
	function TestSub.__init(self)
		self.__super:__init()
		self.subInitialized = true
	end
	function TestSub.GetMagicNumber(self)
		return self.__super:GetMagicNumber() + 1
	end

	luaunit.assertErrorMsgContains("Missing abstract method: _GetTextImpl", function() TestSub() end)

	function TestSub.__protected._GetTextImpl(self)
		return "TEXT"
	end
	function TestSub.GetTextFail(self)
		return self.__super:_GetTextImpl()
	end

	local inst = TestSub()
	luaunit.assertEquals(inst:GetText(), "TEXT")
	luaunit.assertErrorMsgContains("attempt to call method '_GetTextImpl' (a nil value)", function() inst:GetTextFail() end)
end

function TestLibTSMClass.TestPrivateMethod()
	local Test = LibTSMClass.DefineClass("Test")
	function Test.__private.GetMagicNumber(self)
		return 0
	end
	function Test.GetMagicPhrase(self)
		return "NUMBER: "..self:GetMagicNumber()
	end

	local inst = Test()
	luaunit.assertErrorMsgContains("Attempting to call private method (GetMagicNumber) from outside of class", function() inst:GetMagicNumber() end)
	luaunit.assertEquals(inst:GetMagicPhrase(), "NUMBER: 0")
end

function TestLibTSMClass.TestProtectedMethod()
	local Test = LibTSMClass.DefineClass("Test")
	function Test.__protected._GetNumber(self)
		return 4
	end

	local Test2 = LibTSMClass.DefineClass("Test2")
	function Test2.GetNumber(self, test)
		return test:_GetNumber()
	end

	local instTest = Test()
	luaunit.assertErrorMsgContains("Attempting to call protected method (_GetNumber) from outside of class", function() instTest:_GetNumber() end)

	local instTest2 = Test2()
	luaunit.assertErrorMsgContains("Attempting to call protected method (_GetNumber) from outside of class", function() instTest2:GetNumber(instTest) end)

	local TestSub = LibTSMClass.DefineClass("TestSub", Test)
	function TestSub.GetMagicNumber(self)
		return self:_GetNumber()
	end
	luaunit.assertErrorMsgContains("", function() TestSub._GetNumber = function(self) end end)

	local instTestSub = TestSub()
	luaunit.assertEquals(instTestSub:GetMagicNumber(), 4)
	luaunit.assertErrorMsgContains("Attempting to call protected method (_GetNumber) from outside of class", function() instTestSub:_GetNumber() end)
end

function TestLibTSMClass.TestClosure()
	local Test = LibTSMClass.DefineClass("Test")
	function Test.__init(self)
		self.testFunc = self:__closure("_GetNumber")
	end
	function Test.__private._GetNumber(self)
		return 4
	end
	function Test.CallTestFunc(self)
		return self.testFunc()
	end

	local instTest = Test()
	luaunit.assertEquals(instTest.testFunc(), 4)
	luaunit.assertEquals(instTest:CallTestFunc(), 4)

	local TestSub = LibTSMClass.DefineClass("TestSub", Test)
	function TestSub.SubCallTestFunc(self)
		return self.testFunc()
	end

	local instTestSub = TestSub()
	luaunit.assertEquals(instTestSub.testFunc(), 4)
	luaunit.assertEquals(instTestSub:CallTestFunc(), 4)
	luaunit.assertEquals(instTestSub:SubCallTestFunc(), 4)
end

function TestLibTSMClass.TestDump()
	local Test = LibTSMClass.DefineClass("Test")
	function Test.__init(self)
		self.a = 2
		self.b = "hi"
		self.c = {1, 2, 3}
		self.d = {}
		self.e = self
	end

	luaunit.assertEquals(Test.__name, "Test")

	local inst = Test()
	local instStr = tostring(inst)
	luaunit.assertStrMatches(instStr, "^Test:[0-9a-fA-F]+$")

	local output = GetPrintOutput(function() inst:__dump() end)
	luaunit.assertEquals(#output, 7)
	local propertyLines = {output[2], output[3], output[4], output[5], output[6]}
	sort(propertyLines)
	local EXPECTED_PROPERTY_LINES = {
		"  |cff88ccffa|r=2",
		"  |cff88ccffb|r=hi",
		"  |cff88ccffc|r={ ... }",
		"  |cff88ccffd|r={}",
		"  |cff88ccffe|r="..instStr,
	}
	luaunit.assertEquals(propertyLines, EXPECTED_PROPERTY_LINES)
	luaunit.assertEquals(output[7], "}")
end

function TestLibTSMClass.TestDefineClassErrors()
	-- No class name
	luaunit.assertErrorMsgContains("Invalid class name: nil", function() LibTSMClass.DefineClass() end)
	-- Invalid modifier
	luaunit.assertErrorMsgContains("Invalid modifier: INVALID", function() LibTSMClass.DefineClass("Test", nil, "INVALID") end)
	-- Invalid superclass
	luaunit.assertErrorMsgContains("Invalid superclass: INVALID", function() LibTSMClass.DefineClass("Test", "INVALID") end)
end

function TestLibTSMClass.TestErrors()
	local Test = LibTSMClass.DefineClass("Test", nil, "ABSTRACT")
	function Test.__init(self)
		self.a = 2
		self.b = "hi"
		self.c = true
	end
	function Test.GetA(self)
		return self.a
	end
	function Test.__protected.GetB(self)
		return self.b
	end
	function Test.__private.GetC(self)
		return self.c
	end
	function Test.__abstract.GetD(self)
	end
	Test.staticX = 2
	function Test.__static.StaticFunc()
	end

	-- Modifying static members
	luaunit.assertErrorMsgContains("Can't modify or override static members", function() Test.staticX = 3 end)
	-- Setting a reserved property
	luaunit.assertErrorMsgContains("Reserved word: __isa", function() Test.__isa = nil end)
	-- Unnecessary __static
	luaunit.assertErrorMsgContains("Unnecessary __static for non-function class property", function() Test.__static.z = 1 end)

	local TestSub = LibTSMClass.DefineClass("TestSub", Test)

	-- Modifying class after subclassing
	luaunit.assertErrorMsgContains("Can't modify classes after they are subclassed", function() Test.y = 2 end)
	-- Overriding a non-method subclass property
	luaunit.assertErrorMsgContains("Attempting to override non-method superclass property (staticX) with method", function() function TestSub.staticX() end end)
	-- Overriding a public method with a protected method
	luaunit.assertErrorMsgContains("Overriding a public superclass method (GetA) can only be done with a public method", function() function TestSub.__protected.GetA() end end)
	-- Overriding an abstract method with a public method
	luaunit.assertErrorMsgContains("Overriding an abstract superclass method (GetD) can only be done with a protected method", function() function TestSub.GetD() end end)
	-- Overriding a static function with a public method
	luaunit.assertErrorMsgContains("Can't override static superclass property (StaticFunc) with method", function() function TestSub.StaticFunc() end end)
	-- Overriding a private method with a public method
	luaunit.assertErrorMsgContains("Can't override private superclass method (GetC)", function() function TestSub.GetC() end end)
	-- Define abstract method on non-abstract class
	luaunit.assertErrorMsgContains("Can only define abstract methods on abstract classes", function() function TestSub.__abstract.GetE() end end)
	-- Invalid class key
	luaunit.assertErrorMsgContains("Invalid static class key (invalid)", function() return Test.invalid end)
	-- Instantiate abstract class
	luaunit.assertErrorMsgContains("Attempting to instantiate an abstract class", function() Test() end)
	-- Index class with non-string key
	luaunit.assertErrorMsgContains("Can't index class with non-string key", function() TestSub[2] = true end)
	-- Index into __private
	luaunit.assertErrorMsgContains("Can't index into property table", function() return Test.__private.GetA end)

	function TestSub.__protected.GetD(self)
		return {}
	end
	function TestSub.CreateInvalidClosure(self)
		return self:__closure("a")
	end

	-- Return from __init()
	local returnFromInit = false
	function TestSub.__init(self)
		self.__super:__init()
		if returnFromInit then
			return 5
		end
	end
	returnFromInit = true
	luaunit.assertErrorMsgContains("__init(...) must not return any values", function() TestSub() end)
	returnFromInit = false

	local inst = TestSub()

	-- Setting a reserved key
	luaunit.assertErrorMsgContains("Can't set reserved key: __isa", function() inst.__isa = 2 end)
	-- Accessing __super outside of class
	luaunit.assertErrorMsgContains("The superclass can only be referenced within a class method", function() return inst.__super end)
	-- Using __as outside of class
	luaunit.assertErrorMsgContains("The superclass can only be referenced within a class method", function() return inst:__as(Test) end)
	-- Calling class method on non-class object
	luaunit.assertErrorMsgContains("Attempt to call class method on non-object (INVALID)", function() inst.GetD("INVALID") end)
	-- Create closure from outside of class
	luaunit.assertErrorMsgContains("Closures can only be created within a class method", function() return inst:__closure("GetD") end)
	-- Create closure for non-method field
	luaunit.assertErrorMsgContains("Attempt to create closure for non-method field", function() inst:CreateInvalidClosure() end)
end



os.exit(luaunit.LuaUnit.run())
