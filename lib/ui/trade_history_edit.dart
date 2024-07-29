import 'package:crypto_profit_loss_calculator/model/pnl.dart';
import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import 'trade_history.dart';

// ignore: must_be_immutable
class TradeHistoryEdit extends StatefulWidget {
  int id;
  TradeHistoryEdit(this.id, {super.key});
  @override
  State<TradeHistoryEdit> createState() => _TradeHistoryEditState();
}

class _TradeHistoryEditState extends State<TradeHistoryEdit> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  late CoinPnL coinPnL;
  bool readed = false;
  double currentPnL = 0; //%
  double balancePnL = 0;
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _loadData() async {
    coinPnL = await databaseHelper.getCoinPnLbyId(widget.id);
    coinNameController.text = coinPnL.coinName!;
    buyPriceController.text = coinPnL.buyPrice!;
    currentPriceController.text = coinPnL.currentPrice!;
    commissionController.text = coinPnL.commission!;
    balanceController.text = coinPnL.balance!;
    currentPnL = double.parse(coinPnL.currentPnL!);
    balancePnL = double.parse(coinPnL.balancePnL!);
    readed = true;
  }

  _saveData() {
    calculate(context);
    databaseHelper.updateCoinPnL(CoinPnL.withID(
        coinPnL.id,
        coinNameController.text,
        buyPriceController.text,
        currentPriceController.text,
        balanceController.text,
        currentPnL.toStringAsFixed(2),
        balancePnL.toStringAsFixed(2),
        commissionController.text,
        coinPnL.date));
  }

  TextEditingController coinNameController = TextEditingController();
  TextEditingController buyPriceController = TextEditingController();
  TextEditingController currentPriceController = TextEditingController();
  TextEditingController commissionController = TextEditingController();
  TextEditingController balanceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Crypto Profit/Loss Edit'),
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
                    decoration:
                        InputDecoration(labelText: 'Commission Optional'),
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
                              calculate(context);
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
      _saveData();
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return const TradeHistory();
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
        if (balanceController.text.isEmpty) {
          balanceController.text = "0";
        }
        balancePnL = double.parse(balanceController.text) * (currentPnL / 100);
      });
    }
  }
}
