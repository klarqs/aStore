import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:lights_on_height_ecommerce_app/app/controllers/store_controller.dart';
import 'package:lights_on_height_ecommerce_app/app/models/products_model.dart';
import 'package:lights_on_height_ecommerce_app/app/views/product_view.dart';
import 'package:shimmer/shimmer.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _searchTextController = TextEditingController();
  final dio = Dio();
  final StoreController _controller = StoreController();
  final ScrollController categoriesScrollController = ScrollController();

  bool isLoadingProducts = false;

  List<ProductsModel> searchProductsResultList = [];
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

  onSearchTextChanged(String text) async {
    searchProductsResultList.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    for (int i = 0; i < _productsResponseList.length; i++) {
      if (_productsResponseList[i].title.contains(text)) {
        searchProductsResultList.add(_productsResponseList[i]);
      }
    }

    setState(() {});
  }

  // initstate
  @override
  void initState() {
    getAllProducts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: _buildAppBar(),
      body: isLoadingProducts
          ? Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: 8,
                padding: const EdgeInsets.only(
                  bottom: 10.0,
                  left: 18.0,
                  right: 18.0,
                  top: 12.0,
                ),
                itemBuilder: (context, index) {
                  return Shimmer.fromColors(
                    baseColor: Colors.grey.withOpacity(.1),
                    highlightColor: Colors.white60,
                    child: Container(
                      height: 76,
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(.7),
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  );
                },
              ),
            )
          : searchProductsResultList.isEmpty &&
                  _searchTextController.text.isNotEmpty
              ? const Center(
                  child: Text(
                    "No Product Found",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.normal,
                      height: 1.25,
                    ),
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: searchProductsResultList.isEmpty
                      ? productsResponseList.length
                      : searchProductsResultList.length,
                  padding: const EdgeInsets.only(
                    bottom: 10.0,
                    left: 18.0,
                    right: 18.0,
                    top: 12.0,
                  ),
                  itemBuilder: (context, index) {
                    ProductsModel product = searchProductsResultList.isEmpty
                        ? productsResponseList[index]
                        : searchProductsResultList[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductView(
                              productDetails: product,
                            ),
                          ),
                        ),
                        child: Container(
                          height: 76,
                          padding: const EdgeInsets.only(
                            left: 6.0,
                            right: 12.0,
                            top: 6.0,
                            bottom: 6.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 72,
                                width: 72,
                                child: Image.network(product.image),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  product.title,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                product.price.toString(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.start,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
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
        controller: _searchTextController,
        autofocus: true,
        onChanged: (_) {
          onSearchTextChanged(_searchTextController.text);
        },
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
