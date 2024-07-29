import 'package:crypto_profit_loss_calculator/ui/process.dart';
import 'ui/trade_history.dart';
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
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with RouteAware {
  late SharedPreferences prefs;
  int _buttonCount = 0;

  @override
  void initState() {
    super.initState();
    _loadButtonCount();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // RouteObserver'ı dinleyici olarak ekleyin
    RouteObserver<ModalRoute<void>>().subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    // RouteObserver'dan dinleyiciyi kaldırın
    RouteObserver<ModalRoute<void>>().unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Bu method MainScreen'e geri dönüldüğünde çağrılır
    _loadButtonCount();

    setState(() {});
  }

  Future<void> _loadButtonCount() async {
    print("buton sayısı guncellendı");

    prefs = await SharedPreferences.getInstance();
    setState(() {
      _buttonCount = prefs.getInt('processCount') ?? 0;
    });
  }

  Future<List<Widget>> _buildButtons() async {
    print("butonlar guncellendı");
    List<Widget> buttons = [];

    prefs = await SharedPreferences.getInstance();
    setState(() {
      _buttonCount = prefs.getInt('processCount') ?? 0;
    });
    // En üstte yeni ekleme butonu
    buttons.add(
      InkWell(
        onTap: () => _navigateToProcessPage(_buttonCount + 1),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColorLight,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(
              'Yeni Ekle',
              style: TextStyle(
                  color: Theme.of(context).primaryColorDark,
                  fontSize: 19,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
    for (int i = 1; i <= _buttonCount; i++) {
      double currentPnL = 0; //%
      double balancePnL = 0;
      String coinName = prefs.getString("coinName" + i.toString()) ?? '';
      String buyPrice = prefs.getString("buyPrice" + i.toString()) ?? '';
      String currentPrice =
          prefs.getString("currentPrice" + i.toString()) ?? '';
      String balance = prefs.getString("balance" + i.toString()) ?? '';

      String commission = prefs.getString("commission" + i.toString()) ?? '';

      if (coinName != "") {
        currentPnL =
            ((double.parse(currentPrice) / double.parse(buyPrice) * 100) -
                    100) *
                (1 - ((double.parse(commission)) * 2));

        balancePnL = double.parse(balance) * (currentPnL / 100);
        buttons.add(
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: currentPnL >= 0
                      ? Theme.of(context).primaryColorLight
                      : Colors.red),
              child: ListTile(
                leadingAndTrailingTextStyle: TextStyle(fontSize: 20),
                onTap: () => _navigateToProcessPage(i),
                // tileColor: Theme.of(context).primaryColorLight,
                textColor: Theme.of(context).primaryColorDark,
                leading: Text('$i'),
                title: Text(coinName),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(currentPnL.toStringAsFixed(2) + " %"),
                    // Text("$balancePnL"),
                  ],
                ),
                subtitle:
                    Text("buyprice $buyPrice current price $currentPrice "),
              ),
            ),
          ),
        );
      }
    }
    return buttons;
  }

  void _navigateToProcessPage(int buttonId) async {
    bool? isUpdated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Process(buttonId),
      ),
    );
    if (isUpdated == true) {
      _loadButtonCount();
      setState(() {});
    }
  }

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
      body: FutureBuilder<List<Widget>>(
        future: _buildButtons(),
        builder: (context, snapshot) {
          // if (snapshot.connectionState == ConnectionState.waiting) {
          //   return Center(child: CircularProgressIndicator());
          // } else
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            _buttonCount;

            return SingleChildScrollView(
              child: Center(
                child: Column(
                  children: snapshot.data ?? [],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
