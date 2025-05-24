import 'package:flutter/material.dart';
import 'package:flutterproject/main.dart';
import 'package:flutterproject/services/AuthService.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("OneHand"),
        backgroundColor: Colors.lightBlue,
        actions: [
          // Add the plus icon to the AppBar's actions
          IconButton(
            icon: Icon(Icons.add), // Plus icon
            onPressed: () async {
              // Define the action when the plus icon is clicked
              await AuthService().logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AuthCheck()),
              );
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => Campaign()),
              // ),
              // You can navigate, show a dialog, etc.
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Password TextField
            TextField(
              decoration: InputDecoration(
                hintText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Category Section
            const Text(
              "Category",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Search Row or TextField in Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(10, (index) {
                  return Container(
                    width: 140,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Center(child: Text('Card $index')),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
