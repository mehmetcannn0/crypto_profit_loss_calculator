import 'dart:convert';

import 'package:crypto_profit_loss_calculator/trade_history_edit.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TradeHistory extends StatefulWidget {
  const TradeHistory({super.key});
  @override
  State<TradeHistory> createState() => _TradeHistoryState();
}

class _TradeHistoryState extends State<TradeHistory> {
  late SharedPreferences prefs;
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _loadData() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      String tradeHistoryString = prefs.getString("tradeHistory") ?? '[]';
      tradeHistory =
          List<Map<String, dynamic>>.from(json.decode(tradeHistoryString));
    });
  }

  _saveData() {
    // Verileri kaydet

    prefs.setString("tradeHistory", json.encode(tradeHistory));
  }

  @override
  void dispose() {
    _saveData(); // Verileri dispose olduğunda kaydet
    super.dispose();
  }

  List<Map<String, dynamic>> tradeHistory = [
    // {"s": "btctry", "c": "123", "p": "45", "pnl": "0"},
    // {"s": "btctry", "c": "123", "p": "45", "pnl": "-1"},
    // {"s": "btctry", "c": "123", "p": "45", "pnl": "12"},
    // {"s": "btctry", "c": "123", "p": "45", "pnl": "12"}
  ];
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Crypto Profit/Loss History'),
        ),
        body: Container(
            child: ListView.builder(
          itemCount: tradeHistory.length,
          
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Card(
                color: double.parse(
                            tradeHistory[tradeHistory.length - index - 1]
                                ["pnl"]!) <=
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
                                  tradeHistory.length - index - 1);
                            },
                          ));
                        },
                      ),
                      Column(
                        children: [
                          Text(tradeHistory[tradeHistory.length - index - 1]
                              ["s"]),
                          Text(
                            "pnl: %" +
                                tradeHistory[tradeHistory.length - index - 1]
                                    ["pnl"],
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(tradeHistory[tradeHistory.length - index - 1]
                              ["c"]),
                          Text(
                            tradeHistory[tradeHistory.length - index - 1]["p"],
                          ),
                        ],
                      ),
                      InkWell(
                        child: Icon(Icons.clear_rounded),
                        onLongPress: () {
                          setState(() {
                            tradeHistory
                                .removeAt(tradeHistory.length - index - 1);
                          });
                          _saveData();
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
