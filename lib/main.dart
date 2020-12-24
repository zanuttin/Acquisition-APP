import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert' as convert;
import "package:http/http.dart" as http;

void main() {
  runApp(MyApp());
}

class FeedbackForm {
  String title;
  String value;
  String category;
  String member;
  String payment;

  FeedbackForm(this.title, this.value, this.category, this.member, this.payment);

  factory FeedbackForm.fromJson(dynamic json) {
    return FeedbackForm("${json['title']}", "${json['value']}",
        "${json['category']}", "${json['member']}", "${json['payment']}");
  }

  // Method to make GET parameters.
  Map toJson() => {
    'title': title,
    'value': value,
    'category': category,
    'member': member,
    'payment': payment
  };
}

class FormController {

  // Google App Script Web URL.
  static const String URL = "https://script.google.com/macros/s/AKfycbwEQ8yJ62oCarsrAEB3NRdp2usieK7l_VwWNrdxDIuUZi-8ck88/exec";

  // Success Status Message
  static const STATUS_SUCCESS = "SUCCESS";

  /// Async function which saves feedback, parses [feedbackForm] parameters
  /// and sends HTTP GET request on [URL]. On successful response, [callback] is called.
  void submitForm(
      FeedbackForm feedbackForm, void Function(String) callback) async {
    try {
      await http.post(URL, body: feedbackForm.toJson()).then((response) async {
        if (response.statusCode == 302) {
          var url = response.headers['location'];
          await http.get(url).then((response) {
            callback(convert.jsonDecode(response.body)['status']);
          });
        } else {
          callback(convert.jsonDecode(response.body)['status']);
        }
      });
    } catch (e) {
      print(e);
    }
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(title: 'Contas 7 Eh Poko'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class MemberDropdown extends StatefulWidget {
  MemberDropdown({Key key, @required this.onSonChanged}) : super(key: key);
  final StringCallback onSonChanged;

  @override
  MemberDropdownState createState() => MemberDropdownState( onSonChanged: this.onSonChanged);
}

typedef void StringCallback(String str);
typedef void IntCallback(int val);

class MemberDropdownState extends State<MemberDropdown> {
  String member;
  final StringCallback onSonChanged;

  MemberDropdownState({@required this.onSonChanged}) {
    _readMember();
  }

  _readMember() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      member = (prefs.getString('member') ?? "Mini");
      onSonChanged(member);
    });
  }

  @override
  Widget build(BuildContext context) {

    return DropdownButton<String>(
      isExpanded: true,
      value: member,
      icon: Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      //style: TextStyle(color: Colors.green),
      underline: Container(
        height: 1,
        color: Colors.grey,
      ),
      onChanged: (String newValue) async {
        setState(() {
          member = newValue;
        });
        onSonChanged(member);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('member', member);
      },
      items: <String>['Mini', 'Fuga', 'Renner', 'Borel', 'Galego', 'Gui', 'Sub', 'Vó', 'Firmino']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}

class CategoryDropdown extends StatefulWidget {
  CategoryDropdown({Key key, @required this.onSonChanged}) : super(key: key);
  StringCallback onSonChanged;

  @override
  CategoryDropdownState createState() => CategoryDropdownState( onSonChanged: this.onSonChanged );
}

class CategoryDropdownState extends State<CategoryDropdown> {
  String dropdownValue = 'Mercado';
  StringCallback onSonChanged;

  CategoryDropdownState({@required this.onSonChanged}) {
    onSonChanged(dropdownValue);
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      isExpanded: true,
      icon: Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      //style: TextStyle(color: Colors.green),
      underline: Container(
        height: 1,
        color: Colors.grey,
      ),
      onChanged: (String newValue) {
        setState(() {
          dropdownValue = newValue;
          onSonChanged(dropdownValue);
        });
      },
      items: <String>['Mercado', 'Gás', 'Pets']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}

class PaymentRadio extends StatefulWidget {
  PaymentRadio({Key key, @required this.onSonChanged}) : super(key:key);
  IntCallback onSonChanged;

  @override
  PaymentRadioState createState() => PaymentRadioState( onSonChanged: this.onSonChanged);
}

class PaymentRadioState extends State<PaymentRadio> {
  IntCallback onSonChanged;
  int _radioValue = 0;

  PaymentRadioState({@required this.onSonChanged}){
    _radioValue = 0;
    onSonChanged(_radioValue);
  }

  void _handleRadioValueChange(int value) {
    setState(() {
      _radioValue = value;
    });
    onSonChanged(_radioValue);
  }

  @override
  Widget build(BuildContext context){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Radio(
          value: 0,
          groupValue: _radioValue,
          onChanged: _handleRadioValueChange,
        ),
        Text('Cartão da Rep', style: new TextStyle(fontSize: 16.0),),
        Radio(
          value: 1,
          groupValue: _radioValue,
          onChanged: _handleRadioValueChange,
        ),
        Text('Minha Grana', style: new TextStyle(fontSize: 16.0,),)
    ]);
  }
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  MoneyMaskedTextController valueController = MoneyMaskedTextController(decimalSeparator: ',', thousandSeparator: '.', leftSymbol: 'R\$');

  String emptyStringValidator(value) {
    if (value.isEmpty) {
      return "Escreva alguma coisa aqui!";
    }
    return null;
  }

  void sendData() {
    FeedbackForm feedbackForm = FeedbackForm(titleController.text, valueController.text, category, member, payment);
    FormController formController = FormController();
    String dialogTitle;
    formController.submitForm(feedbackForm, (String response) {
      print(response);
      if(response == FormController.STATUS_SUCCESS){
      } else {
      }
    });
  }

  String title, value, category, member, payment;

  void updateMember(String newMember){
    this.member = newMember;
  }

  void updateCategory(String newCategory){
    this.category = newCategory;
  }

  void updatePayment(int newPayment){
    if(newPayment == 0)
      this.payment = "Cartão da Rep";
    else
      this.payment = "Minha Grana";
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Form(
                key: _formKey,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.fromLTRB(0, 10, 0, 10), 
                            child: TextFormField(
                              decoration: InputDecoration(labelText: "Nome da transação",),
                              validator: emptyStringValidator,
                              controller: titleController,
                          )
                        ),
                        Padding(
                            padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                            child: TextFormField(
                              textAlign: TextAlign.right,
                              decoration: InputDecoration(labelText: "Valor da transação"),
                              controller: valueController,
                            )
                        ),
                        Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 10), child: CategoryDropdown(onSonChanged: updateCategory)),
                        Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 10), child: MemberDropdown(onSonChanged: updateMember)),
                        Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 10), child: PaymentRadio(onSonChanged: updatePayment,)),
                      ]),
                ))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: sendData,
        tooltip: 'Increment',
        child: Icon(Icons.upload_rounded),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
