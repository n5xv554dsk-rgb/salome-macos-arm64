import basetest

files="s[a-d]*.comm"
TestCase=basetest.make_tests(files)
class TestCase(TestCase):pass
