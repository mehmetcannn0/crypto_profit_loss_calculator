class CoinPnL {
  int? id;
  String? coinName;
  String? buyPrice;
  String? currentPrice;
  String? balance;
  String? currentPnL;
  String? balancePnL;
  String? commission;
  String? date;

  CoinPnL(this.coinName, this.buyPrice, this.currentPrice, this.balance,
      this.currentPnL, this.balancePnL, this.commission, this.date);
  CoinPnL.withID(
      this.id,
      this.coinName,
      this.buyPrice,
      this.currentPrice,
      this.balance,
      this.currentPnL,
      this.balancePnL,
      this.commission,
      this.date);
  CoinPnL.fromMap(Map map) {
    this.id = map["id"];
    this.coinName = map["coinName"];
    this.buyPrice = map["buyPrice"];
    this.currentPrice = map["currentPrice"];
    this.balance = map["balance"];
    this.currentPnL = map["currentPnL"];
    this.balancePnL = map["balancePnL"];
    this.commission = map["commission"];
    this.date = map["date"];

    // print("from map içi ${this.id} ${this.coinName} ${this.date}");
  }

  Map<String, dynamic> toMap() => {
        "id": id,
        "coinName": coinName,
        "buyPrice": buyPrice,
        "currentPrice": currentPrice,
        "balance": balance,
        "currentPnL": currentPnL,
        "balancePnL": balancePnL,
        "commission": commission,
        "date": date,
      };
}
