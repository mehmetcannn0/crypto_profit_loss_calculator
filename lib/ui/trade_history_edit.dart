import 'package:crypto_profit_loss_calculator/model/pnl.dart';
import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import 'trade_history.dart';

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
    setState(() {
      coinNameController.text = coinPnL.coinName!;
      buyPriceController.text = coinPnL.buyPrice!;
      currentPriceController.text = coinPnL.currentPrice!;
      commissionController.text = coinPnL.commission!;
      balanceController.text = coinPnL.balance!;
      currentPnL = double.parse(coinPnL.currentPnL!);
      balancePnL = double.parse(coinPnL.balancePnL!);
      readed = true;
    });
  }

  _saveData() {
    if (_areInputsValid()) {
      calculate();
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
                    decoration: const InputDecoration(labelText: 'Coin Name'),
                    textInputAction: TextInputAction.next,
                  ),
                  trailing: const Text("/usdt"),
                ),
                const SizedBox(height: 3),
                ListTile(
                  title: TextField(
                    controller: buyPriceController,
                    decoration: const InputDecoration(labelText: 'Buy Price'),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(height: 3),
                ListTile(
                  title: TextField(
                    controller: currentPriceController,
                    decoration:
                        const InputDecoration(labelText: 'Current Price'),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(height: 3),
                ListTile(
                  title: TextField(
                    controller: balanceController,
                    decoration:
                        const InputDecoration(labelText: 'Balance Optional'),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(height: 3),
                ListTile(
                  title: TextField(
                    controller: commissionController,
                    decoration:
                        const InputDecoration(labelText: 'Commission Optional'),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (value) => calculate(),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            color: currentPnL <= 0 ? Colors.red : Colors.green,
                            child: Text("%${currentPnL.toStringAsFixed(2)}"),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            color: balancePnL <= 0 ? Colors.red : Colors.green,
                            child: Text("${balancePnL.toStringAsFixed(1)} \$"),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: calculate,
                            child: const Text(
                              'Calculate',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          TextButton(
                            onPressed: submitfunc,
                            child: const Text(
                              'Save',
                              style: TextStyle(color: Colors.white),
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

  void submitfunc() {
    if (_areInputsValid()) {
      _saveData();
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const TradeHistory(),
        ),
      );
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
