import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProductEditPage extends StatefulWidget {
  final String productId;

  const ProductEditPage({super.key, required this.productId});

  @override
  State<ProductEditPage> createState() => _ProductEditPageState();
}

class _ProductEditPageState extends State<ProductEditPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  bool isLoading = true;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    loadProduct();
  }

  Future<void> loadProduct() async {
    try {
      var response = await http.get(
        Uri.parse("http://10.0.2.2:8001/products/${widget.productId}"),
      );

      if (response.statusCode == 200) {
        var productData = jsonDecode(response.body);
        setState(() {
          nameController.text = productData["name"];
          descriptionController.text = productData["description"];
          priceController.text = productData["price"].toString();
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load product");
      }
    } catch (e) {
      showSnackbar("Error: Failed to load product", Colors.red);
    }
  }

  Future<void> updateProduct() async {
    setState(() => isProcessing = true);
    try {
      var response = await http.put(
        Uri.parse("http://10.0.2.2:8001/products/${widget.productId}"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": nameController.text,
          "description": descriptionController.text,
          "price": double.tryParse(priceController.text) ?? 0.0,
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context, true);
        showSnackbar("Update Success!", Colors.green);
      } else {
        throw Exception("Failed to update product");
      }
    } catch (e) {
      showSnackbar("Error: Failed to update product", Colors.red);
    } finally {
      setState(() => isProcessing = false);
    }
  }

  Future<void> deleteProduct() async {
    setState(() => isProcessing = true);
    try {
      var response = await http.delete(
        Uri.parse("http://10.0.2.2:8001/products/${widget.productId}"),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context, true);
        showSnackbar("Delete Success!", Colors.red);
      } else {
        throw Exception("Failed to delete product");
      }
    } catch (e) {
      showSnackbar("Error: Failed to delete product", Colors.red);
    } finally {
      setState(() => isProcessing = false);
    }
  }

  void showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit/Delete Product'),
        backgroundColor: Colors.indigo,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  buildLabel('Product :'),
                  buildTextField(nameController, 'Product Name'),
                  const SizedBox(height: 20),
                  buildLabel('Description :'),
                  buildTextField(descriptionController, 'Description'),
                  const SizedBox(height: 20),
                  buildLabel('Price :'),
                  buildTextField(priceController, 'Price',
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 30),
                  isProcessing
                      ? const Center(child: CircularProgressIndicator())
                      : buildActionButtons(),
                ],
              ),
            ),
    );
  }

  Widget buildLabel(String text) {
    return Container(
      alignment: Alignment.topLeft,
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.never,
      ),
    );
  }

  Widget buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: updateProduct,
          icon: const Icon(Icons.upgrade, color: Colors.white, size: 20),
          label: const Text("Update", style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            fixedSize: const Size(130, 40),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => showDeleteConfirmation(),
          icon: const Icon(Icons.delete, color: Colors.white, size: 20),
          label: const Text("Delete", style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            fixedSize: const Size(130, 40),
          ),
        ),
      ],
    );
  }

  void showDeleteConfirmation() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text(
          'Confirm Deletion',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
        ),
        content: const Text('Are you sure you want to delete this product?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await deleteProduct();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
