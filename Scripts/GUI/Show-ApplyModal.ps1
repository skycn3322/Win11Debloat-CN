function Show-ApplyModal {
    param (
        [Parameter(Mandatory=$false)]
        [System.Windows.Window]$Owner = $null,
        [Parameter(Mandatory=$false)]
        [bool]$RestartExplorer = $false
    )
    
    Add-Type -AssemblyName PresentationFramework,PresentationCore,WindowsBase | Out-Null

    # P/Invoke 辅助函数：重启资源管理器后强制获取焦点
    if (-not ([System.Management.Automation.PSTypeName]'Win11Debloat.FocusHelper').Type) {
        Add-Type -Namespace Win11Debloat -Name FocusHelper -MemberDefinition @'
            [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
            [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
            [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr hWnd, IntPtr lpdwProcessId);
            [DllImport("user32.dll")] public static extern bool AttachThreadInput(uint idAttach, uint idAttachTo, bool fAttach);
            [DllImport("kernel32.dll")] public static extern uint GetCurrentThreadId();

            public static void ForceActivate(IntPtr hwnd) {
                IntPtr fg = GetForegroundWindow();
                uint fgThread = GetWindowThreadProcessId(fg, IntPtr.Zero);
                uint myThread = GetCurrentThreadId();
                if (fgThread != myThread) AttachThreadInput(myThread, fgThread, true);
                SetForegroundWindow(hwnd);
                if (fgThread != myThread) AttachThreadInput(myThread, fgThread, false);
            }
'@
    }
    
    $usesDarkMode = GetSystemUsesDarkMode
    
    # 确定所有者窗口
    $ownerWindow = if ($Owner) { $Owner } else { $script:GuiWindow }
    
    # 如果所有者窗口存在，显示覆盖层
    $overlay = $null
    if ($ownerWindow) {
        try {
            $overlay = $ownerWindow.FindName('ModalOverlay')
            if ($overlay) {
                $ownerWindow.Dispatcher.Invoke([action]{ $overlay.Visibility = 'Visible' })
            }
        }
        catch { }
    }
    
    # 从文件加载 XAML
    $xaml = Get-Content -Path $script:ApplyChangesWindowSchema -Raw
    $reader = [System.Xml.XmlReader]::Create([System.IO.StringReader]::new($xaml))
    try {
        $applyWindow = [System.Windows.Markup.XamlReader]::Load($reader)
    }
    finally {
        $reader.Close()
    }
    
    # 如果所有者窗口存在，设置所有者
    if ($ownerWindow) {
        try {
            $applyWindow.Owner = $ownerWindow
        }
        catch { }
    }
    
    # 应用主题资源
    SetWindowThemeResources -window $applyWindow -usesDarkMode $usesDarkMode
    
    # 获取 UI 元素
    $script:ApplyInProgressPanel = $applyWindow.FindName('ApplyInProgressPanel')
    $script:ApplyCompletionPanel = $applyWindow.FindName('ApplyCompletionPanel')
    $script:ApplyStepNameEl = $applyWindow.FindName('ApplyStepName')
    $script:ApplyStepCounterEl = $applyWindow.FindName('ApplyStepCounter')
    $script:ApplyProgressBarEl = $applyWindow.FindName('ApplyProgressBar')
    $script:ApplyCompletionTitleEl = $applyWindow.FindName('ApplyCompletionTitle')
    $script:ApplyCompletionMessageEl = $applyWindow.FindName('ApplyCompletionMessage')
    $script:ApplyCompletionIconEl = $applyWindow.FindName('ApplyCompletionIcon')
    $applyRebootPanel = $applyWindow.FindName('ApplyRebootPanel')
    $applyRebootList = $applyWindow.FindName('ApplyRebootList')
    $applyCloseBtn = $applyWindow.FindName('ApplyCloseBtn')
    $applyKofiBtn = $applyWindow.FindName('ApplyKofiBtn')
    $applyCancelBtn = $applyWindow.FindName('ApplyCancelBtn')
    
    # 初始化进行中状态
    $script:ApplyInProgressPanel.Visibility = 'Visible'
    $script:ApplyCompletionPanel.Visibility = 'Collapsed'
    $script:ApplyStepNameEl.Text = "准备中..."
    $script:ApplyStepCounterEl.Text = "准备中..."
    $script:ApplyProgressBarEl.Value = 0
    $script:ApplyModalInErrorState = $false
    
    # 为 ExecuteAllChanges 设置进度回调
    $script:ApplyProgressCallback = {
        param($currentStep, $totalSteps, $stepName)
        $script:ApplyStepNameEl.Text = $stepName
        $script:ApplyStepCounterEl.Text = "步骤 $currentStep / $totalSteps"
        # 将当前步骤/总步骤存储在 Tag 属性中，用于子步骤插值
        $script:ApplyStepCounterEl.Tag = $currentStep
        $script:ApplyProgressBarEl.Tag = $totalSteps
        # 在每个步骤开始时显示进度（步骤1为0%，最后一步完成后为100%）
        $pct = if ($totalSteps -gt 0) { [math]::Round((($currentStep - 1) / $totalSteps) * 100) } else { 0 }
        $script:ApplyProgressBarEl.Value = $pct
        # 处理待处理的窗口消息以保持UI响应
        DoEvents
    }

    # 子步骤回调：更新步骤名称并在当前步骤内插值进度条
    $script:ApplySubStepCallback = {
        param($subStepName, $subIndex, $subCount)
        $script:ApplyStepNameEl.Text = $subStepName
        # 在前一步骤和当前步骤之间插值进度条
        $currentStep = [int]($script:ApplyStepCounterEl.Tag)
        $totalSteps = [int]($script:ApplyProgressBarEl.Tag)
        if ($totalSteps -gt 0 -and $subCount -gt 0) {
            $baseProgress = ($currentStep - 1) / $totalSteps
            $stepFraction = ($subIndex / $subCount) / $totalSteps
            $script:ApplyProgressBarEl.Value = [math]::Round(($baseProgress + $stepFraction) * 100)
        }
        DoEvents
    }
    
    # 在后台运行更改以保持UI响应
    $applyWindow.Dispatcher.BeginInvoke([System.Windows.Threading.DispatcherPriority]::Background, [action]{
        try {
            ExecuteAllChanges

            $registryImportFailureCount = [int]$script:RegistryImportFailures
            
            # 如果需要，重启资源管理器
            if ($RestartExplorer -and -not $script:CancelRequested) {
                RestartExplorer
                
                # 等待资源管理器重新启动完成，然后重新获取焦点
                Start-Sleep -Milliseconds 800
                $applyWindow.Dispatcher.Invoke([action]{
                    $hwnd = (New-Object System.Windows.Interop.WindowInteropHelper($applyWindow)).Handle
                    [Win11Debloat.FocusHelper]::ForceActivate($hwnd)
                })
            }
            
            Write-Host ""
            if ($script:CancelRequested) {
                Write-Host "脚本执行已被用户取消。部分更改可能未应用。"
            } elseif ($registryImportFailureCount -eq 0) {
                Write-Host "所有更改已成功应用!"
            }
            
            # 显示完成状态
            $script:ApplyProgressBarEl.Value = 100
            $script:ApplyInProgressPanel.Visibility = 'Collapsed'
            $script:ApplyCompletionPanel.Visibility = 'Visible'
            
            if ($script:CancelRequested) {
                $script:ApplyCompletionIconEl.Text = [char]0xE7BA
                $script:ApplyCompletionIconEl.Foreground = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.ColorConverter]::ConvertFromString("#e8912d"))
                $script:ApplyCompletionTitleEl.Text = "已取消"
                $script:ApplyCompletionMessageEl.Text = "脚本执行已被用户取消。"
            } elseif ($registryImportFailureCount -gt 0) {
                $script:ApplyCompletionIconEl.Text = [char]0xE7BA
                $script:ApplyCompletionIconEl.Foreground = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.ColorConverter]::ConvertFromString("#e8912d"))
                $script:ApplyCompletionTitleEl.Text = "更改已应用但有错误"
                $script:ApplyCompletionMessageEl.Text = "$registryImportFailureCount 个注册表更改失败。详情请查看控制台。"
            } else {
                $script:ApplyCompletionTitleEl.Text = "更改已应用"

                # 如果有任何应用的功能需要重启，显示重启提示
                if ($RestartExplorer) {
                    $rebootFeatures = @()
                    foreach ($paramKey in $script:Params.Keys) {
                        if ($script:Features.ContainsKey($paramKey) -and $script:Features[$paramKey].RequiresReboot -eq $true) {
                            $feature = $script:Features[$paramKey]
                            $rebootFeatures += "$($feature.Label)"
                        }
                    }

                    if ($rebootFeatures.Count -gt 0) {
                        foreach ($featureName in $rebootFeatures) {
                            $tb = [System.Windows.Controls.TextBlock]::new()
                            $tb.Text = "$([char]0x2022) $featureName"
                            $tb.FontSize = 12
                            $tb.SetResourceReference([System.Windows.Controls.TextBlock]::ForegroundProperty, 'FgColor')
                            $tb.Opacity = 0.85
                            $tb.Margin = [System.Windows.Thickness]::new(0, 2, 0, 0)
                            $applyRebootList.Children.Add($tb) | Out-Null
                        }
                        $applyRebootPanel.Visibility = 'Visible'
                    }
                    else {
                        $script:ApplyCompletionMessageEl.Text = "您的纯净系统已准备就绪。感谢使用 Win11Debloat！"
                    }
                }
            }
            $applyWindow.Dispatcher.Invoke([System.Windows.Threading.DispatcherPriority]::Render, [action]{})
        }
        catch {
            Write-Host "错误: $($_.Exception.Message)"
            $script:ApplyInProgressPanel.Visibility = 'Collapsed'
            $script:ApplyCompletionPanel.Visibility = 'Visible'
            $script:ApplyCompletionIconEl.Text = [char]0xEA39
            $script:ApplyCompletionIconEl.Foreground = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.ColorConverter]::ConvertFromString("#c42b1c"))
            $script:ApplyCompletionTitleEl.Text = "错误"
            $script:ApplyCompletionMessageEl.Text = "应用更改时发生错误: $($_.Exception.Message)"
            
            # 设置错误状态以将Kofi按钮更改为报告链接
            $script:ApplyModalInErrorState = $true

            # 将Kofi按钮更新为报告问题按钮
            $applyKofiBtn.Content = $null
            
            $reportText = [System.Windows.Controls.TextBlock]::new()
            $reportText.Text = '报告问题'
            $reportText.VerticalAlignment = 'Center'
            $reportText.FontSize = 14
            $reportText.Margin = [System.Windows.Thickness]::new(0, 0, 0, 1)

            $applyKofiBtn.Content = $reportText
            
            [System.Windows.Automation.AutomationProperties]::SetName($applyKofiBtn, '报告问题')
            
            $applyWindow.Dispatcher.Invoke([System.Windows.Threading.DispatcherPriority]::Render, [action]{})
        }
        finally {
            $script:ApplyProgressCallback = $null
            $script:ApplySubStepCallback = $null
        }
    }) | Out-Null
    
    # 按钮事件处理
    $applyCloseBtn.Add_Click({
        $applyWindow.Close()
    })

    $applyKofiBtn.Add_Click({
        if ($script:ApplyModalInErrorState) {
            Start-Process "https://github.com/Raphire/Win11Debloat/issues/new"
        } else {
            Start-Process "https://ko-fi.com/raphire"
        }
    })

    $applyCancelBtn.Add_Click({
        if ($script:ApplyCompletionPanel.Visibility -eq 'Visible') {
            # 完成状态 - 直接关闭
            $applyWindow.Close()
        } else {
            # 进行中状态 - 请求取消
            $script:CancelRequested = $true
        }
    })
    
    # 显示对话框
    try {
        $applyWindow.ShowDialog() | Out-Null
    }
    finally {
        # 对话框关闭后隐藏覆盖层
        if ($overlay) {
            try {
                $ownerWindow.Dispatcher.Invoke([action]{ $overlay.Visibility = 'Collapsed' })
            }
            catch { }
        }
    }
}
