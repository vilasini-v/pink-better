import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class HairfallTile extends StatelessWidget{
  final String note;
  final String amount;
  final DateTime dateTime;
  void Function(BuildContext) ? deleteTapped;

  HairfallTile({
    super.key,
    required this.note,
    required this.amount,
    required this.dateTime,
    required this.deleteTapped,

  });
  @override
  Widget build(BuildContext context){
    return Slidable(
      endActionPane: ActionPane(
        motion: const StretchMotion(), 
        children: [
          SlidableAction(onPressed: deleteTapped, icon: Icons.delete, backgroundColor: Colors.redAccent,)
          ]
      ),
     child: ListTile( tileColor: Colors.blueGrey[100],
      title: Text(amount),
      subtitle: Text(note),
      trailing: Text('${dateTime.day}-${dateTime.month}-${dateTime.year}'),
      ),
    );
  }
}