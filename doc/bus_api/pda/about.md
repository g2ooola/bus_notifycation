# 公車動態系統
## 資料來源
* 從大台北公車網站 (https://ebus.gov.taipei/)取得資訊, 其中
  * 授權 :
    * 聲明頁面為 : https://ebus.gov.taipei/Home/CopyrightNotice
    * 其 `著作權聲明` 的 4-2 提到, `本網站上之資訊，可為個人或家庭非營利之目的而重製。`
  * 資料 :
    * 此網站中的 PDA 服務 (https://pda.5284.gov.taipei/), 提供了簡易的公車到站資訊, 且其頁面使用的 API 不做 AUTH 認證, 可以方便取用到公車資訊 API

### 需要資料
1. 路徑
2. 方向 (去, 回程)
3. 站名

## 關鍵資料解析
key id:
* rid: 路線 id
* slid: 某個站點的 id,, 此站點會有多個 路線經過
* sid: 特定路線的某一站點 id

API
* 公車路線
  * 網頁 : https://pda.5284.gov.taipei/MQS/routelist.jsp
  * 使用 parse 網頁拿到 路線 - rid 對應


* 特定路線資料
  * 網頁 : https://pda.5284.gov.taipei/MQS/route.jsp?rid=10785
  * api : https://pda.5284.gov.taipei/MQS/RouteDyna?routeid=10785&nocache=1653118677455
  * 說明 : 此網頁包含每個方向, 每個站的 sid, 需要知道 rid 以組成網址


* 特定站別資料
  * 網頁 : https://pda.5284.gov.taipei/MQS/stop.jsp?from=sl&sid=38878


rule
  root: UpdateTime, Stop, Bus
  Stop:
    範例 :
      [{
          "id": 38857,
          "n1": "N1,38857,10785,-1,,,,-1,,2,2,220521153848,00062550,220521153848,45992630"
      }]
    id: 車站 id
    n1: 車站資訊
      arrN1[1]: 車站 id
      arrN1[7]: 狀態 enum int, 公車是否進站

  Bus:  內含

    範例: 
      [{
            "id": 222238675,
            "num": "606-U3",
            "type": "0",
            "a1": "A1,10780,222238675,1,0,107850,1,121.516142,24.997827,24,217,154500,1,220521154501,54793033,220521154501,46414374",
            "a2": "A2,10780,222238675,1,0,107850,1,38928,0,154443,2,220521154446,81072832,220521154446,46394871"
      }]
    id
    num: 車牌號碼, 測試資料為 TEST  開頭
    type: '1' or '0' ?
    a1:
      ?
      允許沒有直
    a2:
      ?
      一定要有值
      a2[7]: bus_id