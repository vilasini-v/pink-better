import 'package:flutter/material.dart';
import 'package:newpapp/components/hairfall_summary.dart';
import 'package:newpapp/components/hairfall_tile.dart';
import 'package:newpapp/data/hairfall_data.dart';
import 'package:newpapp/model/hair.dart';
import 'package:provider/provider.dart';
import '../data/firestore_db.dart';

class CounterPage extends StatefulWidget{
  const CounterPage({super.key});

  @override
  State<CounterPage> createState()=>_CounterPageState();

}

class _CounterPageState extends State<CounterPage>{
  final newHairCountContoller = TextEditingController();
  final newNote = TextEditingController();
  final FirestoreDb firestoreDb = FirestoreDb();
  @override
void initState() {
  super.initState();
  firestoreDb.cleanupOldLogs();
 Provider.of<HairfallData>(context, listen: false).prepareData();
}

  
  void count(){
    showDialog(context: context, builder: (context)=>AlertDialog(
      title: const Text("add new log"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
         Padding(
            padding: const EdgeInsets.all(2.0),
            child: TextField(
              controller: newNote,
              decoration: const InputDecoration(
                labelText: 'note',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: TextField(
              controller: newHairCountContoller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'amount',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          
        
      ],),
      actions: [
        MaterialButton(
          onPressed: save,
          child: const Text('save'),
        ),
        MaterialButton(onPressed: cancel, child: const Text('cancel'))
      ],
    ),);
  }

  void deleteLog(Hair item){
    Provider.of<HairfallData>(context, listen: false).deleteLog(item);
    clear();
  }

  void save() {
  if (newHairCountContoller.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please fill out all fields.')),
    );
    return;
  }

  Hair newLog = Hair(
    amount: newHairCountContoller.text,
    note: newNote.text,
    date: DateTime.now(),
  );
  Provider.of<HairfallData>(context, listen: false).addNewLog(newLog);
  Navigator.pop(context);
  clear();
}

  void cancel(){
    Navigator.pop(context);
    clear();
  }

  void clear(){
    newHairCountContoller.clear();
    newNote.clear();
  }
  @override
  Widget build(BuildContext context){
    return Consumer<HairfallData>(builder:(context, value, child) => Scaffold(
      appBar: AppBar(title: Text('Hair Fall counter'), backgroundColor: Colors.pink[100],),
      backgroundColor: Colors.grey[100],
      floatingActionButton: FloatingActionButton(
        onPressed: count,
        backgroundColor: Colors.pink[100],
        child: const Icon(Icons.add),
      ),
      body: ListView(
        children: [
          const SizedBox(
            height: 50,
          ),
          //weekly summary
        HairfallSummary(startOfWeek: value.startOfWeekDate()),          
          //all summary
          const SizedBox(
            height:30
          ),
          ListView.builder  (
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: value.getDailyLogs().length,
            itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 10.0, left: 10.0, right:10.0), // Add bottom space
            child: Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0), // Rounded corners
      ),
      elevation: 3, // Shadow depth
      child: HairfallTile(
        note: value.getDailyLogs()[index].note, 
        amount: value.getDailyLogs()[index].amount, 
        dateTime: value.getDailyLogs()[index].date,
        deleteTapped: (p0) =>
        deleteLog(value.getDailyLogs()[index]),
      ),
            ),
          ),
         )
        ],
      )
    ),
    );
  }
}