import 'package:flutter/material.dart';

import '../providers/product.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = "edit-product";
  const EditProductScreen({super.key});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descritpionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _form = GlobalKey<FormState>();
  var _editedProduct = Product(
    id: "",
    title: "",
    description: "",
    imageUrl: "",
    price: 0,
  );

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  void _saveForm() {
    _form.currentState!.save();
    print(_editedProduct.title);
    print(_editedProduct.price);
    print(_editedProduct.description);
    print(_editedProduct.imageUrl);
  }

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descritpionFocusNode.dispose();
    _imageUrlFocusNode.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit product"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _form,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Title",
                ),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_priceFocusNode),
                onSaved: (newValue) => _editedProduct = Product(
                  title: newValue!,
                  price: _editedProduct.price,
                  description: _editedProduct.description,
                  id: _editedProduct.id,
                  imageUrl: _editedProduct.imageUrl,
                ),
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Price",
                ),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                focusNode: _priceFocusNode,
                onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_descritpionFocusNode),
                onSaved: (newValue) => _editedProduct = Product(
                  title: _editedProduct.title,
                  price: double.parse(newValue!),
                  description: _editedProduct.description,
                  id: _editedProduct.id,
                  imageUrl: _editedProduct.imageUrl,
                ),
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Description",
                ),
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                focusNode: _descritpionFocusNode,
                onSaved: (newValue) => _editedProduct = Product(
                  title: _editedProduct.title,
                  price: _editedProduct.price,
                  description: newValue!,
                  id: _editedProduct.id,
                  imageUrl: _editedProduct.imageUrl,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.only(top: 8, right: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Colors.grey,
                      ),
                    ),
                    child: _imageUrlController.text.isEmpty
                        ? const Text("Enter a URL")
                        : FittedBox(
                            child: Image.network(
                              _imageUrlController.text,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        label: Text("Image URL"),
                      ),
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.done,
                      controller: _imageUrlController,
                      focusNode: _imageUrlFocusNode,
                      onFieldSubmitted: (_) => _saveForm(),
                      onSaved: (newValue) => _editedProduct = Product(
                        title: _editedProduct.title,
                        price: _editedProduct.price,
                        description: _editedProduct.description,
                        id: _editedProduct.id,
                        imageUrl: newValue!,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
