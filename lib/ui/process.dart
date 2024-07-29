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
          prefs.getString("coinName" + widget.id.toString()) ?? '';
      buyPriceController.text =
          prefs.getString("buyPrice" + widget.id.toString()) ?? '';
      currentPriceController.text =
          prefs.getString("currentPrice" + widget.id.toString()) ?? '';
      balanceController.text =
          prefs.getString("balance" + widget.id.toString()) ?? '';
      commissionController.text =
          prefs.getString("commission" + widget.id.toString()) ?? '';
    });
    calculate(context);
  }

  _saveData() {
    //button count +1 ıse yenı eklenecek degılse update yapılacak
    int processCount = prefs.getInt('processCount') ?? 0;
    if (processCount + 1 == widget.id) {
      prefs.setInt("processCount", processCount + 1);
    }
    // Verileri kaydet
    prefs.setString("coinName" + widget.id.toString(), coinNameController.text);
    prefs.setString("buyPrice" + widget.id.toString(), buyPriceController.text);
    prefs.setString(
        "currentPrice" + widget.id.toString(), currentPriceController.text);
    prefs.setString("balance" + widget.id.toString(), balanceController.text);
    prefs.setString(
        "commission" + widget.id.toString(), commissionController.text);
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
                              child: Text("%" + currentPnL.toStringAsFixed(2))),
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
        databaseHelper.addPnl(CoinPnL(
            coinNameController.text,
            buyPriceController.text,
            currentPriceController.text,
            balanceController.text,
            currentPnL.toStringAsFixed(2),
            balancePnL.toStringAsFixed(2),
            commissionController.text,
            DateTime.now().toString()));
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

  void mexcapi() async {
    setState(() {
      apiStatus = 2;
    });
    // print("api cagırıldı ->" + coinNameController.text.trim() + "deneme");
    final snackBar = SnackBar(
        content: Text(
            'Fetching data for ${coinNameController.text.toUpperCase()}/USDT from Mexc, please wait...'),
        duration: Duration(seconds: 15), // Snackbar'ın görüntüleme süres
        backgroundColor: Colors.amber);
    ScaffoldMessenger.of(context).showSnackBar(snackBar); // Snackbar'ı göster

    final response = await http.get(Uri.parse(
        'https://www.mexc.com/open/api/v2/market/ticker?symbol=${coinNameController.text.toLowerCase().trim()}_usdt'));
    ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Snackbar'ı kapat

    print(response);
    print(response.statusCode);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> data = responseData['data'];
      if (data.isNotEmpty) {
        final Map<String, dynamic> coinData = data[0];
        final double coinPrice = double.parse(coinData['last']);
        print('Coin Price: $coinPrice');
        currentPriceController.text = coinPrice.toStringAsFixed(2);
        // Snackbar'ı güncelleyerek işlem başarılı mesajını göster
        final successSnackBar = SnackBar(
            content: Text('Data fetched successfully from Mexc!'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green);
        ScaffoldMessenger.of(context).showSnackBar(successSnackBar);
        setState(() {
          apiStatus = 1;
        });
        calculate(context);
        _saveData();
      } else {
        // Hata durumunda Snackbar ile kullanıcıya bilgi ver
        final errorSnackBar = SnackBar(
            content: Text('Failed to fetch data from Mexc!'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red);
        ScaffoldMessenger.of(context).showSnackBar(errorSnackBar);
        print('No data available');
        setState(() {
          apiStatus = 0;
        });
      }
    } else {
      print('Failed to load coin price');
      setState(() {
        apiStatus = 0;
      });
    }
  }

}
