import 'dart:convert';

// import 'package:crypto_profit_loss_calculator/coin_detail.dart';
import 'package:crypto_profit_loss_calculator/trade_history.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Crypto Profit/Loss Calculator',
      theme: ThemeData.dark(),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _loadData() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      coinNameController.text = prefs.getString("coinName") ?? '';
      buyPriceController.text = prefs.getString("buyPrice") ?? '';
      currentPriceController.text = prefs.getString("currentPrice") ?? '';
      balanceController.text = prefs.getString("balance") ?? '';
      commissionController.text = prefs.getString("commission") ?? '';
      String tradeHistoryString = prefs.getString("tradeHistory") ?? '[]';
      tradeHistory =
          List<Map<String, dynamic>>.from(json.decode(tradeHistoryString));
    });
    calculate(context);
  }

  _saveData() {
    // Verileri kaydet
    prefs.setString("coinName", coinNameController.text);
    prefs.setString("buyPrice", buyPriceController.text);
    prefs.setString("currentPrice", currentPriceController.text);
    prefs.setString("balance", balanceController.text);
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
  TextEditingController balanceController = TextEditingController();
  TextEditingController commissionController = TextEditingController();
  List<Map<String, dynamic>> tradeHistory = [];
  double currentPnL = 0; //%
  double balancePnL = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  decoration: InputDecoration(labelText: 'Commission Optional'),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (value) => //submitfunc(context),
                      calculate(context),
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
                              child: Text("%" + currentPnL.toStringAsFixed(4))),
                        ),
                        // SizedBox(
                        //   width: 9,
                        // ),
                        Container(
                            padding: EdgeInsets.all(8),
                            color: balancePnL <= 0 ? Colors.red : Colors.green,
                            child: Text(balancePnL.toStringAsFixed(1) + " \$")),
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
    );
  }

  void clearfunc() {
    setState(() {
      coinNameController.text = "";
      buyPriceController.text = "";
      currentPriceController.text = "";
      balanceController.text = "";
      currentPnL = 0;
      balancePnL = 0;
    });
  }

  void submitfunc(BuildContext context) {
    if (coinNameController.text.isNotEmpty &&
        buyPriceController.text.isNotEmpty &&
        currentPriceController.text.isNotEmpty) {
      setState(() {
        tradeHistory.add({
          "s": coinNameController.text,
          "c": buyPriceController.text,
          "p": currentPriceController.text,
          "pnl": currentPnL.toStringAsFixed(4)
        });
      });
      clearfunc();
      _saveData();
      Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          return TradeHistory();
        },
      ));
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
        if (balanceController.text.isEmpty) {
          balanceController.text = "0";
        }
        balancePnL = double.parse(balanceController.text) * (currentPnL / 100);
      });
    }
  }
}
