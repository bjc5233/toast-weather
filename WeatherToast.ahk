﻿;说明
;  获取天气信息，并以系统toast形式展示
;备注
;  1. 接口地址：https://www.nowapi.com/api/weather.future
;external
;  date       2019-08-10 13:59:48
;  face       (>_<)
;  weather    Shanghai Moderate rain 28℃
; ========================= init =========================
#SingleInstance,Force
#Include <JSON>
weaid = 36
appkey = 27580
sign = 07af95bb4eb5bce5f8c62ef5d760eff7
; ========================= init =========================




; ========================= 下载json并解析 =========================
FormatTime, dateStr, , yyyy-MM-dd
jsonFilePath = %A_Temp%\weatherToast.%dateStr%.json
IfNotExist, %jsonFilePath%
    URLDownloadToFile http://api.k780.com/?app=weather.future&weaid=%weaid%&&appkey=%appkey%&sign=%sign%&format=json, %jsonFilePath%
FileEncoding, UTF-8
file := FileOpen(jsonFilePath, "r")
if !IsObject(file)
	throw Exception("Can't access file for JSONFile instance: " file, -1)
try {
    json := JSON.Load(file.Read())
} catch e {
    FileDelete, %jsonFilePath%
    MsgBox, JSON文件格式错误，请检查[%jsonFilePath%]
    return
}
file.Close()
; ========================= 下载json并解析 =========================



; ========================= 解析天气 =========================
weatherResult := json.result
todayWeatherStr :=
oneWeekWeatherStr :=
for index, oneDayWeather in weatherResult
{
    days := oneDayWeather.days
    week := oneDayWeather.week
    temperature := oneDayWeather.temperature
    weather := oneDayWeather.weather
    wind := oneDayWeather.wind
    winp := oneDayWeather.winp
    weatid := oneDayWeather.weatid
    
    StringReplace, week, week, 星期, 周
    if (index = 1) {
        todayWeatherStr = 
        (
            <text><![CDATA[%days%]]></text>
            <text><![CDATA[%weather%  %temperature%]]></text>
            <text><![CDATA[%wind%  %winp%]]></text>
        )
    } else if (index > 1 and index < 7) {
        oneDayWeatherStr = 
        (
            <subgroup hint-weight="1">
                <text hint-align="center"><![CDATA[%week%]]></text>
                <image src="file:///%A_ScriptDir%/icon/%weatid%.png" hint-removeMargin="true"/>
                <text hint-align="center"><![CDATA[%temperature%]]></text>
                <text hint-align="center"><![CDATA[%weather%]]></text>
            </subgroup>
        )
        oneWeekWeatherStr = %oneWeekWeatherStr%`r`n%oneDayWeatherStr%
    }
}
; ========================= 解析天气 =========================




; ========================= 通过powershell发送toast =========================
code =
(
[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
[Windows.UI.Notifications.ToastNotification, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
[Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] | Out-Null
$APP_ID = ' '
$template = @"
<toast activationType="protocol" launch="" duration="long" displayTimestamp="2017-04-15T19:45:00Z">
    <visual>
        <binding template="ToastGeneric">
            <image placement="hero" src="file:///%A_ScriptDir%/icon/hero.png"/>
            %todayWeatherStr%
            <group>
                %oneWeekWeatherStr%
            </group>
        </binding>
    </visual>
    <audio src="ms-winsoundevent:Notification.Looping.Alarm10" loop="false" silent="false" />
</toast>
"@

$xml = New-Object Windows.Data.Xml.Dom.XmlDocument
$xml.LoadXml($template)
$toast = New-Object Windows.UI.Notifications.ToastNotification $xml
[Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($APP_ID).Show($toast)
)
FileDelete, %A_Temp%\weatherToast.ps1
FileAppend, %code% , %A_Temp%\weatherToast.ps1
run, PowerShell -ExecutionPolicy Bypass -File %A_Temp%\weatherToast.ps1 ,, Hide
; ========================= 通过powershell发送toast =========================