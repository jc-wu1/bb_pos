import 'dart:math';

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

import 'features/receipt/receipt.dart';

class JcsPosApp extends StatelessWidget {
  const JcsPosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JCS POS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Isar? isar;

  @override
  void initState() {
    super.initState();

    isar = Isar.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("widget.title"),
      ),
      body: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 600,
              child: FutureBuilder(
                future: isar!.products.where().limit(10).findAll(),
                builder: (context, asyncSnapshot) {
                  if (asyncSnapshot.hasData) {
                    if (asyncSnapshot.data != null &&
                        asyncSnapshot.data!.isEmpty) {
                      return const Center(child: Text("Product is Empty"));
                    }
                    return ListView.builder(
                      itemCount: asyncSnapshot.data?.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Text(
                            asyncSnapshot.data?[index].productName ?? "-",
                          ),
                          subtitle: Text(
                            "${asyncSnapshot.data?[index].productPrice ?? "-"}",
                          ),
                          trailing: IconButton(
                            onPressed: () async {
                              final receipt1 = await isar!.receipts
                                  .where()
                                  .filter()
                                  .txnIdEqualTo("Receipt1")
                                  .findFirst();

                              print(receipt1!.products);

                              receipt1.products.add(asyncSnapshot.data![index]);

                              await isar!.writeTxn(() async {
                                await receipt1.products.save();
                              });

                              setState(() {});
                            },
                            icon: const Icon(Icons.add),
                          ),
                        );
                      },
                    );
                  }
                  return const Center(child: Text("Error"));
                },
              ),
            ),
          ),
          Expanded(
            child: SizedBox(
              height: 600,
              child: FutureBuilder(
                future: isar!.receipts
                    .where()
                    .filter()
                    .txnIdEqualTo("Receipt1")
                    .findFirst(),
                builder: (context, asyncSnapshot) {
                  if (asyncSnapshot.hasData) {
                    if (asyncSnapshot.data != null) {
                      if (asyncSnapshot.data?.products != null) {
                        return ListView.builder(
                          itemCount: asyncSnapshot.data!.products.length,
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                              title: Text(
                                asyncSnapshot.data!.products
                                        .elementAt(index)
                                        .productName ??
                                    "-",
                              ),
                              subtitle: Text(
                                "${asyncSnapshot.data!.products.elementAt(index).productPrice ?? "-"}",
                              ),
                              trailing: Text(
                                "${asyncSnapshot.data!.products.elementAt(index).qty ?? "-"}",
                              ),
                            );
                          },
                        );
                      } else {
                        return const Center(child: Text("Receipt Empty"));
                      }
                    }
                  }
                  return const Center(child: Text("Error"));
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            ElevatedButton(
              onPressed: () async {
                await isar!.writeTxn(() async {
                  for (var i = 0; i < 10; i++) {
                    final product = Product(
                      itemId: "product$i",
                      productName: "Product Number #$i",
                      productPrice: Random.secure().nextDouble() * 100,
                      createdAt: DateTime.now(),
                    );
                    await isar!.products.put(product);
                  }
                });

                setState(() {});
              },
              child: const Text("Add Products"),
            ),
            ElevatedButton(
              onPressed: () async {
                await isar!.writeTxn(() async {
                  final Receipt receipt = Receipt(
                    txnId: "Receipt1",
                    createdAt: DateTime.now(),
                  );
                  await isar!.receipts.put(receipt);
                });

                setState(() {});
              },
              child: const Text("Add Receipts"),
            ),
          ],
        ),
      ),
    );
  }
}
