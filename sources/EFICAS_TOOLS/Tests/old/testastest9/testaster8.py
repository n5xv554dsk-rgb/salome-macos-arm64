import basetest

files="s[t-z]*.comm"
TestCase=basetest.make_tests(files)
class TestCase(TestCase):pass
