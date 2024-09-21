import 'package:crypto_profit_loss_calculator/services/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

import '../model/pnl.dart';

class PnLHistory extends StatefulWidget {
  int type;
  PnLHistory(this.type, {super.key});
  @override
  State<PnLHistory> createState() => _PnLHistoryState();
}

class _PnLHistoryState extends State<PnLHistory> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  int? length;
  bool readed = false;
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  List<CoinPnL> coinPnL = [];

  _loadData() async {
    coinPnL = await databaseHelper.getCoinPnLList();
    // for (var element in coinPnL) {
    //   print(element.id.toString() +
    //       " " +
    //       element.date.toString() +
    //       " " +
    //       element.currentPnL.toString() +
    //       " " +
    //       element.balancePnL.toString() +
    //       " " +
    //       element.coinName.toString());
    // }

    setState(() {
      length = coinPnL.length;
      readed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        actions: [
          widget.type == 0
              ? IconButton(
                  onPressed: () => setState(() {
                        widget.type = 1;
                      }),
                  icon: Icon(Icons.pie_chart))
              : IconButton(
                  onPressed: () => setState(() {
                        widget.type = 0;
                      }),
                  icon: Icon(Icons.data_thresholding_sharp)),
        ],
      ),
      body: widget.type == 0 ? _buildLineChart() : _buildPieChart(),
    ));
  }

  Widget _buildLineChart() {
    if (!readed) {
      return CircularProgressIndicator();
    }

    if (length == 0) {
      return Text('No data available.');
    }

    List<CoinPnL> _sumDataByDate(List<CoinPnL> data) {
      Map<String, CoinPnL> summedDataMap = {};

      for (CoinPnL coin in data) {
        // Tarih formatını ayarla
        DateTime dateTime = DateTime.parse(coin.date!);
        String formattedDate = DateFormat('MM-dd-yyyy').format(dateTime);
        // String formattedDate = DateFormat('MM-dd').format(dateTime) +
        //     "\n" +
        //     DateFormat('yyyy').format(dateTime);

        if (summedDataMap.containsKey(formattedDate)) {
          summedDataMap[formattedDate]!.balancePnL =
              (double.parse(summedDataMap[formattedDate]!.balancePnL!) +
                      double.parse(coin.balancePnL!))
                  //// .toStringAsFixed(2)
                  .toString();
        } else {
          summedDataMap[formattedDate] = CoinPnL(
            coin.coinName,
            coin.buyPrice,
            coin.currentPrice,
            coin.balance,
            coin.currentPnL,
            coin.balancePnL,
            coin.commission,
            formattedDate,
          );
        }
      }
      // for (var day in summedDataMap.keys) {
      //   print(day + " pnl " + summedDataMap[day]!.balancePnL.toString());
      // }

      //       for (var element in coinPnL) {
      //   print(element.id.toString() +
      //       " " +
      //       element.date.toString() +
      //       " " +
      //       element.currentPnL.toString() +
      //       " " +
      //       element.balancePnL.toString() +
      //       " " +
      //       element.coinName.toString());
      // }

      return summedDataMap.values.toList();
    }

    return SfCartesianChart(
      primaryXAxis: CategoryAxis(
        title: AxisTitle(text: 'Date'),
        labelIntersectAction: AxisLabelIntersectAction.rotate45,
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(text: 'Balance PnL'),
      ),
      series: <LineSeries<CoinPnL, String>>[
        LineSeries<CoinPnL, String>(
          dataSource: _sumDataByDate(coinPnL),
          xValueMapper: (CoinPnL coin, _) =>
              coin.date!.substring(0, 5) +
              "\n" +
              coin.date!.substring(
                6,
              ),
          yValueMapper: (CoinPnL coin, _) =>
              double.tryParse(coin.balancePnL!) ?? 0,
        ),
      ],
      tooltipBehavior: TooltipBehavior(
        animationDuration: 500,
        enable: true,
        builder: (dynamic data, dynamic point, dynamic series, int pointIndex,
            int seriesIndex) {
          // Tooltip
          return Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    // '${point.y}',
                    data.date,
                    style: TextStyle(color: Colors.black),
                  ),
                  Text(
                    point.y.toString(),
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPieChart() {
    if (!readed) {
      return CircularProgressIndicator();
    }

    if (length == 0) {
      return Text('No data available.');
    }

    List<CoinPnL> summedData = _sumDataByCoinName(coinPnL);

    return SfCircularChart(
      series: <CircularSeries<CoinPnL, String>>[
        DoughnutSeries<CoinPnL, String>(
          dataSource: summedData,
          xValueMapper: (CoinPnL coin, _) => coin.coinName!,
          yValueMapper: (CoinPnL coin, _) =>
              double.tryParse(coin.currentPnL!) ?? 0,
          dataLabelSettings: DataLabelSettings(isVisible: true),
          dataLabelMapper: (datum, index) => "%" + datum.currentPnL.toString(),
        ),
      ],
      legend: Legend(isVisible: true),
      tooltipBehavior: TooltipBehavior(
        header: "Coin and PnL",
        animationDuration: 500,
        enable: true,
        format: 'point.x : %point.y', // Tooltip format
      ),
    );
  }

  List<CoinPnL> _sumDataByCoinName(List<CoinPnL> data) {
    Map<String, CoinPnL> summedDataMap = {};

    for (CoinPnL coin in data) {
      if (summedDataMap.containsKey(coin.coinName)) {
        summedDataMap[coin.coinName]!.currentPnL =
            (double.parse(summedDataMap[coin.coinName]!.currentPnL!) +
                    double.parse(coin.currentPnL!))
                .toString();
      } else {
        summedDataMap[coin.coinName.toString()] = CoinPnL(
          coin.coinName,
          '',
          '',
          '',
          coin.currentPnL,
          '',
          '',
          '',
        );
      }
    }

    return summedDataMap.values.toList();
  }
}
