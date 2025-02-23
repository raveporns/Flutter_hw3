import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProductCreatePage extends StatefulWidget {
  const ProductCreatePage({super.key});

  @override
  State<ProductCreatePage> createState() => _ProductCreatePageState();
}

class _ProductCreatePageState extends State<ProductCreatePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isProcessing = false;

  Future<void> createProduct() async {
    if (!_formKey.currentState!.validate()) {
      return; // Stop if form is invalid
    }

    setState(() => isProcessing = true);
    try {
      var response = await http.post(
        Uri.parse("http://10.0.2.2:8001/products"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": nameController.text,
          "description": descriptionController.text,
          "price": double.tryParse(priceController.text) ?? 0.0,
        }),
      );

      if (response.statusCode == 201) {
        Navigator.pop(context, true);
        showSnackbar("Product created successfully!", Colors.green);
      } else {
        throw Exception("Failed to create product");
      }
    } catch (e) {
      showSnackbar("Error: Failed to create product", Colors.red);
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
        title: const Text('Create Product'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              buildLabel('Product :'),
              buildTextField(nameController, 'Product Name', validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Product name is required';
                }
                return null;
              }),
              const SizedBox(height: 20),
              buildLabel('Description :'),
              buildTextField(descriptionController, 'Description', validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Description is required';
                }
                return null;
              }),
              const SizedBox(height: 20),
              buildLabel('Price :'),
              buildTextField(priceController, 'Price', keyboardType: TextInputType.number, validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Price is required';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid price';
                }
                return null;
              }),
              const SizedBox(height: 30),
              isProcessing
                  ? const Center(child: CircularProgressIndicator())
                  : buildCreateButton(),
            ],
          ),
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
      {TextInputType keyboardType = TextInputType.text, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.never,
      ),
      validator: validator,
    );
  }

  Widget buildCreateButton() {
    return ElevatedButton.icon(
      onPressed: createProduct,
      icon: const Icon(Icons.add, color: Colors.white, size: 20),
      label: const Text("Create Product", style: TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.indigo, // Changed to Navy Blue
        fixedSize: const Size(200, 40),
      ),
    );
  }
}
