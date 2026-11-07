import basetest

files="[t-y]*.comm"
TestCase=basetest.make_tests(files)
class TestCase(TestCase):pass
