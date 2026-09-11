param (
    [Parameter(Mandatory=$true)]
    [string]$FilePath,

    [Parameter(Mandatory=$false)]
    [string]$FixedDestination = "",

    [Parameter(Mandatory=$false)]
    [switch]$AutoSubfolder,

    [Parameter(Mandatory=$false)]
    [string]$DefaultPickerFolder = "",

    [Parameter(Mandatory=$false)]
    [switch]$SkipSubfolderPrompt,

    [Parameter(Mandatory=$false)]
    [switch]$OpenDestination
)

# ---------------------------------------------------------------------------
# Registry config resolution
# During installation, paths are stored under HKLM\SOFTWARE\CopyWithRAW.
# Special tokens allow the installer to reference these values without
# hardcoding paths into the registry command strings.
# ---------------------------------------------------------------------------
$regBase = "HKLM:\SOFTWARE\CopyWithRAW"
$regConfig = Get-ItemProperty -Path $regBase -ErrorAction SilentlyContinue

if ($FixedDestination -eq "WL:") {
    $FixedDestination = if ($regConfig) { $regConfig.WLDestination } else { "" }
}
if ($DefaultPickerFolder -eq "PICKER:") {
    $DefaultPickerFolder = if ($regConfig) { $regConfig.DefaultPickerFolder } else { "" }
}

# Base temp directory
$tempBase = Join-Path $env:TEMP "CopyWithRaw"
if (-not (Test-Path $tempBase)) {
    New-Item -ItemType Directory -Path $tempBase | Out-Null
}

# Clean up any session folders older than 60 seconds to avoid accumulation
Get-ChildItem -Path $tempBase -Directory -ErrorAction SilentlyContinue | Where-Object {
    $_.LastWriteTime -lt (Get-Date).AddSeconds(-60)
} | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

# Use a shared session ID so all instances in the same batch write to the same subfolder.
# The session marker file holds the current session ID and is only valid for 20 seconds.
$sessionMarkerFile = Join-Path $tempBase "current_session.txt"
$sessionId = $null

# Try to read an existing recent session ID
if (Test-Path $sessionMarkerFile) {
    $markerAge = (Get-Date) - (Get-Item $sessionMarkerFile).LastWriteTime
    if ($markerAge.TotalSeconds -lt 20) {
        $sessionId = Get-Content $sessionMarkerFile -ErrorAction SilentlyContinue
    }
}

# If no valid session found, create a new one
if ([string]::IsNullOrWhiteSpace($sessionId)) {
    $sessionId = [guid]::NewGuid().ToString()
    $sessionId | Set-Content -Path $sessionMarkerFile -Encoding UTF8
    Start-Sleep -Milliseconds 100  # small delay so other near-simultaneous instances can read it
}

# Write the current file into the session subfolder
$tempDir = Join-Path $tempBase $sessionId
if (-not (Test-Path $tempDir)) {
    New-Item -ItemType Directory -Path $tempDir | Out-Null
}
$uniqueId = [guid]::NewGuid().ToString()
$tempFile = Join-Path $tempDir "$uniqueId.txt"
$FilePath | Set-Content -Path $tempFile -Encoding UTF8

# Try to become the coordinator instance
$mutex = New-Object System.Threading.Mutex($false, "Global\CopyWithRawMutex")
if ($mutex.WaitOne(0)) {
    try {
        # Wait 4 seconds to allow ALL other PowerShell instances to fully start and write their files.
        # FastStone launches instances sequentially and PS startup takes ~1-2s each, so 4s covers 3+ files.
        Start-Sleep -Milliseconds 4000
        
        # Read all recorded files from THIS session only
        $files = Get-ChildItem -Path $tempDir -Filter "*.txt" -ErrorAction SilentlyContinue | ForEach-Object { Get-Content $_.FullName }
        
        $pathsToCopy = New-Object System.Collections.Specialized.StringCollection
        
        $rawExtensions = @('.nef', '.nrw', '.cr2', '.cr3', '.crw', '.arw', '.srf', '.sr2', '.dng', '.raf', '.orf', '.rw2', '.pef', '.srw')
        
        foreach ($file in $files) {
            if ([string]::IsNullOrWhiteSpace($file) -or -not (Test-Path $file)) { continue }
            
            # Add the selected JPEG file
            if (-not $pathsToCopy.Contains($file)) { 
                $pathsToCopy.Add($file) | Out-Null
            }
            
            # Check if it's a JPEG or RAW and find associated files
            $ext = [System.IO.Path]::GetExtension($file).ToLower()
            $jpegExtensions = @('.jpg', '.jpeg')
            
            if ($jpegExtensions -contains $ext) {
                # --- JPEG selected: find matching RAW ---
                $dir = [System.IO.Path]::GetDirectoryName($file)
                $jpegBaseName = [System.IO.Path]::GetFileNameWithoutExtension($file)
                
                $rawFiles = Get-ChildItem -Path $dir -File | Where-Object { $rawExtensions -contains $_.Extension.ToLower() }
                
                $matchedRaw = $null
                $longestMatch = 0
                
                foreach ($raw in $rawFiles) {
                    $rawBase = $raw.BaseName
                    if ($jpegBaseName.StartsWith($rawBase, [System.StringComparison]::InvariantCultureIgnoreCase)) {
                        if ($rawBase.Length -gt $longestMatch) {
                            $longestMatch = $rawBase.Length
                            $matchedRaw = $raw.FullName
                        }
                    }
                }
                
                if ($matchedRaw) {
                    if (-not $pathsToCopy.Contains($matchedRaw)) {
                        $pathsToCopy.Add($matchedRaw) | Out-Null
                    }
                }
                
                # XMP sidecars for JPEG
                $xmp1 = Join-Path $dir ($jpegBaseName + ".xmp")
                if (Test-Path $xmp1) {
                    if (-not $pathsToCopy.Contains($xmp1)) { $pathsToCopy.Add($xmp1) | Out-Null }
                }
                if ($matchedRaw) {
                    $rawBase2 = [System.IO.Path]::GetFileNameWithoutExtension($matchedRaw)
                    $xmp2 = Join-Path $dir ($rawBase2 + ".xmp")
                    if (Test-Path $xmp2) {
                        if (-not $pathsToCopy.Contains($xmp2)) { $pathsToCopy.Add($xmp2) | Out-Null }
                    }
                    $rawFull = [System.IO.Path]::GetFileName($matchedRaw)
                    $xmp3 = Join-Path $dir ($rawFull + ".xmp")
                    if (Test-Path $xmp3) {
                        if (-not $pathsToCopy.Contains($xmp3)) { $pathsToCopy.Add($xmp3) | Out-Null }
                    }
                }
                
            } elseif ($rawExtensions -contains $ext) {
                # --- RAW selected: find matching JPEG ---
                $dir = [System.IO.Path]::GetDirectoryName($file)
                $rawBaseName = [System.IO.Path]::GetFileNameWithoutExtension($file)
                $rawFileName = [System.IO.Path]::GetFileName($file)
                
                # Find JPEGs whose name starts with the RAW base name
                $jpegFiles = Get-ChildItem -Path $dir -File | Where-Object { $jpegExtensions -contains $_.Extension.ToLower() }
                foreach ($jpeg in $jpegFiles) {
                    if ($jpeg.BaseName.StartsWith($rawBaseName, [System.StringComparison]::InvariantCultureIgnoreCase)) {
                        if (-not $pathsToCopy.Contains($jpeg.FullName)) {
                            $pathsToCopy.Add($jpeg.FullName) | Out-Null
                        }
                    }
                }
                
                # XMP sidecars for RAW
                $xmpA = Join-Path $dir ($rawBaseName + ".xmp")
                if (Test-Path $xmpA) {
                    if (-not $pathsToCopy.Contains($xmpA)) { $pathsToCopy.Add($xmpA) | Out-Null }
                }
                $xmpB = Join-Path $dir ($rawFileName + ".xmp")
                if (Test-Path $xmpB) {
                    if (-not $pathsToCopy.Contains($xmpB)) { $pathsToCopy.Add($xmpB) | Out-Null }
                }
            }
        }
        
        if ($pathsToCopy.Count -gt 0) {
            Add-Type -AssemblyName System.Windows.Forms
            Add-Type -AssemblyName System.Drawing

            if ([string]::IsNullOrWhiteSpace($FixedDestination)) {
                # C# code for the modern Windows 10/11 folder picker (Explorer style)
                Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class ModernFolderBrowser
{
    [ComImport]
    [Guid("DC1C5A9C-E88A-4dde-A5A1-60F82A20AEF7")]
    private class FileOpenDialogInternal { }

    [ComImport]
    [Guid("42f85136-db7e-439c-85f1-e4075d135fc8")]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    private interface IFileOpenDialog
    {
        [PreserveSig] uint Show([In] IntPtr parent);
        void SetFileTypes([In] uint cFileTypes, [In] IntPtr rgFilterSpec);
        void SetFileTypeIndex([In] uint iFileType);
        void GetFileTypeIndex(out uint piFileType);
        void Advise([In, MarshalAs(UnmanagedType.Interface)] IntPtr pfde, out uint pdwCookie);
        void Unadvise([In] uint dwCookie);
        void SetOptions([In] uint fos);
        void GetOptions(out uint pfos);
        void SetDefaultFolder([In, MarshalAs(UnmanagedType.Interface)] IShellItem psi);
        void SetFolder([In, MarshalAs(UnmanagedType.Interface)] IShellItem psi);
        void GetFolder([MarshalAs(UnmanagedType.Interface)] out IShellItem ppsi);
        void GetCurrentSelection([MarshalAs(UnmanagedType.Interface)] out IntPtr ppsi);
        void SetFileName([In, MarshalAs(UnmanagedType.LPWStr)] string pszName);
        void GetFileName([MarshalAs(UnmanagedType.LPWStr)] out string pszName);
        void SetTitle([In, MarshalAs(UnmanagedType.LPWStr)] string pszTitle);
        void SetOkButtonLabel([In, MarshalAs(UnmanagedType.LPWStr)] string pszText);
        void SetFileNameLabel([In, MarshalAs(UnmanagedType.LPWStr)] string pszLabel);
        void GetResult([MarshalAs(UnmanagedType.Interface)] out IShellItem ppsi);
        void AddPlace([In, MarshalAs(UnmanagedType.Interface)] IntPtr psi, uint fdap);
        void SetDefaultExtension([In, MarshalAs(UnmanagedType.LPWStr)] string pszDefaultExtension);
        void Close([MarshalAs(UnmanagedType.Error)] int hr);
        void SetClientGuid([In] ref Guid guid);
        void ClearClientData();
        void SetFilter([In] IntPtr pFilter);
        void GetResults([MarshalAs(UnmanagedType.Interface)] out IntPtr ppenum);
        void GetSelectedItems([MarshalAs(UnmanagedType.Interface)] out IntPtr ppsai);
    }

    [ComImport]
    [Guid("43826D1E-E718-42EE-BC55-A1E261C37BFE")]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    private interface IShellItem
    {
        void BindToHandler([In] IntPtr pbc, [In] ref Guid bhid, [In] ref Guid riid, out IntPtr ppv);
        void GetParent([MarshalAs(UnmanagedType.Interface)] out IShellItem ppsi);
        void GetDisplayName([In] uint sigdnName, out IntPtr ppszName);
        void GetAttributes([In] uint sfgaoMask, out uint psfgaoAttribs);
        void Compare([In, MarshalAs(UnmanagedType.Interface)] IShellItem psi, [In] uint hint, out int piOrder);
    }

    [DllImport("shell32.dll", CharSet = CharSet.Unicode, PreserveSig = false)]
    private static extern void SHCreateItemFromParsingName(
        [In][MarshalAs(UnmanagedType.LPWStr)] string pszPath,
        [In] IntPtr pbc,
        [In][MarshalAs(UnmanagedType.LPStruct)] Guid riid,
        [Out][MarshalAs(UnmanagedType.Interface, IidParameterIndex = 2)] out IShellItem ppv);

    public static string ShowDialog(string title, string defaultPath)
    {
        try {
            IFileOpenDialog dialog = (IFileOpenDialog)new FileOpenDialogInternal();
            dialog.SetOptions(0x00000020 | 0x10000000); // FOS_PICKFOLDERS | FOS_FORCEFILESYSTEM
            dialog.SetTitle(title);
            
            if (!string.IsNullOrEmpty(defaultPath)) {
                try {
                    Guid shellItemGuid = new Guid("43826D1E-E718-42EE-BC55-A1E261C37BFE");
                    IShellItem defaultFolderItem;
                    SHCreateItemFromParsingName(defaultPath, IntPtr.Zero, shellItemGuid, out defaultFolderItem);
                    dialog.SetFolder(defaultFolderItem);
                } catch { }
            }
            
            uint hr = dialog.Show(IntPtr.Zero);
            if (hr == 0) // S_OK
            {
                IShellItem item;
                dialog.GetResult(out item);
                IntPtr pszString;
                item.GetDisplayName(0x80058000, out pszString); // SIGDN_FILESYSPATH
                string path = Marshal.PtrToStringAuto(pszString);
                Marshal.FreeCoTaskMem(pszString);
                return path;
            }
        } catch { }
        return null;
    }
}
"@
                
                # Show the modern folder browser directly
                $dialogTitle = "Select Destination Folder for " + $pathsToCopy.Count + " files"
                $destFolder = [ModernFolderBrowser]::ShowDialog($dialogTitle, $DefaultPickerFolder)
            } else {
                $destFolder = $FixedDestination
            }

            if ($destFolder) {
                if ($AutoSubfolder) {
                    $originalDir = [System.IO.Path]::GetDirectoryName($FilePath)
                    $originalFolderName = [System.IO.Path]::GetFileName($originalDir)
                    if (-not [string]::IsNullOrWhiteSpace($originalFolderName)) {
                        $destFolder = Join-Path $destFolder $originalFolderName
                    }
                    $dialogResult = [System.Windows.Forms.DialogResult]::OK
                } elseif ($SkipSubfolderPrompt) {
                    $dialogResult = [System.Windows.Forms.DialogResult]::OK
                } else {
                    # Ask for a subfolder name
                    $subForm = New-Object System.Windows.Forms.Form
                    $subForm.Text = "Subfolder Options"
                    $subForm.Size = New-Object System.Drawing.Size(400, 160)
                    $subForm.StartPosition = 'CenterScreen'
                    $subForm.TopMost = $true
                    $subForm.FormBorderStyle = 'FixedDialog'
                    $subForm.MaximizeBox = $false
                    $subForm.MinimizeBox = $false
                    $subForm.ShowInTaskbar = $false

                    $lbl = New-Object System.Windows.Forms.Label
                    $lbl.Text = "Enter a subfolder name to create (or leave empty to copy directly):"
                    $lbl.Location = New-Object System.Drawing.Point(10, 20)
                    $lbl.AutoSize = $true
                    $subForm.Controls.Add($lbl)

                    $txt = New-Object System.Windows.Forms.TextBox
                    $txt.Location = New-Object System.Drawing.Point(15, 50)
                    $txt.Size = New-Object System.Drawing.Size(355, 20)
                    $subForm.Controls.Add($txt)

                    $ok = New-Object System.Windows.Forms.Button
                    $ok.Text = "Copy"
                    $ok.Location = New-Object System.Drawing.Point(215, 90)
                    $ok.DialogResult = [System.Windows.Forms.DialogResult]::OK
                    $subForm.Controls.Add($ok)

                    $cancel = New-Object System.Windows.Forms.Button
                    $cancel.Text = "Cancel"
                    $cancel.Location = New-Object System.Drawing.Point(295, 90)
                    $cancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
                    $subForm.Controls.Add($cancel)

                    $subForm.AcceptButton = $ok
                    $subForm.CancelButton = $cancel

                    $dialogResult = $subForm.ShowDialog()
                    if ($dialogResult -eq [System.Windows.Forms.DialogResult]::OK) {
                        $subName = $txt.Text.Trim()
                        if (-not [string]::IsNullOrEmpty($subName)) {
                            $destFolder = Join-Path $destFolder $subName
                        }
                    }
                    $subForm.Dispose()
                }
                
                if ($dialogResult -eq [System.Windows.Forms.DialogResult]::OK) {
                    
                    # Check if destination exists, create if not
                    if (-not (Test-Path $destFolder)) {
                        try {
                            New-Item -ItemType Directory -Path $destFolder -ErrorAction Stop | Out-Null
                        } catch {
                            [System.Windows.Forms.MessageBox]::Show("Could not create destination folder:`n" + $_.Exception.Message, "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
                            $destFolder = $null
                        }
                    }
                    
                    if ($destFolder) {
                        $copiedCount = 0
                        $errorCount = 0
                        
                        foreach ($path in $pathsToCopy) {
                            $fileName = [System.IO.Path]::GetFileName($path)
                            $destPath = Join-Path $destFolder $fileName
                            
                            try {
                                Copy-Item -Path $path -Destination $destPath -Force -ErrorAction Stop
                                $copiedCount++
                            } catch {
                                $errorCount++
                            }
                        }
                        
                        $msg = "Successfully copied $copiedCount files to`n$destFolder"
                        if ($errorCount -gt 0) {
                            $msg += "`n`nFailed to copy $errorCount files."
                        }
                        
                        [System.Windows.Forms.MessageBox]::Show($msg, "Copy with RAW", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
                        
                        if ($OpenDestination) {
                            Invoke-Item $destFolder
                        }
                    }
                }
                $subForm.Dispose()
            }
        }
        
        # Clean up the entire session subfolder so nothing bleeds into the next run
        Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
    finally {
        $mutex.ReleaseMutex()
    }
} else {
    # Not the coordinator
}
