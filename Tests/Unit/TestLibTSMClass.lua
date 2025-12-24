-- test framework
luaunit = require('Tests.Unit.Include.luaunit')
require('Tests.Unit.Include.wowunit')

-- code under test
require('LibStub.LibStub')
local LibTSMClass, private = unpack(require('LibTSMClass'))



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
	end
	function TestAbstract.__abstract._GetTextImpl()
	end
	function TestAbstract.GetText(self)
		return self:_GetTextImpl()
	end

	local TestAbstractSub = LibTSMClass.DefineClass("TestAbstractSub", TestAbstract)
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

	local TestAbstractSub2 = LibTSMClass.DefineClass("TestAbstractSub2", TestAbstractSub)
	function TestAbstractSub2.__init(self)
		self.__super:__init()
	end

	local inst2 = TestAbstractSub2()
	luaunit.assertEquals(inst2:GetText(), "TEXT")
	luaunit.assertErrorMsgContains("attempt to call method '_GetTextImpl' (a nil value)", function() inst:GetTextFail() end)

	local TestAbstractAbstractSub = LibTSMClass.DefineClass("TestAbstractAbstractSub", TestAbstract, "ABSTRACT")
	local TestAbstractAbstractSub2 = LibTSMClass.DefineClass("TestAbstractAbstractSub2", TestAbstractAbstractSub)
	luaunit.assertErrorMsgContains("Missing abstract method: _GetTextImpl", function() TestAbstractAbstractSub2() end)

	function TestAbstractAbstractSub2.__protected._GetTextImpl(self)
		return "TEXT"
	end

	local inst3 = TestAbstractAbstractSub2()
	luaunit.assertEquals(inst3:GetText(), "TEXT")
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

function TestLibTSMClass.TestPrivateInit()
	local TestPrivateInit = LibTSMClass.DefineClass("TestPrivateInit")
	function TestPrivateInit.__private.__init(self, value)
		self.value = value
		self.value2 = nil
	end
	function TestPrivateInit.__private._SetValue2(self, value)
		self.value2 = value
	end
	function TestPrivateInit.__static.Create(value)
		local inst = TestPrivateInit(value)
		inst:_SetValue2(value * -1)
		return inst
	end

	local TestPrivateInitSub = LibTSMClass.DefineClass("TestPrivateInitSub", TestPrivateInit)
	luaunit.assertErrorMsgContains("Can't override private superclass method", function() function TestPrivateInitSub.__init(self) end end)

	luaunit.assertErrorMsgContains("Attempting to call private method (__init) from outside of class", function() TestPrivateInit(12) end)
	luaunit.assertErrorMsgContains("Attempting to call private method (__init) from outside of class", function() TestPrivateInitSub(12) end)

	local testInst = TestPrivateInit.Create(42)
	luaunit.assertEquals(testInst.value, 42)
	luaunit.assertEquals(testInst.value2, -42)
end

function TestLibTSMClass.TestProtectedInit()
	local TestProtectedInit = LibTSMClass.DefineClass("TestProtectedInit")
	function TestProtectedInit.__protected.__init(self, value)
		self.value = value
		self.value2 = nil
	end
	function TestProtectedInit.__protected._SetValue2(self, value)
		self.value2 = value
	end
	function TestProtectedInit.__static.Create(value)
		local inst = TestProtectedInit(value)
		inst:_SetValue2(value * -1)
		return inst
	end

	local TestProtectedInitSub = LibTSMClass.DefineClass("TestProtectedInitSub", TestProtectedInit)
	luaunit.assertErrorMsgContains("Overriding a protected superclass method (__init) can only be done with a protected method", function() function TestProtectedInitSub.__init(self) end end)
	function TestProtectedInitSub.__protected.__init(self, value, value3)
		self.__super:__init(value)
		self.value3 = value3
	end
	function TestProtectedInitSub.__protected._SetValue2(self, value)
		self.__super:_SetValue2(value)
	end
	function TestProtectedInitSub.__static.Create(value, value3)
		local inst = TestProtectedInitSub(value, value3)
		inst:_SetValue2(value * -1)
		return inst
	end

	local TestProtectedInitSubSub = LibTSMClass.DefineClass("TestProtectedInitSubSub", TestProtectedInitSub)
	function TestProtectedInitSubSub.__static.Create(value, value3)
		local inst = TestProtectedInitSubSub(value, value3)
		inst:_SetValue2(value + 1)
		return inst
	end

	luaunit.assertErrorMsgContains("Attempting to call protected method (__init) from outside of class", function() TestProtectedInit(12) end)
	luaunit.assertErrorMsgContains("Attempting to call protected method (__init) from outside of class", function() TestProtectedInitSub(12) end)

	local testInst = TestProtectedInit.Create(42)
	luaunit.assertEquals(testInst.value, 42)
	luaunit.assertEquals(testInst.value2, -42)

	local testInstSub = TestProtectedInitSub.Create(42, 11)
	luaunit.assertEquals(testInstSub.value, 42)
	luaunit.assertEquals(testInstSub.value2, -42)
	luaunit.assertEquals(testInstSub.value3, 11)

	local testInstSub = TestProtectedInitSubSub.Create(42, 11)
	luaunit.assertEquals(testInstSub.value, 42)
	luaunit.assertEquals(testInstSub.value2, 43)
	luaunit.assertEquals(testInstSub.value3, 11)
end

function TestLibTSMClass.TestClosure()
	local TestClosureBase = LibTSMClass.DefineClass("TestClosureBase", nil, "ABSTRACT")
	function TestClosureBase.__init(self)
		self.testFunc3 = self:__closure("_GetValue")
	end
	function TestClosureBase.__abstract._GetValue(self)
	end
	function TestClosureBase.CallTestFunc3(self)
		return self.testFunc3()
	end

	local TestClosure = LibTSMClass.DefineClass("TestClosure", TestClosureBase)
	function TestClosure.__init(self)
		self.__super:__init()
		self.testFunc = self:__closure("_GetNumber")
		self.testFunc2 = self:__closure("_GetString")
	end
	function TestClosure.__protected._GetValue(self)
		return 72
	end
	function TestClosure.__private._GetNumber(self)
		return 4
	end
	function TestClosure.__protected._GetString(self)
		return "a"
	end
	function TestClosure.CallTestFunc(self)
		return self.testFunc()
	end
	function TestClosure.CallTestFunc2(self)
		return self.testFunc2()
	end

	local instTest = TestClosure()
	luaunit.assertEquals(instTest.testFunc(), 4)
	luaunit.assertEquals(instTest:CallTestFunc(), 4)
	luaunit.assertEquals(instTest:CallTestFunc2(), "a")
	luaunit.assertEquals(instTest:CallTestFunc3(), 72)

	local TestClosureSub = LibTSMClass.DefineClass("TestClosureSub", TestClosure)
	function TestClosureSub.SubCallTestFunc(self)
		return self.testFunc()
	end
	function TestClosureSub.__protected._GetString(self)
		return "b"
	end

	local instTestSub = TestClosureSub()
	luaunit.assertEquals(instTestSub.testFunc(), 4)
	luaunit.assertEquals(instTestSub:CallTestFunc(), 4)
	luaunit.assertEquals(instTestSub:CallTestFunc2(), "b")
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
		self.f = {self.a, self.d, {[""] = {9}}}
	end

	luaunit.assertEquals(TestDebugInfo.__name, "TestDebugInfo")

	luaunit.assertIsNil(LibTSMClass.GetDebugInfo("TestDebugInfo:xxxx"))

	local inst = TestDebugInfo()
	local instStr = tostring(inst)
	luaunit.assertStrMatches(instStr, "^TestDebugInfo:[0-9a-fA-F]+$")

	local debugInfoStr = LibTSMClass.GetDebugInfo(instStr)
	local debugLines = {strsplit("\n", debugInfoStr)}
	luaunit.assertEquals(#debugLines, 18)
	local debugLinesContainedVar = { a = false, b = false, c = false, d = false, e = false, f = false }
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
			elseif varName == "f" then
				luaunit.assertEquals(line, "  f = {")
				luaunit.assertEquals(debugLines[i+1], "    1 = 2")
				luaunit.assertEquals(debugLines[i+2], "    2 = \"REF{.d}\"")
				luaunit.assertEquals(debugLines[i+3], "    3 = {")
				luaunit.assertEquals(debugLines[i+4], "      \"\" = { ... }")
				luaunit.assertEquals(debugLines[i+5], "    }")
				luaunit.assertEquals(debugLines[i+6], "  }")
				i = i + 6
			else
				luaunit.assertTrue(false)
			end
		end
		i = i + 1
	end

	-- Capture the printed output from __dump() and make sure it matches the debug info from above
	local dumpLines = {}
	local origPrint = print
	print = function(line, ...)
		assert(select("#", ...) == 0)
		-- Strip any colors
		line = gsub(line, "|cff[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]([^|]*)|r", "%1")
		tinsert(dumpLines, line)
	end
	local success, errMsg = pcall(function() inst:__dump() end)
	print = origPrint
	assert(success, errMsg)
	luaunit.assertEquals(dumpLines, debugLines)
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
	function TestErrors.CreateInvalidClosure4(self)
		return self:__closure("GetE")
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
	function TestErrorsSub.__private.GetE(self)
		return 222
	end
	function TestErrorsSub.CreateInvalidClosure(self)
		return self:__closure("a")
	end
	function TestErrorsSub.CreateInvalidClosure2(self)
		return self:__closure("GetC")
	end
	function TestErrorsSub.CreateInvalidClosure3(self)
		return self.__super:__closure("GetB")
	end
	function TestErrorsSub.CallPrivate(self)
		return self:GetC()
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

	local function CleanPrivateState()
		local instInfo = private.instInfo[inst]
		if instInfo.methodClass then
			instInfo.methodClass = nil
			private.classInfo[TestErrors].inClassFunc = 0
			private.classInfo[TestErrorsSub].inClassFunc = 0
		end
	end

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
	CleanPrivateState()
	-- Cannot create closure for superclass private method
	luaunit.assertErrorMsgContains("Attempt to create closure for private superclass method", function() return inst:CreateInvalidClosure2() end)
	CleanPrivateState()
	-- Cannot create closure as superclass
	luaunit.assertErrorMsgContains("Cannot create closure as superclass", function() return inst:CreateInvalidClosure3() end)
	CleanPrivateState()
	-- Cannot create closure for virtual private method
	luaunit.assertErrorMsgContains("Attempt to create closure for private virtual method", function() return inst:CreateInvalidClosure4() end)
	CleanPrivateState()
	-- Calling a private superclass method from outside of class method
	luaunit.assertErrorMsgContains("Attempting to call private method (GetC) from outside of class", function() inst:GetC() end)
	-- Calling a private superclass method from within a subclass
	luaunit.assertErrorMsgContains("Attempting to call private method (GetC) from outside of class", function() inst:CallPrivate() end)
end

function TestLibTSMClass.TestGC()
	local TestGC = LibTSMClass.DefineClass("TestGC")
	local inst1 = TestGC()

	local instances = setmetatable({}, { __mode = "kv" })
	instances[inst1] = true

	inst1 = nil

	luaunit.assertNotEquals(instances, {})
	collectgarbage()
	luaunit.assertEquals(instances, {})
end

function TestLibTSMClass.TestExtend()
	local TestExtend = LibTSMClass.DefineClass("TestExtend")
	function TestExtend.__private:_GetPrivateValue()
		return 45
	end

	local inst1 = TestExtend()

	local TestExtendExtensions = TestExtend:__extend()

	function TestExtendExtensions:GetValue()
		return 21
	end

	luaunit.assertEquals(inst1:GetValue(), 21)
	luaunit.assertEquals(TestExtend():GetValue(), 21)

	function TestExtendExtensions:GetValue2()
		return self:_GetPrivateValue()
	end

	luaunit.assertErrorMsgContains("Attempting to call private method (_GetPrivateValue) from outside of class", function() inst1:GetValue2() end)
end

function TestLibTSMClass.TestEquals()
	local TestEquals = LibTSMClass.DefineClass("TestEquals")
	function TestEquals:__init(value)
		self._value = value
	end
	function TestEquals:__equals(other)
		-- Defer to a private method to show we can access private methods on `other`
		return self:_GetValue() == other:_GetValue()
	end
	function TestEquals.__private:_GetValue()
		return self._value
	end

	local TestEqualsSub = LibTSMClass.DefineClass("TestEqualsSub", TestEquals)

	local inst = TestEquals(42)
	local instSub = TestEqualsSub(77)

	luaunit.assertTrue(inst == inst)
	luaunit.assertTrue(inst == TestEquals(42))
	luaunit.assertTrue(inst ~= TestEquals(77))
	luaunit.assertTrue(inst ~= instSub)
	luaunit.assertTrue(instSub == TestEqualsSub(77))
	-- Different classes are never equal
	luaunit.assertTrue(TestEquals(77) ~= TestEqualsSub(77))
end



os.exit(luaunit.LuaUnit.run())
