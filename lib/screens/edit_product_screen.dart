import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = "edit-product";
  const EditProductScreen({super.key});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  var _isInit = true;
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
  var _initValues = {
    "title": "",
    "description": "",
    "imageUrl": "",
    "price": "",
  };
  var _isLoading = false;

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if (_imageUrlController.text.isEmpty ||
          (!_imageUrlController.text.startsWith("http") &&
              !_imageUrlController.text.startsWith("https")) ||
          (!_imageUrlController.text.endsWith("jpg") &&
              !_imageUrlController.text.endsWith("png") &&
              !_imageUrlController.text.endsWith("jpeg"))) return;
      setState(() {});
    }
  }

  void _saveForm() {
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    }
    _form.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedProduct.id != "") {
      Provider.of<Products>(context, listen: false).updateProduct(
        _editedProduct.id,
        _editedProduct,
      );
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
    } else {
      Provider.of<Products>(context, listen: false)
          .addProduct(_editedProduct)
          .then((_) {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();
      });
    }
  }

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context)!.settings.arguments;
      if (productId != null) {
        _editedProduct = Provider.of<Products>(
          context,
          listen: false,
        ).findById(productId as String);
        _initValues = {
          "title": _editedProduct.title,
          "description": _editedProduct.description,
          "price": _editedProduct.price.toString(),
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _initValues["title"],
                      decoration: const InputDecoration(
                        labelText: "Title",
                      ),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        return FocusScope.of(context)
                            .requestFocus(_priceFocusNode);
                      },
                      onSaved: (newValue) => _editedProduct = Product(
                        title: newValue!,
                        price: _editedProduct.price,
                        description: _editedProduct.description,
                        id: _editedProduct.id,
                        imageUrl: _editedProduct.imageUrl,
                        isFavorite: _editedProduct.isFavorite,
                      ),
                      validator: (value) {
                        if (value!.isEmpty) return "Please, provide a value.";
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues["price"],
                      decoration: const InputDecoration(
                        labelText: "Price",
                      ),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descritpionFocusNode);
                      },
                      onSaved: (newValue) => _editedProduct = Product(
                        title: _editedProduct.title,
                        price: double.parse(newValue!),
                        description: _editedProduct.description,
                        id: _editedProduct.id,
                        imageUrl: _editedProduct.imageUrl,
                        isFavorite: _editedProduct.isFavorite,
                      ),
                      validator: (value) {
                        if (value!.isEmpty) return "Please, enter a price.";
                        if (double.tryParse(value) == null) {
                          return "Please, enter a valid number.";
                        }
                        if (double.parse(value) <= 0) {
                          return "Please, enter a number greater than 0";
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues["description"],
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
                        isFavorite: _editedProduct.isFavorite,
                      ),
                      validator: (value) {
                        if (value!.isEmpty)
                          return "Please, enter a description.";
                        return null;
                      },
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
                              isFavorite: _editedProduct.isFavorite,
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Please, enter an image URL.";
                              }
                              if (!value.startsWith("http") &&
                                  !value.startsWith("https")) {
                                return "Please, enter a valid URL.";
                              }
                              if (!value.endsWith("jpg") &&
                                  !value.endsWith("png") &&
                                  !value.endsWith("jpeg")) {
                                return "Please, enter a valid image URL.";
                              }
                              return null;
                            },
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
