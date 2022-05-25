var _gaq = _gaq || [];
_gaq.push(['_setAccount', 'UA-36595213-1']);
_gaq.push(['_setCustomVar', 1, 'RouteName', '672', 3]);
_gaq.push(['_trackPageview']);

(function() {
    var ga = document.createElement('script');
    ga.type = 'text/javascript';
    ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0];
    s.parentNode.insertBefore(ga, s);
})();

var PathAttrSymbolMap = {};
var VirtualStopMap = {};

// 未在此狀態中, 則其 key 為進站秒數
var TTEMap = {
    '0': '進站中',
    '': '未發車',
    '-1': '未發車',
    '-2': '交管不停',
    '-3': '末班已過',
    '-4': '今日未營運'
};
var Timer = null;



function queryDyna() {
    if (Timer != null) clearTimeout(Timer);
    http('GET', 'RouteDyna?routeid=10785', test_processDyna);
}

var golbal_VirtualStopMap = {};
var busmap = {}

// callback fundtion after queryDyna
function test_processDyna(data) {
    if (data.UpdateTime) {
        document.getElementById("spnUpdateTime").innerHTML = data.UpdateTime.substring(11);

        var okDataMS = Date.parse(data.UpdateTime.substr(0, 10) + "T" + data.UpdateTime.substring(11).replace(/&#x3a;/g, ":")) - 1200000; // 20分
        var busmap = {};

        // go through each bus info
        for (var i = 0; i < data.Bus.length; i++) {
            if (data.Bus[i].a2 == null) continue;
            if (data.Bus[i].a1 != null) {
                var arrA1 = data.Bus[i].a1.split(',');
                if (arrA1[3] == "2" || arrA1[4] == "99") continue;
            };
            var arrA2 = data.Bus[i].a2.split(',');
            if (arrA2[3] == "2" || arrA2[4] == "99") continue;

            if (/^TEST.*$/g.test(data.Bus[i].num)) continue;
            if (
                Date.parse("20" + arrA2[11].substr(0, 2) + "-" + arrA2[11].substr(2, 2) + "-" + arrA2[11].substr(4, 2) + "T" + arrA2[11].substr(6, 2) + ":" + arrA2[11].substr(8, 2) + ":" + arrA2[11].substr(10, 2))
                < okDataMS
            ) continue;

            // 測試用, 用來轉換 bus_id 的資料
            // 目前沒有相關資料
            var busStopId = arrA2[7];
            if (VirtualStopMap.hasOwnProperty(busStopId)) busStopId = VirtualStopMap[busStopId];

            // 建立一個 map : busmap[busStopId] = `當站 bus gif 圖片`
            if (!busmap.hasOwnProperty(busStopId)) busmap[busStopId] = "";
            else busmap[busStopId] += "<br>";
            busmap[busStopId] += "<img border=0 src=\"bus" + data.Bus[i].type + ".gif\"><font style=\"color:darkblue;\">" + data.Bus[i].num + (PathAttrSymbolMap.hasOwnProperty(arrA2[5]) ? PathAttrSymbolMap[arrA2[5]] : "") + "</font>";
        };

        // 網頁中, 車站的 html dom id 是 tte 開頭
        // tte + stop_id = 車站的 dom id
        //

        // TTEMap: 進站狀態的 enum 轉換
        for (var i = 0; i < data.Stop.length; i++) {
            if (data.Stop[i].n1 == null) continue;
            var arrN1 = data.Stop[i].n1.split(',');
            if (!document.getElementById("tte" + arrN1[1])) continue;

            if (TTEMap.hasOwnProperty(arrN1[7])) {
                // 若車站狀態在 enum 列表中
                if (busmap.hasOwnProperty(arrN1[1])) {
                    // 若剛才的 busmap, 有此站的資料, 則特殊處理
                    if (arrN1[7] == "0") {
                        // 進站中,  圖片放前面
                        document.getElementById("tte" + arrN1[1]).innerHTML = busmap[arrN1[1]] + "<br>" + TTEMap[arrN1[7]];
                    } else {
                        // 非進站中, 圖片放後面
                        document.getElementById("tte" + arrN1[1]).innerHTML = TTEMap[arrN1[7]] + "<br>" + busmap[arrN1[1]];
                    }
                
                } else {
                    // 若剛才的 busmap, 無此站的資料, 則單存顯示狀態
                    document.getElementById("tte" + arrN1[1]).innerHTML = TTEMap[arrN1[7]];
                }
            } else {
                // 將 arrN1[7] 轉為整數, 10 進位
                // 此時 tte > 0, 代表即將進站的秒數
                var tte = parseInt(arrN1[7], 10);
                if (busmap.hasOwnProperty(arrN1[1])) {
                    if (tte > 0 && tte < 180)
                        document.getElementById("tte" + arrN1[1]).innerHTML = busmap[arrN1[1]] + "<br>將到站";
                    else
                        document.getElementById("tte" + arrN1[1]).innerHTML = Math.floor(tte / 60) + "分<br>" + busmap[arrN1[1]];
                } else {
                    if (tte > 0 && tte < 180)
                        document.getElementById("tte" + arrN1[1]).innerHTML = "將到站";
                    else
                        document.getElementById("tte" + arrN1[1]).innerHTML = Math.floor(tte / 60) + "分";
                };
            };
        };
    };
    Timer = setTimeout(queryDyna, 60000);
}