# bluetooth
####  以架構上來說,依照Apple的定義,區分為兩大角色: Central與Peripheral, 
週邊設備稱為Peripheral ,而讀取週邊設備資料的行動裝置稱為Central ,由於資料是位於Peripheral,
所以Apple有時也會稱呼Peripheral為Server,而Central為 Client。  

*  Peripheral會透過定時的廣播(Advertising),來讓Central發現自己的存在,進而可以進行進一步的連線作業。 
但是Peripheral廣播的頻率如何設定! 廣播得太頻繁將會增加耗電,廣播的間隔時間拉得太長又會造成Central發現Peripheral的困難,各家BLE產品的製造商,
都需要下不少功夫來微調自家產品這部分的參數,以期可以在省電與使用性上可以達成平衡。
各式的Peripheral都會各自進行廣播,以便於讓Central發現自己的存在,且每一個 Peripheral都會帶一個唯一的UUID碼,以做為區別。  

*  Central發現Peripheral的存在後,可以與Peripheral連線,以便於確認Peripheral提供的哪些功能與服,
每一個Peripheral都會定義若干個Service與Characteristic來讓Central來識別所提供的資訊與服務,
通常都至少會有一個Service,而Service裡面也會定義一個或 者多個Characteristic,以各自提供各種資訊.
Characteristic本身有可能僅支援讀取僅支援寫入或者讀寫都支援,至於會提供哪些功能與機制,就由產品製造商自行視需要而做定義,沒有一定的規範。  
*  Apple於CoreBluetooth Framework中,提供了相關機制,讓iOS裝置可以成為Central,也可以成為Peripheral。
成為Peripheral時,可以透過撰寫程式碼,來提供其他裝置各式的服務與功能,也可以因此而發展出許多有趣的應用。
SIG並沒有明確的定義每一個BLE產品的最高同時連線數為多少,但就經驗上的實測, iOS裝置為Central時,有可能同時與六~八個Peripheral周邊進行連線。
傳輸速度上來說雖然理論值可以到1Mbps但以實務應用來做實測幾乎都只有17-20Kbps而已,若想透過BLE來傳大量的資料,基本上是蠻不合適的。 
