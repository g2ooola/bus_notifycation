# bus_notifycation

## About
想解決的問題
1. 公車到站前自動通知
2. 可供多人使用
3. 可訂閱多條路線的多個站

可優化之處
1. 到站前 x 分鐘為基礎進行通知
2. 增加新的通知渠道, 如簡訊
3. 加上訂閱的時間區間, 如 `每週二 17:00~18:00 某路線某站牌` 的到站通知
4. 增加更方便的訂閱方式

## How to user
### 前置設定
* 在 `private/secret.yml` 中加入 email smtp 設定
  * 內容格式可以參考 `privare/secret.yml.sample.yaml`
* 在 `data/subscribtion.csv` 內設定要訂閱的公車資料
  * 內容格式可參考 `data/subscribtion.csv.sample`

### 執行程式
* 直接執行
  * 執行 `ruby app/main/rb` 可開始程式, 目前設定公車到站前 7 分鐘發送 email 通知
  * 執行 `LOCAL_TEST=true ruby app/main.rb` 以測試狀態執行
    * 所有通知顯示在 terminal 上, 不寄信
* 可使用 `systemd` 確保此程式維持執行

* 執行單元測試
  * `LOCAL_TEST=true ruby app/test.rb`
