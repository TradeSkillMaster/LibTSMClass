-- test framework
luaunit = require('Tests.Unit.Include.luaunit')

-- wow globals
strmatch = string.match

-- code under test
require('LibStub.LibStub')
require('LibTSMClass')
LibTSMClass = LibStub("LibTSMClass")



TestLibTSMClass = {}
function TestLibTSMClass:TestBasic()
	local Test = LibTSMClass:DefineClass("Test")
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

function TestLibTSMClass:TestSubClass()
	local Test = LibTSMClass:DefineClass("Test")
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

	local TestSub = LibTSMClass:DefineClass("TestSub", Test)
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

function TestLibTSMClass:TestStatic()
	local Test = LibTSMClass:DefineClass("Test")
	Test.staticX = 39

	local TestSub = LibTSMClass:DefineClass("TestSub", Test)
	TestSub.staticY = 32

	local testInst = Test()
	luaunit.assertEquals(testInst.staticX, 39)
	luaunit.assertEquals(testInst.staticY, nil)

	testInst.staticX = 11
	luaunit.assertEquals(testInst.staticX, 11)

	local testSubInst = TestSub()
	luaunit.assertEquals(testSubInst.staticX, 39)
	luaunit.assertEquals(testSubInst.staticY, 32)
end

function TestLibTSMClass:TestVirtual()
	local Test = LibTSMClass:DefineClass("Test")
	function Test.TestVirtual(self)
		return 111
	end
	function Test.TestVirtualCaller(self)
		return self:TestVirtual()
	end
	function Test.TestVirtualCaller2(self)
		return self:TestVirtual2()
	end

	local TestSub = LibTSMClass:DefineClass("TestSub", Test)
	function TestSub.TestVirtual(self)
		return 777
	end
	function TestSub.TestVirtual2(self)
		return 333
	end

	local testSubInst = TestSub()
	luaunit.assertEquals(testSubInst:TestVirtual(), 777)
	luaunit.assertEquals(testSubInst:TestVirtualCaller(), 777)
	luaunit.assertEquals(testSubInst:TestVirtual2(), 333)
	luaunit.assertEquals(testSubInst:TestVirtualCaller2(), 333)
end



os.exit(luaunit.LuaUnit.run())
