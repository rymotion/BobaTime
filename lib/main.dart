import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';

void main() => runApp(MyApp());
final Map<String, String> drinkOrder = {
  "drinkType": "Smoothie",
  "size": "Small",
  "addons": "None",
  "flavor": ""
};
final List<String> drinkType = ["Smoothie", "Milk Tea", "Brewed Drink"];
final Map<String, double> size = {"Small": 350, "Medium": 450, "Large": 550};
final Map<String, int> flavor = {
  "Matcha": 0xFF69bf64,
  "Taro": 0xFF8878c3,
  "Charcoal": 0xFF36454f
};

bool canInteract = false, animateToppings = false;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(theme: ThemeData.dark(), home: MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String selectedType, _animation, chosFlav;
  Iterator d = drinkType.iterator,
      f = flavor.keys.iterator,
      s = size.keys.iterator;

  var orderSize;
  List cart = new List();
  String editingState = "Customize";

  @override
  void initState() {
    super.initState();
    setState(() {
      orderSize = size[drinkOrder['size']];
      selectedType = drinkOrder["drinkType"];
    });
  }

  void update(Iterator curr, Iterable structure, String key) {
    curr.moveNext()
        ? setState(() {
            drinkOrder.update(key, (data) => curr.current);
          })
        : curr = structure.iterator;
  }

  Widget orderStatus(BuildContext context) {
    return Stack(alignment: Alignment.center, children: <Widget>[
      Stack(alignment: Alignment.bottomCenter, children: <Widget>[
        AnimatedContainer(
            duration: new Duration(seconds: 1),
            curve: Curves.bounceOut,
            width: MediaQuery.of(context).size.width - 50,
            height: size[drinkOrder['size']],
            color: Color(flavor[drinkOrder["flavor"]] ?? 0xFF4CAEE3),
            child: Visibility(
                visible: animateToppings,
                child: FlareActor(
                  "flare_assets/Toppings.flr",
                  animation: _animation,
                  fit: BoxFit.cover,
                )))
      ]),
      Visibility(
          visible: canInteract,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                RaisedButton(
                    child: Text("${d.current ?? drinkOrder['drinkType']}"),
                    onPressed: () {
                      update(d, drinkType, "drinkType");
                    }),
                RaisedButton(
                    child: Text(
                        "Drink Size:\n${s.current ?? drinkOrder['size']}",
                        textAlign: TextAlign.center),
                    onPressed: () {
                      update(s, size.keys, "size");
                    }),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Checkbox(
                          value: animateToppings,
                          onChanged: (bool changedValue) {
                            if (changedValue) {
                              setState(() {
                                animateToppings = changedValue;
                                _animation = "Appear";
                                drinkOrder.update("addons", (data) => "Boba");
                              });
                            } else {
                              setState(() {
                                animateToppings = changedValue;
                                _animation = "Disappear";
                                drinkOrder.update("addons", (data) => "None");
                              });
                            }
                          }),
                      Text("Boba?",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.w700))
                    ]),
                RaisedButton(
                    child: Text("Flavor:\n${f.current ?? 'No flavor chosen'}",
                        textAlign: TextAlign.center),
                    onPressed: () {
                      update(f, flavor.keys, "flavor");
                    })
              ]))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
            Expanded(child: orderStatus(context)),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              RaisedButton(
                  child: Text("$editingState"),
                  onPressed: () {
                    setState(() {
                      canInteract = canInteract ? false : true;
                      editingState = canInteract ? "Finish" : "Customize";
                    });
                  })
            ])
          ])),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add_shopping_cart),
          onPressed: () {
            setState(() {
              cart.add(drinkOrder);
            });
          }),
      persistentFooterButtons: <Widget>[
        FlatButton(
            child: Row(children: <Widget>[
              Icon(Icons.arrow_drop_up),
              Text("${cart.length}")
            ]),
            onPressed: () => showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return ListView.builder(
                      itemCount: cart.length,
                      itemBuilder: (context, int index) {
                        int i = index + 1;
                        return Text(
                          "$i ${cart[i - 1].values}",
                          textAlign: TextAlign.center,
                        );
                      });
                }))
      ],
    );
  }
}
