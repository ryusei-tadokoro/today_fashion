import "./jquery.japan-map"; 

;(function($){
  "use strict";

  $(function(){
      var mapContainer = $("#map-container");
      var canvas = mapContainer.find("canvas");

      // コンテナのサイズをキャンバスに設定
      canvas.attr("width", mapContainer.width());
      canvas.attr("height", mapContainer.height());

      var showWeatherPath = mapContainer.data("show-weather-path");

      var areas = [
          {"code": 1 , "name":"北海道地方", "color":"#ca93ea", "hoverColor":"#e0b1fb", "prefectures":[1]},
          {"code": 2 , "name":"東北地方",   "color":"#a7a5ea", "hoverColor":"#d6d4fd", "prefectures":[2,3,4,5,6,7]},
          {"code": 3 , "name":"関東地方",   "color":"#84b0f6", "hoverColor":"#c1d8fd", "prefectures":[8,9,10,11,12,13,14]},
          {"code": 4 , "name":"北陸・甲信越地方", "color":"#52d49c", "hoverColor":"#93ecc5", "prefectures":[15,16,17,18,19,20]},
          {"code": 5 , "name":"東海地方",   "color":"#77e18e", "hoverColor":"#aff9bf", "prefectures":[21,22,23,24]},
          {"code": 6 , "name":"近畿地方",   "color":"#f2db7b", "hoverColor":"#f6e8ac", "prefectures":[25,26,27,28,29,30]},
          {"code": 7 , "name":"中国地方",   "color":"#f9ca6c", "hoverColor":"#ffe5b0", "prefectures":[31,32,33,34,35]},
          {"code": 8 , "name":"四国地方",   "color":"#fbad8b", "hoverColor":"#ffd7c5", "prefectures":[36,37,38,39]},
          {"code": 9 , "name":"九州地方",   "color":"#f7a6a6", "hoverColor":"#ffcece", "prefectures":[40,41,42,43,44,45,46]},
          {"code":10 , "name":"沖縄地方",   "color":"#ea89c4", "hoverColor":"#fdcae9", "prefectures":[47]}
      ];

      mapContainer.japanMap({
          areas  : areas,
          selection : "prefecture",
          borderLineWidth: 0.25,
          drawsBoxLine : false,
          movesIslands : true,
          showsAreaName : true,
          width: 800,
          font : "MS Mincho",
          fontSize : 12,
          fontColor : "areaColor",
          fontShadowColor : "black",
          onHover: function(data){
            $("#text").text(data.name).css("background-color", data.area.hoverColor).show();
          },
          onSelect : function(data){
              var url = showWeatherPath + "?city=" + encodeURIComponent(data.name);
              window.location.href = url;
          }
      });
  });

})(jQuery);
