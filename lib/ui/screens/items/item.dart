import 'package:flutter/material.dart';
import 'package:kasir/data/models/item.dart';

class Item extends StatefulWidget {
  const Item({Key? key}) : super(key: key);

  @override
  State<Item> createState() => _ItemState();
}

class _ItemState extends State<Item> {
  TextEditingController kodeController = TextEditingController();
  TextEditingController namaController = TextEditingController();
  TextEditingController hargaController = TextEditingController();
  TextEditingController stokController = TextEditingController();

  bool isLoading = false;
  List<ItemService> items = [];

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async {
    setState(() {
      isLoading = true;
    });
    final data = List<ItemService>.from(await ItemService.fetchItems());
    setState(() {
      items = data;
      isLoading = false;
    });
  }

  Future<void> addItems(data) async {
    final statusCode = await ItemService.addItems(data);

    if (statusCode == 200) {
      await fetchItems();
    } else {
      throw Exception('Failed to create items');
    }
  }

  Future<void> editItems(nobarcode, data) async {
    final statusCode = await ItemService.editItems(nobarcode, data);
    if (statusCode == 200) {
      fetchItems();
    } else {
      throw Exception('Failed to update items');
    }
  }

  Future<void> deleteItems(nobarcode) async {
    final statusCode = await ItemService.deleteItems(nobarcode);

    if (statusCode == 200) {
      fetchItems();
    } else {
      throw Exception('Failed to delete items');
    }
  }

  void _showEditModal(BuildContext context, int index) {
    kodeController.text = index == -1 ? '' : items[index].nobarcode.toString();
    namaController.text = index == -1 ? '' : items[index].nama;
    hargaController.text = index == -1 ? '' : items[index].harga.toString();
    stokController.text = index == -1 ? '' : items[index].stok.toString();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(index == -1 ? 'Tambah Barang' : 'Edit Barang'),
          content: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // TextFormField(
                //   controller: kodeController,
                //   decoration: const InputDecoration(labelText: 'Kode'),
                // ),
                TextFormField(
                  controller: namaController,
                  decoration: const InputDecoration(labelText: 'Nama'),
                ),
                TextFormField(
                  controller: hargaController,
                  decoration: const InputDecoration(labelText: 'Harga'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: stokController,
                  decoration: const InputDecoration(labelText: 'Stok'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                // Get values from controllers
                String kode = kodeController.text;
                String nama = namaController.text;
                double? harga = double.tryParse(hargaController.text);
                int? stok = int.tryParse(stokController.text);

                if (!nama.isNotEmpty && harga == null && stok == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Semua kolom harus diisi dan valid')),
                  );
                } else {
                  Navigator.pop(context);
                  if (index == -1) {
                    addItems({
                      "nobarcode": kode,
                      "nama": nama,
                      "harga": harga,
                      "stok": stok,
                    });
                  } else {
                    editItems(kode, {
                      "nama": nama,
                      "harga": harga,
                      "stok": stok,
                    });
                  }
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, nobarcode) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text('Apakah Anda yakin ingin menghapus item ini?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); 
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                deleteItems(nobarcode);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text('Daftar Barang'),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? const Center(
                  child: Text("Belum ada produk"),
                )
              : ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${items[index].nama} (${items[index].nobarcode})',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  'Harga : ${items[index].harga}',
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w300),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () {
                                    _showEditModal(context, index);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    _showDeleteConfirmationDialog(
                                        context, items[index].nobarcode);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showEditModal(context, -1);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
