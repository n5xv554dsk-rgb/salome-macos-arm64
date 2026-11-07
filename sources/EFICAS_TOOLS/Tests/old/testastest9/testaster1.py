import basetest

files="[a-l]*.comm"
TestCase=basetest.make_tests(files)
class TestCase(TestCase):pass
