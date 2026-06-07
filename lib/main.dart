import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dashboard',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  Widget statCard(
      String title,
      String value,
      IconData icon,
      BuildContext context,
      ) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon,size:40),
              const SizedBox(height:10),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }

  Widget roomCard(
      String room,
      String tenant,
      bool occupied,
      ) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text(room),
        ),
        title: Text("Kamar $room"),
        subtitle: Text(
          occupied
              ? "Dihuni $tenant"
              : "Kosong",
        ),
        trailing: Icon(
          occupied
              ? Icons.check_circle
              : Icons.cancel,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Property Dashboard V1.3 coba"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            Row(
              children: [
                statCard(
                  "Kamar",
                  "12",
                  Icons.home,
                  context,
                ),
                statCard(
                  "Penghuni",
                  "9",
                  Icons.people,
                  context,
                ),
              ],
            ),

            const SizedBox(height:16),

            Expanded(
              child: ListView(
                children: [
                  roomCard(
                    "A1",
                    "Budi",
                    true,
                  ),
                  roomCard(
                    "A2",
                    "",
                    false,
                  ),
                  roomCard(
                    "B1",
                    "Siti",
                    true,
                  ),
                  roomCard(
                    "B2",
                    "",
                    false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      floatingActionButton:
      FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}