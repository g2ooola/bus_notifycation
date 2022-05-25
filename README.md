# bus_notifycation
## How to user
1. 在 private/secret.yml 中加入 gmail smtp 密碼
yml 檔案格式如下

```yml
gmail_password: YOUR_PASS_WORD
```

smtp 密碼設定方式可參考 [REF](https://www.webdesigntooler.com/google-smtp-send-mail)

## 需求
1. 公車到站前自動通知
2. 可供多人使用
3. 可訂閱多條路線的多個站

其他
1. 建議以到站前 x 分鐘為基礎
2. 暫時以 email 通知
3. 只訂閱站不合理, 應該要加上時間

## 公車查詢網頁
### 流程
1. 訂閱

### 需要資料
1. 路徑
2. 方向 (去, 回程)
3. 站名

### 關鍵
rid: 路線 id
公車路線
  網頁 : https://pda.5284.gov.taipei/MQS/routelist.jsp
  使用 parse 網頁拿到 路線 - rid 對應

特定路線資料
  網頁 : https://pda.5284.gov.taipei/MQS/route.jsp?rid=10785
  api : https://pda.5284.gov.taipei/MQS/RouteDyna?routeid=10785&nocache=1653118677455
  需要 rid


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