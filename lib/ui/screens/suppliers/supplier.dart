import 'package:flutter/material.dart';
import 'package:kasir/data/models/supplier.dart';

class Supplier extends StatefulWidget {
  const Supplier({Key? key}) : super(key: key);

  @override
  State<Supplier> createState() => _SupplierState();
}

class _SupplierState extends State<Supplier> {
  TextEditingController idSupController = TextEditingController();
  TextEditingController namaController = TextEditingController();
  TextEditingController alamatController = TextEditingController();
  TextEditingController noHpController = TextEditingController();

  bool isLoading = false;
  List<SupplierService> suppliers = [];

  @override
  void initState() {
    super.initState();
    fetchSuppliers();
  }

  Future<void> fetchSuppliers() async {
    setState(() {
      isLoading = true;
    });
    final data =
        List<SupplierService>.from(await SupplierService.fetchSuppliers());

    setState(() {
      suppliers = data;
      isLoading = false;
    });
  }

  Future<void> addSuppliers(data) async {
    final statusCode = await SupplierService.addSuppliers(data);
    if (statusCode == 200) {
      await fetchSuppliers();
    } else {
      throw Exception('Failed to create supplier');
    }
  }

  Future<void> editSuppliers(idsup, data) async {
    final statusCode = await SupplierService.editSuppliers(idsup, data);
    if (statusCode == 200) {
      await fetchSuppliers();
    } else {
      throw Exception('Failed to create supplier');
    }
  }

  Future<void> deleteSuppliers(idsup) async {
    final statusCode = await SupplierService.deleteSuppliers(idsup);

    if (statusCode == 200) {
      fetchSuppliers();
    } else {
      throw Exception('Failed to delete suppliers');
    }
  }

  void _showEditModal(BuildContext context, int index) {
    idSupController.text = index == -1 ? '' : suppliers[index].idsup.toString();
    namaController.text = index == -1 ? '' : suppliers[index].nama;
    alamatController.text =
        index == -1 ? '' : suppliers[index].alamat.toString();
    noHpController.text = index == -1 ? '' : suppliers[index].nohp.toString();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(index == -1 ? 'Tambah Supplier' : 'Edit Supplier'),
          content: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // TextFormField(
                //   controller: idSupController,
                //   decoration: const InputDecoration(labelText: 'Kode'),
                // ),
                TextFormField(
                  controller: namaController,
                  decoration: const InputDecoration(labelText: 'Nama'),
                ),
                TextFormField(
                  controller: alamatController,
                  decoration: const InputDecoration(labelText: 'Alamat'),
                ),
                TextFormField(
                  controller: noHpController,
                  decoration: const InputDecoration(labelText: 'No Hp'),
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
                String idsup = idSupController.text;
                String nama = namaController.text;
                String alamat = alamatController.text;
                int? nohp = int.tryParse(noHpController.text);

                if (!nama.isNotEmpty && !alamat.isNotEmpty && nohp == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Semua kolom harus diisi dan valid')),
                  );
                } else {
                  Navigator.pop(context);
                  if (index == -1) {
                    addSuppliers({
                      "idsup": idsup,
                      "nama": nama,
                      "alamat": alamat,
                      "nohp": nohp,
                    });
                  } else {
                    editSuppliers(idsup, {
                      "nama": nama,
                      "alamat": alamat,
                      "nohp": nohp,
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

  void _showDeleteConfirmationDialog(BuildContext context, idsup) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content:
              const Text('Apakah Anda yakin ingin menghapus supplier ini?'),
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
                deleteSuppliers(idsup);
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
          child: Text('Daftar Supplier'),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : suppliers.isEmpty
              ? const Center(
                  child: Text("Belum ada supplier"),
                )
              : ListView.builder(
                  itemCount: suppliers.length,
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
                                  suppliers[index].nama,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  'Alamat : ${suppliers[index].alamat}',
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
                                        context, suppliers[index].idsup);
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
