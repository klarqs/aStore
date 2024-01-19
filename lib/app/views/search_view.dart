import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:lights_on_height_ecommerce_app/app/controllers/store_controller.dart';
import 'package:lights_on_height_ecommerce_app/app/models/products_model.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController searchTextController = TextEditingController();
  final dio = Dio();
  final StoreController _controller = StoreController();
  final ScrollController categoriesScrollController = ScrollController();

  bool isLoadingProducts = false;

  List<ProductsModel> _productsResponseList = [];
  List<ProductsModel> get productsResponseList => _productsResponseList;

  void animateTo() {
    setState(() {
      categoriesScrollController.animateTo(
          categoriesScrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.ease);
    });
  }

  updateIsLoadingProducts(bool value) {
    setState(() {
      isLoadingProducts = value;
    });
  }

  void getAllProducts({selectedCategory = "ALL"}) async {
    updateIsLoadingProducts(true);
    try {
      Response response;
      response = await dio.get(selectedCategory == "ALL"
          ? "${_controller.baseUrl}/products"
          : "${_controller.baseUrl}/products/category/${selectedCategory.toString().toLowerCase()}");
      if (response.statusCode == 200) {
        final List responseList = response.data;
        _productsResponseList =
            responseList.map((e) => ProductsModel.fromJson(e)).toList();
        responseList;
      } else {}
      setState(() {});
      updateIsLoadingProducts(false);
    } on DioException catch (e) {
      var errorMessage = _controller.handleError(e);
      BotToast.showText(text: errorMessage);
      updateIsLoadingProducts(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: _buildAppBar(),
        body: const SizedBox());
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: .8,
      backgroundColor: Colors.white,
      // leadingWidth: 44,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      title: TextField(
        textCapitalization: TextCapitalization.words,
        cursorColor: const Color(0xff1D1D1B),
        cursorWidth: 2,
        controller: searchTextController,
        autofocus: true,
        onChanged: (_) {},
        style: const TextStyle(
          fontSize: 16,
          height: 1.4,
          letterSpacing: -.1,
          color: Color(0xff1D1D1B),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          floatingLabelBehavior: FloatingLabelBehavior.always,
          hintText: "Search",
          fillColor: const Color(0xff1D1D1B).withOpacity(.04),
          filled: true,
          counterStyle: const TextStyle(
            fontSize: 0,
          ),
          labelStyle: const TextStyle(
            fontSize: 16,
            letterSpacing: -.1,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: const TextStyle(
            fontSize: 16,
            letterSpacing: -.1,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 18,
          ),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(
              right: 12.0,
              left: 12.0,
            ),
            child: Icon(Icons.search),
          ),
        ),
      ),
    );
  }
}
