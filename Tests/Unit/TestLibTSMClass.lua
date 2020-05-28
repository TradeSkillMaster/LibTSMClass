-- test framework
luaunit = require('Tests.Unit.Include.luaunit')

-- wow globals
strmatch = string.match
format = string.format

-- code under test
require('LibStub.LibStub')
require('LibTSMClass')
LibTSMClass = LibStub("LibTSMClass")



TestLibTSMClass = {}
function TestLibTSMClass.TestBasic()
	local Test = LibTSMClass.DefineClass("Test")
	function Test.__init(self)
		self.initialized = true
	end
	function Test.GetMagicNumber(self)
		return 0
	end

	local testInst = Test()
	luaunit.assertTrue(testInst.initialized)
	luaunit.assertEquals(testInst:GetMagicNumber(), 0)
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
	function Test.__static.GetZ()
		return 52
	end
	Test.staticX = 39

	local TestSub = LibTSMClass.DefineClass("TestSub", Test)
	function TestSub.__static.GetZ()
		return 77
	end
	TestSub.staticY = 32

	luaunit.assertEquals(Test.GetZ(), 52)
	luaunit.assertEquals(TestSub.GetZ(), 77)

	local testInst = Test()
	luaunit.assertEquals(testInst.staticX, 39)
	luaunit.assertEquals(testInst.staticY, nil)

	testInst.staticX = 11
	luaunit.assertEquals(testInst.staticX, 11)

	local testSubInst = TestSub()
	luaunit.assertEquals(testSubInst.staticX, 39)
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
	luaunit.assertError(function() testCInst:BDoTestSuper2() end)
	luaunit.assertEquals(testCInst:BDoTestAsA(), "A")
	luaunit.assertEquals(testCInst:BDoTestAsB(), "B")
	luaunit.assertEquals(testCInst:BDoTestAsC(), "C")
	luaunit.assertError(function() testCInst:ADoTestSuper1() end)
	luaunit.assertError(function() testCInst:ADoTestSuper2() end)
	luaunit.assertEquals(testCInst:ADoTestAsA(), "A")
	luaunit.assertEquals(testCInst:ADoTestAsB(), "B")
	luaunit.assertEquals(testCInst:ADoTestAsC(), "C")

	local testBInst = B()
	luaunit.assertEquals(tostring(testBInst), "B_STR")
	luaunit.assertEquals(testBInst:GetLetter(), "B")
	luaunit.assertEquals(testCInst:BDoTestSuper1(), "A")
	luaunit.assertError(function() testBInst:ADoTestSuper2() end)
	luaunit.assertEquals(testBInst:BDoTestAsA(), "A")
	luaunit.assertEquals(testBInst:BDoTestAsB(), "B")
	luaunit.assertError(function() testBInst:BDoTestAsC() end)

	local testAInst = A()
	luaunit.assertEquals(tostring(testAInst), "A_STR")
	luaunit.assertEquals(testAInst:GetLetter(), "A")
	luaunit.assertError(function() testAInst:ADoTestSuper1() end)
	luaunit.assertError(function() testAInst:ADoTestSuper2() end)
	luaunit.assertError(function() testAInst:ADoTestAsA() end)
	luaunit.assertError(function() testAInst:ADoTestAsB() end)
	luaunit.assertError(function() testAInst:ADoTestAsC() end)
end



os.exit(luaunit.LuaUnit.run())
