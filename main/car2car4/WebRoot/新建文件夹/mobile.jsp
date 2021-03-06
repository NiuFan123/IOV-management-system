<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%
String path = request.getContextPath();
String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>

<!DOCTYPE html>
<html>
<head lang="en">

    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="initial-scale=1.0, user-scalable=no, width=device-width">
    <title>车辆管理平台</title>

    <script src="http://siteapp.baidu.com/static/webappservice/uaredirect.js" type="text/javascript"></script>
    <script type="text/javascript">uaredirect("http://m.baidu.com");</script>

    <script src="http://code.jquery.com/jquery-2.1.1.min.js"></script>
    <script src="http://code.jquery.com/mobile/1.4.5/jquery.mobile-1.4.5.min.js"></script>

    <!--<link type="text/css" rel="stylesheet" href="jquery-ui.min.css">-->
    <link rel="stylesheet" href="http://code.jquery.com/mobile/1.4.5/jquery.mobile-1.4.5.min.css"/>
    <link rel="stylesheet" href="http://cache.amap.com/lbs/static/main.css?v=1.0?v=1.0"/>

    <script type="text/javascript"
            src="http://webapi.amap.com/maps?v=1.3&key=a51711ba75b2f6f205da4e278c7ea51c&plugin=AMap.ToolBar"></script>
    <script type="text/javascript" src="http://cache.amap.com/lbs/static/addToolbar.js"></script>

    <script>
        $(document).ready(function () {
            $("#carId").attr("disabled", true);
            $("#select_ShowWhat option[value='Trail']").remove();

            $("#bt_search").click(function () {
                //点标记
                var p1 = new AMap.LngLat(116.43215, 39.922303);
                var p2 = new AMap.LngLat(116.356619, 39.917432);
                var p3 = new AMap.LngLat(116.379536, 39.960602);
                var p4 = new AMap.LngLat(116.521671, 39.932308);

                var data = new Array();
                data[0] = p1;
                data[1] = p2;
                data[2] = p3;
                data[3] = p4;
                showLocation(data);

                routePlan(data);
                /*
                 //根据起终点坐标规划驾车路线
                 var p1 = new AMap.LngLat(116.43215, 39.922303);
                 var p2 = new AMap.LngLat(116.356619, 39.917432);
                 var p3 = new AMap.LngLat(116.379536, 39.960602);
                 var p4 = new AMap.LngLat(116.521671, 39.932308);

                 var data = new Array();
                 data[0] = p1;
                 data[1] = p2;
                 data[2] = p3;
                 data[3] = p4;
                 routePlan(data);
                 */
            });

            $("#bt_carInfo").click(function () {
//                map.clearMap();//清空地图
//                alert($("#time").val());
                console.log($("#time").val());
                var time = $("#time").val();
                var time1;
                time1 = time.split(":");
                console.log("hour:" + time1[0] + "\nsecond:" + time1[1]);
            });

            $("#select-range").change(function () {
                if ($(this).val() == "single") {
//                    alert("单车");
//                    $("#carId").removeAttr("disabled");
                    $("#carId").attr("disabled", false);
                    $("#trail").attr("disabled", false);
                    $("#select_ShowWhat").append("<option value='Trail'>轨迹</option>");//添加option
//                    $("#select_showWhat").val("Trail").attr("readonly",false);
                } else {
                    $("#carId").attr("disabled", true);
                    $("#trail").attr("disabled", true);
                    $("#select_ShowWhat option[value='Trail']").remove();
                    $("#select_ShowWhat option[value='GPS']").attr("selected", "selected");
//                    $("#select_ShowWhat").val("CellId").prop("selected", true);
//                    $("#select_ShowWhat").reset();
//                    $("#select_ShowWhat").get(0).value = "2";
//                    var text1="CellId";
//                    $("#select_ShowWhat option[text = text1]").attr("selected", "selected");
//                    $("#select_showWhat").val("Trail").attr("readonly",true);
                }

            });

        });


    </script>
    <script>

        function init() {
            var mapHeight = $(window).height() - $("#div2").offset().top - $("#div2").height();
            $("#mapContainer").css({
                "position": "absolute",
                "top": $("#div1").height() + $("#div2").height() + 3,
                "height": mapHeight - 3
            });

            map = new AMap.Map("mapContainer"); //新建一个地图
            //给地图添加控件
            AMap.plugin(['AMap.ToolBar', 'AMap.MapType', 'AMap.Geolocation'],
                    function () {
                        map.addControl(new AMap.ToolBar());

//                        map.addControl(new AMap.Scale());

                        map.addControl(new AMap.MapType({
                            defaultType: 0 //使用2D地图
                        }));

                        map.addControl(new AMap.Geolocation());

                    });
            //设置城市
            AMap.event.addDomListener(document.getElementById('query'), 'click', function () {
                var cityName = document.getElementById('cityName').value;
                if (!cityName) {
                    cityName = '北京市';
                }
                map.setCity(cityName);
            });


            map.addControl(new AMap.ToolBar());
            if (AMap.UA.mobile) {
                document.getElementById('bitmap').style.display = 'none';
                bt.style.fontSize = '16px';
            } else {
                bt.style.marginRight = '10px';
            }
        }

        /**
         *
         * 显示点
         */

        function showLocation(data) {
            //添加点标记，并使用自己的icon
            $.each(data, function (index) {
                new AMap.Marker({
                    map: map,
//                position: [116.405467, 39.907761],
                    position: data[index],
                    icon: new AMap.Icon({
                        size: new AMap.Size(40, 50),  //图标大小
                        image: "http://webapi.amap.com/theme/v1.3/images/newpc/way_btn2.png",
                        imageOffset: new AMap.Pixel(0, -60)
                    })
                });
            });


        }
        /**
         * 点集合按路径规划方式连接方法。传入的data参数为坐标数组
         * @param data
         */
        function routePlan(data) {
//            alert(data);

            //驾车导航模块
            AMap.plugin(["AMap.Driving"], function () {
                drivingOption = {
                    policy: AMap.DrivingPolicy.LEAST_TIME,
                    map: map,
                    hideMarkers: true,
                    showTraffic: false
                };

                $.each(data, function (index) {
                    //index为索引
                    //name为值
                    //如果使用函数的上下文this则相当于第二个参数
                    var driving = new AMap.Driving(drivingOption); //构造驾车导航类
                    driving.search(data[index], data[index + 1], function (status, result) {
                        button.onclick = function () {
                            driving.searchOnAMAP({
                                origin: result.origin,
                                destination: result.destination
                            });
                        }
                    });

                });

            });
        }


    </script>
</head>


<body onload="init()">

<div data-role="page" id="pageone">

    <div data-role="header">
        <!--<h1>标题</h1>-->
    </div>

    <div data-role="content" style="margin: 0px;padding: 0px">

        <!--<div id="formcontener2" style="margin: 0px;padding: 0px; height: 40%;">-->

        <div id="div1" class="ui-grid-solo" style="height:20%">

            <div style="float:left;width:38%;margin-right: 2%;margin-left: 2%;">
                <select name="searchRange" id="select-range">
                    <option value="all">全部车辆</option>
                    <option value="single">指定车辆</option>
                </select>
            </div>


            <div style="float:left;width:38%;margin-right: 2%;">
                <label class="ui-hidden-accessible" for="carId">Text Input:</label>
                <input name="carId" id="carId" type="text" placeholder="请输入车架号：" value=""
                       data-clear-btn="true">
            </div>


            <div style="float:left;width:16%;margin-right: 2%;">
                <!--<a href="#" class="ui-button" id="btn1">查询</a>-->
                <button id="bt_search" type="button" data-theme="c">查询</button>
            </div>

        </div>

        <div class="ui-grid-solo" id="div2" style="height:20%">

            <div style="float:left;width:35%;margin-right: 2%;margin-left: 2%;">
                <select name="showWhat" id="select_ShowWhat">
                    <option value="GPS">GPS</option>
                    <option value="CellId">CellId</option>
                    <option id="trail" value="Trail">轨迹</option>
                </select>
            </div>


            <div style="float:left;width:41%;margin-right: 2%;">
                <input name="time" id="time" type="time" value="" data-clear-btn="true">
            </div>


            <div style="float:left;width:16%;margin-right: 2%;">
                <!--<a href="#" class="ui-button" id="btn1">查询</a>-->
                <button id="bt_carInfo" type="button">车辆信息</button>
            </div>

        </div>
        <!--style="width:100%;height:60%;background: red"class="ui-grid-solo"-->


        <div class="ui-grid-solo" id="mapContainer"></div>
        <div class="button-group" style="margin-right: 10%">
            <input id="cityName" class="inputtext" placeholder="请输入城市的名称" type="text"/>
            <input id="query" class="button" value="到指定的城市" type="button"/>
        </div>

    </div>


    <div data-role="footer">

    </div>

</div>


</body>
</html>