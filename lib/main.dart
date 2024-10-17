import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('notepad');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Local Database-Hive',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Box? notepad;

  @override
  void initState() {
    super.initState();
    notepad = Hive.box("notepad");
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _updateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Local Database-Hive",
          style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.amber,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 50),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(hintText: "Name"),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _mobileNumberController,
              decoration: InputDecoration(hintText: 'Mobile Number'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(hintText: 'Address'),
            ),
            SizedBox(height: 30),
            SizedBox(
              width: 400,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    final name = _nameController.text;
                    final mobileNumber = _mobileNumberController.text;
                    final address = _addressController.text;
                    if (name.isNotEmpty &&
                        mobileNumber.isNotEmpty &&
                        address.isNotEmpty) {
                      await notepad!.add({
                        'name': name,
                        'mobileNumber': mobileNumber,
                        'address': address,
                      });
                      _nameController.clear();
                      _mobileNumberController.clear();
                      _addressController.clear();
                      Fluttertoast.showToast(msg: "Added successfully");
                    } else {
                      Fluttertoast.showToast(
                          msg: "Please fill in all the fields");
                    }
                  } catch (e) {
                    Fluttertoast.showToast(
                      msg: e.toString(),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Add new data",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 30),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: Hive.box('notepad').listenable(),
                builder: (context, box, widget) {
                  return ListView.builder(
                    itemCount: notepad!.length,
                    itemBuilder: (_, index) {
                      final data = notepad!.getAt(index) as Map;
                      return Card(
                        elevation: 5,
                        child: ListTile(
                          title: Text("Name:  ${data['name']}"),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Mobile:   ${data['mobileNumber']}"),
                              Text("Address: ${data['address']}"),
                            ],
                          ),
                          trailing: SizedBox(
                            width: 100,
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () async {
                                    showDialog(
                                      context: context,
                                      builder: (_) {
                                        return Dialog(
                                          child: Container(
                                            height: 200,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(20.0),
                                              child: Column(
                                                children: [
                                                  TextField(
                                                    controller:
                                                        _updateController,
                                                    decoration: InputDecoration(
                                                        hintText:
                                                            "Update value"),
                                                  ),
                                                  SizedBox(height: 30),
                                                  ElevatedButton(
                                                    onPressed: () async {
                                                      final updateData =
                                                          _updateController
                                                              .text;
                                                      notepad!.putAt(
                                                          index, updateData);
                                                      _updateController.clear();
                                                      Navigator.pop(context);
                                                      Fluttertoast.showToast(
                                                          msg:
                                                              "Updated successfully");
                                                    },
                                                    child: Text('Update'),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  icon: Icon(
                                    Icons.edit,
                                    color: Colors.green,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    await notepad!.deleteAt(index);
                                    Fluttertoast.showToast(
                                        msg: "Deleted successfully");
                                  },
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.amber,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
