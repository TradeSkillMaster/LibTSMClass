-- test framework
luaunit = require('Tests.Unit.Include.luaunit')
require('Tests.Unit.Include.wowunit')

-- code under test
require('LibStub.LibStub')
require('LibTSMClass')
LibTSMClass = LibStub("LibTSMClass")



TestLibTSMClass = {}
function TestLibTSMClass.TestBasic()
	local TestBasic = LibTSMClass.DefineClass("TestBasic")
	function TestBasic.__init(self)
		if not self.initialized then
			self.initialized = true
			self.value = 2
		end
	end
	function TestBasic.GetValue(self)
		return self.value
	end

	local testInst = TestBasic()
	luaunit.assertTrue(testInst.initialized)
	luaunit.assertEquals(testInst:GetValue(), 2)

	local testInst2 = LibTSMClass.ConstructWithTable({ initialized = true, value = 5 }, TestBasic)
	luaunit.assertTrue(testInst2.initialized)
	luaunit.assertEquals(testInst2:GetValue(), 5)
end

function TestLibTSMClass.TestSubClass()
	local TestSubClass = LibTSMClass.DefineClass("TestSubClass")
	function TestSubClass.__init(self)
		self.initialized = true
		self.n = 2
	end
	function TestSubClass.GetMagicNumber(self)
		return 0
	end
	function TestSubClass.Echo(self, ...)
		return ...
	end

	local TestSubClassSub = LibTSMClass.DefineClass("TestSubClassSub", TestSubClass)
	function TestSubClassSub.__init(self)
		self.__super:__init()
		self.subInitialized = true
	end
	function TestSubClassSub.GetMagicNumber(self)
		return self.__super:GetMagicNumber() + 1
	end
	function TestSubClassSub.GetText(self)
		return "TEXT"
	end

	luaunit.assertTrue(TestSubClass:__isa(TestSubClass))
	luaunit.assertTrue(TestSubClassSub:__isa(TestSubClass))
	luaunit.assertTrue(TestSubClassSub:__isa(TestSubClassSub))

	local testSubInst = TestSubClassSub()
	luaunit.assertTrue(testSubInst:__isa(TestSubClass))
	luaunit.assertTrue(testSubInst:__isa(TestSubClassSub))
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
	local TestStatic = LibTSMClass.DefineClass("TestStatic")
	function TestStatic.__static.GetA()
		return 95
	end
	function TestStatic.__static.GetZ()
		return 52
	end
	TestStatic.staticX = 39

	local TestStaticSub = LibTSMClass.DefineClass("TestStaticSub", TestStatic)
	function TestStaticSub.__static.GetZ()
		return 77
	end
	TestStaticSub.staticX = 9
	TestStaticSub.staticY = 32

	luaunit.assertEquals(TestStatic.GetZ(), 52)
	luaunit.assertEquals(TestStaticSub.GetZ(), 77)
	luaunit.assertEquals(TestStatic.GetA(), 95)
	luaunit.assertEquals(TestStaticSub.GetA(), 95)

	local testInst = TestStatic()
	luaunit.assertEquals(testInst.staticX, 39)
	luaunit.assertEquals(testInst.staticY, nil)

	testInst.staticX = 11
	luaunit.assertEquals(testInst.staticX, 11)
	luaunit.assertEquals(TestStatic.staticX, 39)

	local testSubInst = TestStaticSub()
	luaunit.assertEquals(testSubInst.staticX, 9)
	luaunit.assertEquals(testSubInst.staticY, 32)
end

function TestLibTSMClass.TestVirtual()
	local TestVirtual = LibTSMClass.DefineClass("TestVirtual")
	function TestVirtual.VirtualMethod(self)
		return 111
	end
	function TestVirtual.VirtualMethodCaller(self)
		return self:VirtualMethod()
	end
	function TestVirtual.VirtualMethodCaller2(self)
		return self:VirtualMethod2()
	end

	local TestVirtualSub = LibTSMClass.DefineClass("TestVirtualSub", TestVirtual)
	function TestVirtualSub.VirtualMethod(self)
		return 777
	end
	function TestVirtualSub.VirtualMethod2(self)
		return 333
	end

	local testSubInst = TestVirtualSub()
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
	local TestAbstract = LibTSMClass.DefineClass("TestAbstract", nil, "ABSTRACT")
	function TestAbstract.__init(self)
		self.initialized = true
		self.n = 2
	end
	function TestAbstract.GetMagicNumber(self)
		return 0
	end
	function TestAbstract.GetMagicPhrase(self)
		return self:GetText()
	end
	function TestAbstract.__abstract._GetTextImpl()
	end
	function TestAbstract.GetText(self)
		return self:_GetTextImpl()
	end

	local TestAbstractSub = LibTSMClass.DefineClass("TestAbstractSub", TestAbstract)
	function TestAbstractSub.__init(self)
		self.__super:__init()
		self.subInitialized = true
	end
	function TestAbstractSub.GetMagicNumber(self)
		return self.__super:GetMagicNumber() + 1
	end

	luaunit.assertErrorMsgContains("Missing abstract method: _GetTextImpl", function() TestAbstractSub() end)

	function TestAbstractSub.__protected._GetTextImpl(self)
		return "TEXT"
	end
	function TestAbstractSub.GetTextFail(self)
		return self.__super:_GetTextImpl()
	end

	local inst = TestAbstractSub()
	luaunit.assertEquals(inst:GetText(), "TEXT")
	luaunit.assertErrorMsgContains("attempt to call method '_GetTextImpl' (a nil value)", function() inst:GetTextFail() end)
end

function TestLibTSMClass.TestPrivateMethod()
	local TestPrivate = LibTSMClass.DefineClass("TestPrivate")
	function TestPrivate.__private.GetMagicNumber(self)
		return 0
	end
	function TestPrivate.GetMagicPhrase(self)
		return "NUMBER: "..self:GetMagicNumber()
	end

	local inst = TestPrivate()
	luaunit.assertErrorMsgContains("Attempting to call private method (GetMagicNumber) from outside of class", function() inst:GetMagicNumber() end)
	luaunit.assertEquals(inst:GetMagicPhrase(), "NUMBER: 0")
end

function TestLibTSMClass.TestProtectedMethod()
	local TestProtected = LibTSMClass.DefineClass("TestProtected")
	function TestProtected.__protected._GetNumber(self)
		return 4
	end

	local TestProtected2 = LibTSMClass.DefineClass("TestProtected2")
	function TestProtected2.GetNumber(self, test)
		return test:_GetNumber()
	end

	local instTest = TestProtected()
	luaunit.assertErrorMsgContains("Attempting to call protected method (_GetNumber) from outside of class", function() instTest:_GetNumber() end)

	local instTest2 = TestProtected2()
	luaunit.assertErrorMsgContains("Attempting to call protected method (_GetNumber) from outside of class", function() instTest2:GetNumber(instTest) end)

	local TestProtectedSub = LibTSMClass.DefineClass("TestProtectedSub", TestProtected)
	function TestProtectedSub.GetMagicNumber(self)
		return self:_GetNumber()
	end
	luaunit.assertErrorMsgContains("", function() TestProtectedSub._GetNumber = function(self) end end)

	local instTestSub = TestProtectedSub()
	luaunit.assertEquals(instTestSub:GetMagicNumber(), 4)
	luaunit.assertErrorMsgContains("Attempting to call protected method (_GetNumber) from outside of class", function() instTestSub:_GetNumber() end)
end

function TestLibTSMClass.TestClosure()
	local TestClosure = LibTSMClass.DefineClass("TestClosure")
	function TestClosure.__init(self)
		self.testFunc = self:__closure("_GetNumber")
	end
	function TestClosure.__private._GetNumber(self)
		return 4
	end
	function TestClosure.CallTestFunc(self)
		return self.testFunc()
	end

	local instTest = TestClosure()
	luaunit.assertEquals(instTest.testFunc(), 4)
	luaunit.assertEquals(instTest:CallTestFunc(), 4)

	local TestClosureSub = LibTSMClass.DefineClass("TestClosureSub", TestClosure)
	function TestClosureSub.SubCallTestFunc(self)
		return self.testFunc()
	end

	local instTestSub = TestClosureSub()
	luaunit.assertEquals(instTestSub.testFunc(), 4)
	luaunit.assertEquals(instTestSub:CallTestFunc(), 4)
	luaunit.assertEquals(instTestSub:SubCallTestFunc(), 4)
end

function TestLibTSMClass.TestDebugInfo()
	local TestDebugInfo = LibTSMClass.DefineClass("TestDebugInfo")
	function TestDebugInfo.__init(self)
		self.a = 2
		self.b = "hi"
		self.c = {1, 2, 3}
		self.d = {}
		self.e = TestDebugInfo
	end

	luaunit.assertEquals(TestDebugInfo.__name, "TestDebugInfo")

	local inst = TestDebugInfo()
	local instStr = tostring(inst)
	luaunit.assertStrMatches(instStr, "^TestDebugInfo:[0-9a-fA-F]+$")

	local debugLines = {strsplit("\n", LibTSMClass.GetDebugInfo(instStr))}
	luaunit.assertEquals(#debugLines, 11)
	local debugLinesContainedVar = { a = false, b = false, c = false, d = false, e = false }
	local i = 1
	while i <= #debugLines do
		local line = debugLines[i]
		if i == 1 then
			luaunit.assertEquals(line, "self = <"..instStr.."> {")
		elseif i == #debugLines then
			luaunit.assertEquals(line, "}")
		else
			local varName = strmatch(line, "%s+([a-z0-9]+) = ")
			luaunit.assertEquals(debugLinesContainedVar[varName], false)
			debugLinesContainedVar[varName] = true
			if varName == "a" then
			elseif varName == "b" then
			elseif varName == "c" then
				luaunit.assertEquals(line, "  c = {")
				luaunit.assertEquals(debugLines[i+1], "    1 = 1")
				luaunit.assertEquals(debugLines[i+2], "    2 = 2")
				luaunit.assertEquals(debugLines[i+3], "    3 = 3")
				luaunit.assertEquals(debugLines[i+4], "  }")
				i = i + 4
			elseif varName == "d" then
				luaunit.assertEquals(line, "  d = {}")
			elseif varName == "e" then
				luaunit.assertEquals(line, "  e = \"class:TestDebugInfo\"")
			else
				luaunit.assertTrue(false)
			end
		end
		i = i + 1
	end
end

function TestLibTSMClass.TestDefineClassErrors()
	-- No class name
	luaunit.assertErrorMsgContains("Invalid class name: nil", function() LibTSMClass.DefineClass() end)
	-- Invalid modifier
	luaunit.assertErrorMsgContains("Invalid modifier: INVALID", function() LibTSMClass.DefineClass("TestInvalidModifier", nil, "INVALID") end)
	-- Invalid superclass
	luaunit.assertErrorMsgContains("Invalid superclass: INVALID", function() LibTSMClass.DefineClass("TestInvalidSuperclass", "INVALID") end)
end

function TestLibTSMClass.TestErrors()
	local TestErrors = LibTSMClass.DefineClass("TestErrors", nil, "ABSTRACT")
	function TestErrors.__init(self)
		self.a = 2
		self.b = "hi"
		self.c = true
	end
	function TestErrors.GetA(self)
		return self.a
	end
	function TestErrors.__protected.GetB(self)
		return self.b
	end
	function TestErrors.__private.GetC(self)
		return self.c
	end
	function TestErrors.__abstract.GetD(self)
	end
	TestErrors.staticX = 2
	function TestErrors.__static.StaticFunc()
	end

	-- Modifying static members
	luaunit.assertErrorMsgContains("Can't modify or override static members", function() TestErrors.staticX = 3 end)
	-- Setting a reserved property
	luaunit.assertErrorMsgContains("Reserved word: __isa", function() TestErrors.__isa = nil end)
	-- Unnecessary __static
	luaunit.assertErrorMsgContains("Unnecessary __static for non-function class property", function() TestErrors.__static.z = 1 end)

	local TestErrorsSub = LibTSMClass.DefineClass("TestErrorsSub", TestErrors)

	-- Modifying class after subclassing
	luaunit.assertErrorMsgContains("Can't modify classes after they are subclassed", function() TestErrors.y = 2 end)
	-- Overriding a non-method subclass property
	luaunit.assertErrorMsgContains("Attempting to override non-method superclass property (staticX) with method", function() function TestErrorsSub.staticX() end end)
	-- Overriding a public method with a protected method
	luaunit.assertErrorMsgContains("Overriding a public superclass method (GetA) can only be done with a public method", function() function TestErrorsSub.__protected.GetA() end end)
	-- Overriding an abstract method with a public method
	luaunit.assertErrorMsgContains("Overriding an abstract superclass method (GetD) can only be done with a protected method", function() function TestErrorsSub.GetD() end end)
	-- Overriding a static function with a public method
	luaunit.assertErrorMsgContains("Can't override static superclass property (StaticFunc) with method", function() function TestErrorsSub.StaticFunc() end end)
	-- Overriding a private method with a public method
	luaunit.assertErrorMsgContains("Can't override private superclass method (GetC)", function() function TestErrorsSub.GetC() end end)
	-- Define abstract method on non-abstract class
	luaunit.assertErrorMsgContains("Can only define abstract methods on abstract classes", function() function TestErrorsSub.__abstract.GetE() end end)
	-- Invalid class key
	luaunit.assertErrorMsgContains("Invalid static class key (invalid)", function() return TestErrors.invalid end)
	-- Instantiate abstract class
	luaunit.assertErrorMsgContains("Attempting to instantiate an abstract class", function() TestErrors() end)
	-- Index class with non-string key
	luaunit.assertErrorMsgContains("Can't index class with non-string key", function() TestErrorsSub[2] = true end)
	-- Index into __private
	luaunit.assertErrorMsgContains("Can't index into property table", function() return TestErrors.__private.GetA end)

	function TestErrorsSub.__protected.GetD(self)
		return {}
	end
	function TestErrorsSub.CreateInvalidClosure(self)
		return self:__closure("a")
	end

	-- Return from __init()
	local returnFromInit = false
	function TestErrorsSub.__init(self)
		self.__super:__init()
		if returnFromInit then
			return 5
		end
	end
	returnFromInit = true
	luaunit.assertErrorMsgContains("__init(...) must not return any values", function() TestErrorsSub() end)
	returnFromInit = false

	local inst = TestErrorsSub()

	-- Setting a reserved key
	luaunit.assertErrorMsgContains("Can't set reserved key: __isa", function() inst.__isa = 2 end)
	-- Accessing __super outside of class
	luaunit.assertErrorMsgContains("The superclass can only be referenced within a class method", function() return inst.__super end)
	-- Using __as outside of class
	luaunit.assertErrorMsgContains("The superclass can only be referenced within a class method", function() return inst:__as(TestErrors) end)
	-- Calling class method on non-class object
	luaunit.assertErrorMsgContains("Attempt to call class method on non-object (INVALID)", function() inst.GetD("INVALID") end)
	-- Create closure from outside of class
	luaunit.assertErrorMsgContains("Closures can only be created within a class method", function() return inst:__closure("GetD") end)
	-- Create closure for non-method field
	luaunit.assertErrorMsgContains("Attempt to create closure for non-method field", function() inst:CreateInvalidClosure() end)
end



os.exit(luaunit.LuaUnit.run())
