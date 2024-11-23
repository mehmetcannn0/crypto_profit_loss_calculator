import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:crypto_profit_loss_calculator/model/pnl.dart';
import 'package:crypto_profit_loss_calculator/services/database_helper.dart';
import 'package:crypto_profit_loss_calculator/ui/trade_history.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Process extends StatefulWidget {
  int id;

  Process(this.id, {super.key});
  @override
  _ProcessState createState() => _ProcessState();
}

class _ProcessState extends State<Process> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  late SharedPreferences prefs;
  int apiStatus = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _loadData() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      coinNameController.text =
          prefs.getString("coinName${widget.id}")?.toUpperCase() ?? '';
      buyPriceController.text = prefs.getString("buyPrice${widget.id}") ?? '';
      currentPriceController.text =
          prefs.getString("currentPrice${widget.id}") ?? '';
      balanceController.text = prefs.getString("balance${widget.id}") ?? '';
      commissionController.text =
          prefs.getString("commission${widget.id}") ?? '';
    });
    calculate();
  }

  _saveData() {
    if (_areInputsValid()) {
      //button count +1 ıse yenı eklenecek degılse update yapılacak
      int processCount = prefs.getInt('processCount') ?? 0;
      if (processCount + 1 == widget.id) {
        prefs.setInt("processCount", processCount + 1);
      }
      // Verileri kaydet
      prefs.setString(
          "coinName${widget.id}", coinNameController.text.toUpperCase());
      prefs.setString("buyPrice${widget.id}", buyPriceController.text);
      prefs.setString("currentPrice${widget.id}", currentPriceController.text);
      prefs.setString("balance${widget.id}", balanceController.text);
      prefs.setString("commission${widget.id}", commissionController.text);
    }
  }

  // @override
  // void dispose() {
  //   _saveData(); // Verileri dispose olduğunda kaydet
  //   super.dispose();
  // }

  TextEditingController coinNameController = TextEditingController();
  TextEditingController buyPriceController = TextEditingController();
  TextEditingController currentPriceController = TextEditingController();
  TextEditingController balanceController = TextEditingController();
  TextEditingController commissionController = TextEditingController();

  double currentPnL = 0; //%
  double balancePnL = 0;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_areInputsValid()) {
          Navigator.pop(context, true);
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return TradeHistory();
                      },
                    )),
                icon: Icon(Icons.history))
          ],
          title: Text('Crypto Profit/Loss Calculator'),
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
                    keyboardType: TextInputType.number,
                  ),
                  trailing: IconButton(
                      onPressed: () => (coinNameController.text.isNotEmpty &&
                              buyPriceController.text.isNotEmpty)
                          ? mexcapi()
                          : () {},
                      icon: Icon(
                        Icons.replay,
                        color: apiStatus == 0
                            ? Colors.red
                            : apiStatus == 1
                                ? Colors.green
                                : apiStatus == 2
                                    ? Colors.amber
                                    : Colors.white,
                      )),
                ),
                SizedBox(height: 3),
                ListTile(
                  title: TextField(
                    controller: balanceController,
                    decoration: InputDecoration(labelText: 'Balance Optional'),
                    textInputAction: TextInputAction.next,
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
                    onSubmitted: (value) => calculate(),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(height: 3),
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
                                    Text("%" + currentPnL.toStringAsFixed(2))),
                          ),
                          // SizedBox(
                          //   width: 9,
                          // ),
                          Container(
                              padding: EdgeInsets.all(8),
                              color:
                                  balancePnL <= 0 ? Colors.red : Colors.green,
                              child:
                                  Text(balancePnL.toStringAsFixed(1) + " \$")),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              if (calculate()) {
                                _saveData();
                              }
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
                              clearfunc();
                            },
                            child: Container(
                              // padding: EdgeInsets.all(12),
                              // color: Colors.black26,
                              child: Text(
                                style: TextStyle(color: Colors.white),
                                'Clear',
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              submitfunc();
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

  void clearfunc() {
    setState(() {
      coinNameController.clear();
      buyPriceController.clear();
      currentPriceController.clear();
      balanceController.clear();
      commissionController.clear();
      currentPnL = 0;
      balancePnL = 0;
    });
  }

  void submitfunc() {
    if (_areInputsValid()) {
      databaseHelper.addPnl(CoinPnL(
        coinNameController.text,
        buyPriceController.text,
        currentPriceController.text,
        balanceController.text,
        currentPnL.toStringAsFixed(2),
        balancePnL.toStringAsFixed(2),
        commissionController.text,
        DateTime.now().toIso8601String(),
      ));
      clearfunc();
      _saveData();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Trade saved successfully!"),
        backgroundColor: Colors.green,
      ));
    }
  }

  bool calculate() {
    if (_areInputsValid()) {
      setState(() {
        if (commissionController.text.isEmpty) {
          commissionController.text = "0";
        }
        try {
          final buyPrice = double.parse(buyPriceController.text);
          final currentPrice = double.parse(currentPriceController.text);
          final commission = double.tryParse(commissionController.text) ?? 0;

          currentPnL =
              (((currentPrice / buyPrice) - 1) * 100) * (1 - (commission * 2));
          balancePnL =
              currentPnL * (double.tryParse(balanceController.text) ?? 0) / 100;
        } catch (e) {
          currentPnL = 0;
          balancePnL = 0;
        }
      });
      return true;
    } else {
      return false;
    }
  }

  Future<void> mexcapi() async {
    if (coinNameController.text.isEmpty) return;
    setState(() => apiStatus = 2);

    try {
      final response = await http.get(Uri.parse(
          'https://www.mexc.com/open/api/v2/market/ticker?symbol=${coinNameController.text.toLowerCase().trim()}_usdt'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        if (data.isNotEmpty) {
          currentPriceController.text =
              double.parse(data[0]['last']).toStringAsFixed(2);
          apiStatus = 1;
        } else {
          apiStatus = 0;
        }
      } else {
        apiStatus = 0;
      }
    } catch (_) {
      apiStatus = 0;
    }
    if (calculate()) {
      _saveData();
    }

    setState(() {});
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Invalid Input'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  bool _areInputsValid() {
    if (coinNameController.text.isEmpty) {
      _showError("Coin name cannot be empty.");
      return false;
    }
    if (double.tryParse(buyPriceController.text) == null) {
      _showError("Enter a valid buy price.");
      return false;
    }
    if (double.tryParse(currentPriceController.text) == null) {
      _showError("Enter a valid current price.");
      return false;
    }
    if (commissionController.text.isNotEmpty &&
        double.tryParse(commissionController.text) == null) {
      _showError("Enter a valid value for commission or leave it blank.");
      return false;
    }
    if (balanceController.text.isNotEmpty &&
        double.tryParse(balanceController.text) == null) {
      _showError("Enter a valid value for balance or leave it blank.");
      return false;
    }
    return true;
  }
}
