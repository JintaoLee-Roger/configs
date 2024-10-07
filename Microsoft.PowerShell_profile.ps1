# vim $PROFILE
# update: . $PROFILE

#################### ls ###############################
try {
    Remove-Item alias:ls -ErrorAction Stop
} catch {}

function ls {
    param (
        [Parameter(ValueFromRemainingArguments=$true)]
        [string[]]$arguments,
        [switch]$l,
        [switch]$a,
        [switch]$h
    )

    $paths = @()
    $options = ""

    foreach ($arg in $arguments) {
        if ($arg -like "-*") {
            $options += $arg.Replace("-", "")
        } else {
            $paths += $arg
        }
    }
    if ($paths.Count -eq 0) {
        $paths = @(".")
    }

    # 合并 switch 和 $options 字符串中的选项
    $l = $l -or ($options -match "l")
    $a = $a -or ($options -match "a")
    $h = $h -or ($options -match "h")

    # 自定义文件大小显示方式（将字节转换为人类可读格式）
    function Convert-Size {
        param (
            [int64]$size
        )

        if ($size -ge 1GB) {
            return "{0:N2} GB" -f ($size / 1GB)
        } elseif ($size -ge 1MB) {
            return "{0:N2} MB" -f ($size / 1MB)
        } elseif ($size -ge 1KB) {
            return "{0:N2} KB" -f ($size / 1KB)
        } else {
            return "$size Bytes"
        }
    }

    # 遍历每个路径并输出文件信息
    foreach ($path in $paths) {
        # 获取文件列表，-a 参数决定是否显示隐藏文件
        $items = Get-ChildItem -Path $path -Force:$a

        if ($l) {
            # 如果 -l 参数被指定，显示详细信息
            if ($h) {
                # -h 表示以人类可读格式显示文件大小
                $items | Select-Object Mode, LastWriteTime, @{Name="Size";Expression={Convert-Size $_.Length}}, Name | Format-Table
            } else {
                # 否则按默认字节大小显示
                $items | Format-Table Mode, LastWriteTime, Length, Name
            }
        } else {
            # 如果没有 -l，只显示文件名称
            $items | Format-Table Name
        }
    }
}


function l {
    ls -alh @args  # @args 将传递给 ls 的所有额外参数
}

function ll {
    ls -alh @args  # @args 将传递给 ls 的所有额外参数
}


#################### cd ###############################
try {
    Remove-Item alias:cd -ErrorAction Stop
} catch {}

function cd {
    param (
        [string]$path = ""
    )

    # 获取用户主目录
    $homeDir = [System.Environment]::GetFolderPath("UserProfile")

    if (-not $path) {
        # 如果没有传递任何路径，切换到主目录 (模拟 `cd`)
        Set-Location $homeDir
    } elseif ($path -eq "~") {
        # 切换到主目录 (模拟 `cd ~`)
        Set-Location $homeDir
    # } elseif ($path -eq "-") {
    #     # 切换到上一次所在的目录 (模拟 `cd -`)
    #     $temp = $PWD
    #     Set-Location $OLDPWD
    #     $OLDPWD = $temp
    } else {
        # 切换到指定的路径
        try {
            Set-Location $path
            # 更新 OLDPWD
            $OLDPWD = $PWD
        } catch {
            Write-Host "Error: Cannot find path '$path'" -ForegroundColor Red
        }
    }
}

function cdc {
    cd c:\
}

function cdd {
    cd d:\
}

function cde {
    cd e:\
}


#################### cp ###############################
try {
    Remove-Item alias:cp -ErrorAction Stop
} catch {}

function cp {
    param (
        [string]$source,        # 源路径
        [string]$destination,   # 目标路径
        [switch]$r              # -r 参数，用于递归复制目录
    )

    # 检查源路径是否存在
    if (-not (Test-Path $source)) {
        Write-Host "Error: Source '$source' does not exist." -ForegroundColor Red
        return
    }

    # 检查源是否是目录
    if ((Test-Path $source -PathType Container) -and (-not $r)) {
        Write-Host "Error: omitting directory '$source'. Use -r to copy directories." -ForegroundColor Red
        return
    }

    # 如果源是文件或者 -r 参数已经指定，进行复制操作
    try {
        if ($r) {
            # 递归复制目录及其内容
            Copy-Item -Path $source -Destination $destination -Recurse -Force
            # Write-Host "Directory '$source' copied to '$destination' recursively."
        } else {
            # 复制文件
            Copy-Item -Path $source -Destination $destination -Force
            # Write-Host "File '$source' copied to '$destination'."
        }
    } catch {
        Write-Host "Error: Could not copy '$source' to '$destination'." -ForegroundColor Red
    }
}


#################### mv ###############################
try {
    Remove-Item alias:mv -ErrorAction Stop
} catch {}

function mv {
    param (
        [string]$source,        # 源路径
        [string]$destination    # 目标路径
    )

    # 检查源路径是否存在
    if (-not (Test-Path $source)) {
        Write-Host "Error: Source '$source' does not exist." -ForegroundColor Red
        return
    }

    # 获取目标路径的父目录
    $destinationParent = Split-Path -Parent $destination

    # 如果目标路径的父目录不为空且不存在，提示错误
    if ($destinationParent -and (-not (Test-Path $destinationParent))) {
        Write-Host "Error: Destination path '$destinationParent' does not exist." -ForegroundColor Red
        return
    }

    # 尝试移动文件或目录
    try {
        Move-Item -Path $source -Destination $destination -Force
        # Write-Host "Moved '$source' to '$destination'."
    } catch {
        Write-Host "Error: Could not move '$source' to '$destination'." -ForegroundColor Red
    }
}

#################### rm ###############################
try {
    Remove-Item alias:rm -ErrorAction Stop
} catch {}

function rm {
    param (
        [Parameter(ValueFromRemainingArguments=$true)]
        [string[]]$arguments,
        [switch]$r,  # 显式 -r 参数
        [switch]$f   # 显式 -f 参数
    )

    # 初始化路径和选项的默认值
    $paths = @()
    $options = ""

    # 解析 $arguments
    foreach ($arg in $arguments) {
        if ($arg -like "-*") {
            # 如果参数以 '-' 开头，解析选项
            $options += $arg.Replace("-", "")
        } else {
            # 将其他参数视为路径
            $paths += $arg
        }
    }

    # 合并显式传入的 -r 和 -f 参数与从选项中解析出的值
    $r = $r -or ($options -match "r")
    $f = $f -or ($options -match "f")

    # 检查是否有路径参数
    if ($paths.Count -eq 0) {
        Write-Host "Error: no paths provided for removal." -ForegroundColor Red
        return
    }

    # 遍历路径并执行删除操作
    foreach ($path in $paths) {
        # 检查路径是否存在
        if (-not (Test-Path $path)) {
            Write-Host "Error: '$path' does not exist." -ForegroundColor Red
            continue
        }

        # 检查是否是目录，且没有 -r 参数
        if ((Test-Path $path -PathType Container) -and (-not $r)) {
            Write-Host "Error: cannot remove '$path': Is a directory. Use -r to remove directories." -ForegroundColor Red
            continue
        }

        # 尝试删除文件或目录
        try {
            if ($r) {
                # 递归删除目录
                Remove-Item -Path $path -Recurse -Force:$f
                # Write-Host "Directory '$path' has been removed recursively."
            } else {
                # 删除文件或非递归删除目录
                Remove-Item -Path $path -Force:$f
                # Write-Host "File '$path' has been removed."
            }
        } catch {
            Write-Host "Error: Could not remove '$path'." -ForegroundColor Red
        }
    }
}


################## touch #######################
function touch {
    param (
        [string]$path  # 文件路径
    )

    # 获取文件的父目录
    $parentDir = Split-Path -Parent $path

    # 检查是否有父目录，如果有则检查父目录是否存在
    if ($parentDir -and (-not (Test-Path $parentDir))) {
        Write-Host "Error: Parent directory '$parentDir' does not exist." -ForegroundColor Red
        return
    }

    # 如果文件不存在，创建文件
    if (-not (Test-Path $path)) {
        New-Item -Path $path -ItemType File -Force | Out-Null
        # Write-Host "File '$path' created."
    } else {
        Write-Host "File '$path' already exists. Do nothing!"
    }
}

################## mkdir #######################
function mkdir {
    param (
        [string]$path,   # 目录路径
        [switch]$p       # -p 参数，用于递归创建父目录
    )

    # 检查路径是否存在
    if (Test-Path $path) {
        Write-Host "Directory '$path' already exists. Cannot create." -ForegroundColor Red
        return
    }

    # 获取父目录
    $parentDir = Split-Path -Parent $path

    # 如果 -p 参数不存在，检查父目录是否存在
    if (-not $p -and $parentDir -and (-not (Test-Path $parentDir))) {
        Write-Host "Error: Parent directory '$parentDir' does not exist. Use -p to create directories recursively." -ForegroundColor Red
        return
    }

    # 创建目录
    try {
        if ($p) {
            # 递归创建目录（包括不存在的父目录）
            New-Item -Path $path -ItemType Directory -Force | Out-Null
            # Write-Host "Directory '$path' created recursively."
        } else {
            # 普通创建目录
            New-Item -Path $path -ItemType Directory | Out-Null
            # Write-Host "Directory '$path' created."
        }
    } catch {
        Write-Host "Error: Could not create directory '$path'." -ForegroundColor Red
    }
}


############# sudo ###########
function sudo {
    param(
        [Parameter(Mandatory=$true, ValueFromRemainingArguments)]
        [string[]]
        $Command
    )

    $commandString = $Command -join ' '
    $encodedCommand = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($commandString))
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -EncodedCommand $encodedCommand"
}


########### vim #############
Set-Alias vim nvim
Set-Alias vi nvim

########### service #############
function dhale {
    ssh jtli@dhale
}

function xmw {
    ssh jtli@xinmwu
}

function cig {
    ssh lijintao@cig
}
