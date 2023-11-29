import 'dart:convert';

import 'package:crypto_profit_loss_calculator/trade_history.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TradeHistoryEdit extends StatefulWidget {
  // String coinSymbol;
  // String coinCost;
  // String currentPrice;
  int currentIndex;
  TradeHistoryEdit(
      this.currentIndex, //, this.coinSymbol, this.coinCost, this.currentPrice,
      {super.key});
  @override
  State<TradeHistoryEdit> createState() => _TradeHistoryEditState();
}

class _TradeHistoryEditState extends State<TradeHistoryEdit> {
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _loadData() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString("commission", commissionController.text);
      String tradeHistoryString = prefs.getString("tradeHistory") ?? '[]';
      tradeHistory =
          List<Map<String, dynamic>>.from(json.decode(tradeHistoryString));
      coinNameController.text = tradeHistory[widget.currentIndex]["s"];
      buyPriceController.text = tradeHistory[widget.currentIndex]["c"];
      currentPriceController.text = tradeHistory[widget.currentIndex]["p"];
    });
  }

  _saveData() {
    // Verileri kaydet
    prefs.setString("commission", commissionController.text);
    prefs.setString("tradeHistory", json.encode(tradeHistory));
  }

  @override
  void dispose() {
    _saveData(); // Verileri dispose olduğunda kaydet
    super.dispose();
  }

  TextEditingController coinNameController = TextEditingController();
  TextEditingController buyPriceController = TextEditingController();
  TextEditingController currentPriceController = TextEditingController();
  TextEditingController commissionController = TextEditingController();
  List<Map<String, dynamic>> tradeHistory = [
    // {"s": "btctry", "c": "123", "p": "45", "pnl": "0"},
    // {"s": "btctry", "c": "123", "p": "45", "pnl": "-1"},
    // {"s": "btctry", "c": "123", "p": "45", "pnl": "12"},
    // {"s": "btctry", "c": "123", "p": "45", "pnl": "12"}
  ];
  double currentPnL = 0;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Crypto Profit/Loss Edit'),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ListTile(
                  title: TextField(
                    controller: coinNameController,
                    decoration: InputDecoration(labelText: 'Coin Name'),
                    textInputAction: TextInputAction.next,
                  ),
                  trailing: Text("/usdt"),
                ),
                SizedBox(height: 3),
                ListTile(
                  title: TextField(
                    controller: buyPriceController,
                    decoration: InputDecoration(labelText: 'Buy Price'),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(height: 3),
                ListTile(
                  title: TextField(
                    controller: currentPriceController,
                    decoration: InputDecoration(labelText: 'Current Price'),
                    textInputAction: TextInputAction.next,
                    onSubmitted: (value) => //submitfunc(context),
                        calculate(context),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(height: 3),
                ListTile(
                  title: TextField(
                    controller: commissionController,
                    decoration:
                        InputDecoration(labelText: 'Commission Optional'),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (value) => //submitfunc(context),
                        calculate(context),
                    keyboardType: TextInputType.number,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Container(
                                padding: EdgeInsets.all(8),
                                color:
                                    currentPnL <= 0 ? Colors.red : Colors.green,
                                child:
                                    Text("%" + currentPnL.toStringAsFixed(4))),
                          ),
                          // SizedBox(
                          //   width: 9,
                          // ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              calculate(context);
                              _saveData();
                            },
                            child: Container(
                              // padding: EdgeInsets.all(12),
                              // color: Colors.black26,
                              child: Text(
                                style: TextStyle(color: Colors.white),
                                'Calculate',
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              submitfunc(context);
                            },
                            child: Container(
                              // padding: EdgeInsets.all(12),
                              // color: Colors.black26,
                              child: Text(
                                style: TextStyle(color: Colors.white),
                                'Save',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void submitfunc(BuildContext context) {
    if (coinNameController.text.isNotEmpty &&
        buyPriceController.text.isNotEmpty &&
        currentPriceController.text.isNotEmpty) {
      setState(() {
        tradeHistory[widget.currentIndex]["s"] = coinNameController.text;
        tradeHistory[widget.currentIndex]["c"] = buyPriceController.text;
        tradeHistory[widget.currentIndex]["p"] = currentPriceController.text;
        tradeHistory[widget.currentIndex]["pnl"] =
            currentPnL.toStringAsFixed(4);

        // .add({
        //   "s": coinNameController.text,
        //   "c": buyPriceController.text,
        //   "p": currentPriceController.text,
        //   "pnl": currentPnL.toStringAsFixed(3)
        // });
      });
      _saveData();
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return TradeHistory();
          },
        ),
      );
    }
  }

  calculate(BuildContext context) {
    if (coinNameController.text.isNotEmpty &&
        buyPriceController.text.isNotEmpty &&
        currentPriceController.text.isNotEmpty) {
      setState(() {
        if (commissionController.text.isEmpty) {
          commissionController.text = "0";
        }
        currentPnL = ((double.parse(currentPriceController.text) /
                    double.parse(buyPriceController.text) *
                    100) -
                100) *
            (1 - ((double.parse(commissionController.text)) * 2));
      });
    }
  }
}
