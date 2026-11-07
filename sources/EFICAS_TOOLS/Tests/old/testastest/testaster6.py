import basetest

files="ssl[m-z]*.comm"
TestCase=basetest.make_tests(files)
class TestCase(TestCase):pass
