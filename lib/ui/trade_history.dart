import 'package:crypto_profit_loss_calculator/model/pnl.dart';
import 'package:crypto_profit_loss_calculator/ui/pnl_history.dart';

import '../services/database_helper.dart';
import 'trade_history_edit.dart';
import 'package:flutter/material.dart';

class TradeHistory extends StatefulWidget {
  const TradeHistory({super.key});
  @override
  State<TradeHistory> createState() => _TradeHistoryState();
}

class _TradeHistoryState extends State<TradeHistory> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  int? lenght;
  bool readed = false;
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  List<CoinPnL> coinPnL = [];

  _loadData() async {
    coinPnL = await databaseHelper.getCoinPnLList();
    int lenghtLocal;

    setState(() {
      lenghtLocal = coinPnL.length;

      lenght = lenghtLocal;
      readed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Crypto Profit/Loss History'),
          actions: [
            IconButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        print("line");
                        return Container();
                        // return PnLHistory(0);
                      },
                    )),
                icon: Icon(Icons.data_thresholding_sharp)),
          ],
        ),
        body: Container(
            child: ListView.builder(
          itemCount: coinPnL.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Card(
                color: double.parse(
                            coinPnL[coinPnL.length - index - 1].currentPnL!) <=
                        0
                    ? Colors.red
                    : Colors.green,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        child: Icon(Icons.edit),
                        onLongPress: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return TradeHistoryEdit(
                                  coinPnL[coinPnL.length - index - 1].id!);
                            },
                          ));
                        },
                      ),
                      Column(
                        children: [
                          Text(coinPnL[coinPnL.length - index - 1].coinName!),
                          Text(
                            "pnl: %" +
                                coinPnL[coinPnL.length - index - 1].currentPnL!,
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(coinPnL[coinPnL.length - index - 1].buyPrice!),
                          Text(
                            coinPnL[coinPnL.length - index - 1].currentPrice!,
                          ),
                        ],
                      ),
                      InkWell(
                        child: Icon(Icons.clear_rounded),
                        onLongPress: () {
                          setState(() {
                            databaseHelper.deletePnl(
                                coinPnL[coinPnL.length - index - 1].id!);
                            _loadData();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        )),
      ),
    );
  }
}
