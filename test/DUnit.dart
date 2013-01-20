library DUnit;

// TODO: refactor into seperate library.

/*
 * A minimal port of the QUnit subset that Underscore.js uses.
 */


class _TestTuple {
  String testName;
  Function func;
  bool isAsync = false;
  _TestTuple(this.testName, this.func, {this.isAsync: false});
}

Map<String,List<_TestTuple>> _moduleTests;
Map<String,Function> _modulesStartup;
Map<String,Function> _modulesTeardown;
String _moduleName;
module (name, [Function startup(Function cb), Function teardown]) {
  if (_moduleTests == null) _moduleTests = new Map<String,List<_TestTuple>>();
  if (_modulesStartup == null) _modulesStartup = new Map<String,Function>();
  if (_modulesTeardown == null) _modulesTeardown = new Map<String,Function>();

  _moduleName = name;
  _moduleTests.putIfAbsent(_moduleName, () => new List<_TestTuple>());
  _modulesStartup[_moduleName] = startup;
  _modulesTeardown[_moduleName] = teardown;
}

test(name, Function assertions) {
  _moduleTests[_moduleName].add(new _TestTuple(name, assertions, isAsync: false));
}
asyncTest(name, Function assertions) {
  _moduleTests[_moduleName].add(new _TestTuple(name, assertions, isAsync: true));
}

List<Assertion> _testAssertions;
equal(actual, expected, msg) =>
    _testAssertions.add(new Assertion(actual,expected,msg));
isNull(actual, msg) =>
    _testAssertions.add(new Assertion(actual,null,msg));
isNotNull(actual, msg) =>
    _testAssertions.add(new Assertion(actual,null,msg,notEqual:true));
notEqual(actual, expected, msg) =>
    _testAssertions.add(new Assertion(actual,expected,msg,notEqual:true));
deepEqual(actual, expected, msg) =>
    _testAssertions.add(new Assertion(actual,expected,msg,deepEqual:true));
notDeepEqual(actual, expected, msg) =>
    _testAssertions.add(new Assertion(actual,expected,msg,deepEqual:true,notEqual:true));
strictEqual(actual, expected, msg) =>
    _testAssertions.add(new Assertion(actual,expected,msg,strictEqual:true));
notStrictEqual(actual, expected, msg) =>
    _testAssertions.add(new Assertion(actual,expected,msg,strictEqual:true,notEqual:true));
ok(actual, msg) =>
  _testAssertions.add(new Assertion(actual,true,msg));

Function _start;
Function _next;
start() => _start();

raises(actualFn, expectedTypeFn, msg) {
  try {
    var actual = actualFn();
    _testAssertions.add(new Assertion(actual,"expected error",msg));
  }
  catch (e) {
    if (expectedTypeFn(e)) {
      _testAssertions.add(new Assertion(true,true,msg));
    } else {
      _testAssertions.add(new Assertion(e,"wrong error type",msg));
    }
  }
}

runAllTests({bool hidePassedTests: false}){
  int totalTests = 0;
  int totalPassed = 0;
  int totalFailed = 0;
  Stopwatch sw = new Stopwatch();
  sw.start();

  Queue<String> moduleNames = new Queue<String>.from(_moduleTests.keys);
  Queue<_TestTuple> moduleTests = new Queue<_TestTuple>();
  String moduleName;
  _TestTuple _test;
  int testNo = 0;

  _end(){
    print("\nTests completed in ${sw.elapsedMilliseconds}ms");
    print("$totalTests tests of $totalPassed passed, $totalFailed failed.");
  }

  _next = (){
    if (moduleTests.length == 0) {
      if (moduleNames.length == 0) return _end();
      moduleName = moduleNames.removeFirst();
      moduleTests = new Queue<_TestTuple>.from(_moduleTests[moduleName]);
      testNo = 0;
      if (!hidePassedTests) print("");
    }
    if (moduleTests.length == 0) return _next();

    _test = moduleTests.removeFirst();
    _testAssertions = new List<Assertion>();

    _start = (){
      String testName = _test.testName;
      String testType = _test.isAsync ? "async" : "sync";

      testNo++;
      String error = null;

      int total = _testAssertions.length;
      int failed = _testAssertions.filter((x) => !x.success()).length;
      int success = total - failed;

      totalTests  += total;
      totalFailed += failed;
      totalPassed += success;

      if (!hidePassedTests || failed > 0) {
        print("$testNo. $moduleName: $testName ($failed, $success, $total)");
      }

      for (int i=0; i<_testAssertions.length; i++) {
        Assertion assertion = _testAssertions[i];
        bool fail = !assertion.success();
        if (!hidePassedTests || fail) {
          print("  ${i+1}. ${assertion.msg}");
          if (assertion.expected is! bool) {
            print("     Expected ${assertion.expected}");
          }
        }
        if (fail) {
          print("     FAILED was ${assertion.actual}");
        }
      }
      if (error != null) print(error);
      Function teardown = _modulesTeardown[moduleName];
      if (teardown != null) teardown();
      _next();
    };

    try {

      Function startup = _modulesStartup[moduleName];
      if (startup != null) {
        startup(([k]) => _test.func());
      }
      else {
        _test.func();
      }
    }
//UnComment to catch and report errors
//    catch(final e){
//      error = "Error while running $testType test #$testNo in $moduleName: $testName\n$e";
//    }
    finally {}
    if (!_test.isAsync) start();
  };

  _next();
}

class Assertion {
  var actual, expected;
  bool deepEqual,strictEqual,notEqual;
  String msg;
  Assertion(this.actual,this.expected,this.msg,{this.deepEqual: false, this.strictEqual: false,this.notEqual: false});
  success() {
    if (strictEqual) return notEqual ? !identical(actual, expected) : identical(actual, expected);
    if (!deepEqual) return notEqual ? actual != expected : actual == expected;
    bool isEqual = _eq(actual, expected);
    return notEqual ? !isEqual : isEqual;
  }
}

_eq(actual, expected) {
  if (actual == null || expected == null) {
    return actual == expected;
  }

  if (actual is Map) {
    if (expected is! Map) return false;
    if (actual.length != expected.length) return false;
    for (var key in actual.keys)
      if (!_eq(actual[key], expected[key])) return false;
    return true;
  }
  else if (actual is List) {
    if (expected is! List) return false;
    if (actual.length != expected.length) return false;
    int i=0;
    return actual.every((x) => _eq(x, expected[i++]));
  }

  return actual == expected;
}