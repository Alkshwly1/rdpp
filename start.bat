@echo off
setlocal enabledelayedexpansion

:: Webhook حق Discord
set webhook=https://discord.com/api/webhooks/1396598545611624448/1knf6aOC9Bpe1LiSoMoph4E2ik7dqwBsxXa4-GSRIocKkknq0fnVuG9WUxBt-2zgN51j

:: دالة إرسال تنبيه إلى Discord
set "notifyPowerShell=powershell -command ^"$Payload = @{ content = '⚠️ حدث خطأ: %%~1' }; Invoke-RestMethod -Uri '!webhook!' -Method Post -Body ($Payload | ConvertTo-Json) -ContentType 'application/json'^""

:: تنفيذ الأوامر، وكل ما صار خطأ نرسل تنبيه
del /f "C:\Users\Public\Desktop\Epic Games Launcher.lnk" > out.txt 2>&1 || call !notifyPowerShell! "فشل حذف اختصار Epic"
net config server /srvcomment:"Windows Server 2019 By MBAH GADGET" > out.txt 2>&1 || call !notifyPowerShell! "فشل إعداد وصف الجهاز"
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /V EnableAutoTray /T REG_DWORD /D 0 /F > out.txt 2>&1 || call !notifyPowerShell! "فشل تعديل الريجستري AutoTray"
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /f /v Wallpaper /t REG_SZ /d D:\a\wallpaper.bat || call !notifyPowerShell! "فشل تعيين خلفية التشغيل"
net user administrator JohnTech1234 /add >nul || call !notifyPowerShell! "فشل إنشاء مستخدم administrator"
net localgroup administrators administrator /add >nul || call !notifyPowerShell! "فشل إضافة المستخدم لمجموعة المدراء"
net user administrator /active:yes >nul || call !notifyPowerShell! "فشل تفعيل حساب administrator"
net user installer /delete || call !notifyPowerShell! "فشل حذف حساب installer"
diskperf -Y >nul || call !notifyPowerShell! "فشل تفعيل diskperf"
sc config Audiosrv start= auto >nul || call !notifyPowerShell! "فشل إعداد خدمة الصوت"
sc start audiosrv >nul || call !notifyPowerShell! "فشل تشغيل خدمة الصوت"
ICACLS C:\Windows\Temp /grant administrator:F >nul || call !notifyPowerShell! "فشل منح صلاحية Temp"
ICACLS C:\Windows\installer /grant administrator:F >nul || call !notifyPowerShell! "فشل منح صلاحية installer"

:: طباعة تفاصيل الاتصال
echo Success!
echo IP:
tasklist | find /i "ngrok.exe" >Nul && curl -s localhost:4040/api/tunnels | jq -r .tunnels[0].public_url || (
  echo "Failed to retrieve NGROK tunnel"
  call !notifyPowerShell! "فشل استخراج رابط ngrok"
)
echo Username: administrator
echo Password: JohnTech1234
echo You can login now.
ping -n 10 127.0.0.1 >nul
