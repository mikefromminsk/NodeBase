set WshShell =  CreateObject("WScript.Shell")
set Link = WshShell.CreateShortcut(WshShell.SpecialFolders("StartUp") & "\MetaBase.lnk")
Link.TargetPath = WshShell.CurrentDirectory & "\MetaBase.exe"
Link.WorkingDirectory = WshShell.CurrentDirectory
Link.Save
set objShellApp = CreateObject("Shell.Application")
objShellApp.open(WshShell.SpecialFolders("StartUp"))