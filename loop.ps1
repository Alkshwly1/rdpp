# إعدادات GitHub و Discord
$GitUser   = "Alkshwly1"
$RepoName  = "rdp-storage"
$GitToken  = "githubpat11BHZIK6I0AvNKTYfrnj5v_QJgbf0uJqr6U4Jm3ARgE3DFFx6ToVYmE4Yxjl7cIg34FOBNFED6vyhfrgsW"
$Webhook   = "https://discord.com/api/webhooks/1396598545611624448/1knf6aOC9Bpe1LiSoMoph4E2ik7dqwBsxXa4-GSRIocKkknq0fnVuG9WUxBt-2zgN51j"
$BasePath  = "C:\MyFiles"

# تحميل أو إنشاء عدّاد الجلسات
$CounterFile = "$BasePath\counter.txt"
if (!(Test-Path $CounterFile)) {
    Set-Content -Path $CounterFile -Value "1"
}
$SessionCount = [int](Get-Content $CounterFile)
$SessionID    = "Session_$SessionCount"
$SessionName  = "$SessionID_" + (Get-Date -Format "yyyy-MM-dd_HH-mm")
$BackupDir    = "$BasePath\$SessionName"
$LatestDir    = "$BasePath\latest"

# زيادة رقم الجلسة
$SessionCount++
Set-Content -Path $CounterFile -Value $SessionCount

# إنشاء مجلد للجلسة الجديدة
New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null

# استرجاع ملفات آخر جلسة من GitHub
git clone https://$GitUser:$GitToken@github.com/$GitUser/$RepoName.git "$LatestDir" 2>$null
Remove-Item "$LatestDir\.git" -Recurse -Force -ErrorAction SilentlyContinue
Copy-Item "$LatestDir\*" "$BackupDir" -Recurse -Force -ErrorAction SilentlyContinue

# تهيئة Git داخل مجلد الجلسة
cd $BackupDir
git init
git config --global user.name "Brekkan"
git config --global user.email "you@example.com"
git remote add origin https://$GitUser:$GitToken@github.com/$GitUser/$RepoName.git

# بدء حلقة التجديد المستمر كل 30 ثانية
while ($true) {
    try {
        # إعادة تشغيل ngrok
        taskkill /F /IM ngrok.exe 2>$null
        Start-Process ".\ngrok\ngrok.exe" -ArgumentList "tcp 3389" -NoNewWindow
        Start-Sleep -Seconds 5

        # استخراج رابط ngrok من اللوج
        $LogPath = "$env:USERPROFILE\AppData\Local\ngrok\ngrok.log"
        $logs = Get-Content $LogPath -ErrorAction SilentlyContinue
        $endpoint = ($logs | Select-String "url=tcp://" | Select-Object -Last 1).ToString()
        if ($endpoint -match "tcp://(.+):(\d+)") {
            $host = $matches[1]
            $port = $matches[2]
            $NgrokInfo = "$host:$port"
        } else {
            $NgrokInfo = "غير معروف"
        }

        # رفع ملفات الجلسة إلى GitHub
        cd $BackupDir
        git add .
        git commit -m "Backup: $SessionName - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" 2>$null
        git push origin master

        # إرسال تنبيه إلى Discord
        $Payload = @{ 
            content = "📦 الجلسة رقم: `$SessionCount`\n🗂 اسم المجلد: `$SessionName`\n🔗 رابط الاتصال: `$NgrokInfo`\n👤 المستخدم: administrator\n🔑 كلمة المرور: JohnTech1234"
        }
        Invoke-RestMethod -Uri $Webhook -Method Post -Body ($Payload | ConvertTo-Json) -ContentType 'application/json'
    }
    catch {
        $ErrorMessage = $_.Exception.Message
        $Payload = @{ content = "❌ خطأ في الجلسة `$SessionName`: `$ErrorMessage`" }
        Invoke-RestMethod -Uri $Webhook -Method Post -Body ($Payload | ConvertTo-Json) -ContentType 'application/json'
    }

    # انتظار 30 ثانية
    Start-Sleep -Seconds 30
}
