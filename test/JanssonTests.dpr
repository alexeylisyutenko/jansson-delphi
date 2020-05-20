program JanssonTests;
{

  Delphi DUnit Test Project
  -------------------------
  This project contains the DUnit test framework and the GUI/Console test runners.
  Add "CONSOLE_TESTRUNNER" to the conditional defines entry in the project options 
  to use the console test runner.  Otherwise the GUI test runner will be used by 
  default.

}

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}



uses
  Forms,
  TestFramework,
  GUITestRunner,
  TextTestRunner,
  Jansson in '..\Jansson.pas',
  TestArray in 'TestArray.pas',
  TestSimple in 'TestSimple.pas',
  TestUnpack in 'TestUnpack.pas',
  Util in 'Util.pas',
  TestPack in 'TestPack.pas',
  TestObject in 'TestObject.pas',
  TestNumber in 'TestNumber.pas',
  TestLoadb in 'TestLoadb.pas',
  TestLoadCallback in 'TestLoadCallback.pas',
  TestLoad in 'TestLoad.pas',
  TestEqual in 'TestEqual.pas',
  TestVersion in 'TestVersion.pas',
  TestSprintf in 'TestSprintf.pas',
  TestDumpCallback in 'TestDumpCallback.pas',
  TestDump in 'TestDump.pas',
  TestCopy in 'TestCopy.pas';

{$R *.RES}

begin
  Application.Initialize;
  if IsConsole then
    TextTestRunner.RunRegisteredTests
  else
    GUITestRunner.RunRegisteredTests;
end.

