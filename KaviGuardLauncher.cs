using System;
using System.Management.Automation;
using System.Windows.Forms;

// KaviGuard launcher: runs the dashboard GUI script inside this process.
// Built as a windowed exe with the KaviGuard shield embedded, so the
// taskbar shows the right icon and pinning groups correctly. No console,
// no wscript, no hidden-window tricks needed.
public static class KaviGuardLauncher
{
    [STAThread]
    public static void Main()
    {
        string scriptPath = @"C:\Tools\KaviGuard\KaviGuard-Gui.ps1";
        try
        {
            string script = System.IO.File.ReadAllText(scriptPath);
            using (PowerShell ps = PowerShell.Create())
            {
                ps.AddScript(script);
                ps.Invoke();
            }
        }
        catch { }
    }
}
