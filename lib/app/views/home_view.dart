import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:lights_on_height_ecommerce_app/app/controllers/store_controller.dart';
import 'package:lights_on_height_ecommerce_app/app/models/products_model.dart';
import 'package:shimmer/shimmer.dart';
import 'package:lights_on_height_ecommerce_app/app/views/product_view.dart';
import 'package:lights_on_height_ecommerce_app/app/views/search_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final dio = Dio();
  final StoreController _controller = StoreController();
  final ScrollController categoriesScrollController = ScrollController();

  bool isLoadingCategories = false, isLoadingProducts = false;
  String _selectedCategory = "ALL";

  final String _appBarTitle = "Hello Seun",
      _appBarSubTitle = "Welcome back to the store...";

  List<dynamic> _categoriesResponseList = [];
  List<dynamic> get categoriesResponseList => _categoriesResponseList;

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

  updateIsLoadingCategories(bool value) {
    setState(() {
      isLoadingCategories = value;
    });
  }

  updateIsLoadingProducts(bool value) {
    setState(() {
      isLoadingProducts = value;
    });
  }

  void getAllCategories() async {
    updateIsLoadingCategories(true);
    try {
      Response response;
      response = await dio.get("${_controller.baseUrl}/products/categories");
      if (response.statusCode == 200) {
        final List<dynamic> responseList = response.data;
        _categoriesResponseList = responseList;
        _categoriesResponseList.insert(0, "All");
      } else {}
      setState(() {});
      updateIsLoadingCategories(false);
    } on DioException catch (e) {
      var errorMessage = _controller.handleError(e);
      BotToast.showText(text: errorMessage);
      updateIsLoadingCategories(false);
    }
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

  void getCategoryProducts() {
    getAllProducts(selectedCategory: _selectedCategory);
  }

  // initstate
  @override
  void initState() {
    getAllCategories();
    getAllProducts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          isLoadingCategories
              ? SizedBox(
                  height: 54,
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                    ),
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6.0,
                          horizontal: 4.0,
                        ),
                        child: Shimmer.fromColors(
                            baseColor: Colors.grey.withOpacity(.1),
                            highlightColor: Colors.white60,
                            child: Container(
                              height: 50,
                              width: 100,
                              margin: const EdgeInsets.only(top: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(.7),
                                borderRadius: BorderRadius.circular(24),
                              ),
                            )),
                      );
                    },
                  ),
                )
              : SizedBox(
                  height: 54,
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    controller: categoriesScrollController,
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                    ),
                    itemCount: categoriesResponseList.length,
                    itemBuilder: (context, index) {
                      String category = categoriesResponseList[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6.0,
                          horizontal: 4.0,
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () {
                            setState(() {
                              _selectedCategory =
                                  category.toString().toUpperCase();
                            });

                            getCategoryProducts();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12.0,
                              horizontal: 18.0,
                            ),
                            decoration: BoxDecoration(
                              color: _selectedCategory ==
                                      category.toString().toUpperCase()
                                  ? Colors.green
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.green,
                              ),
                            ),
                            child: Text(
                              category.toString().toUpperCase(),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _selectedCategory ==
                                        category.toString().toUpperCase()
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
          // _buildPageTitle(),
          isLoadingProducts
              ? Expanded(
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: 4,
                    padding: const EdgeInsets.only(
                      bottom: 10.0,
                      left: 18.0,
                      right: 18.0,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 40 / 48,
                    ),
                    itemBuilder: (context, index) {
                      return Shimmer.fromColors(
                          baseColor: Colors.grey.withOpacity(.1),
                          highlightColor: Colors.white60,
                          child: Container(
                            height: 50,
                            width: 100,
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(.7),
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ));
                    },
                  ),
                )
              : Expanded(
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: productsResponseList.length,
                    padding: const EdgeInsets.only(
                        bottom: 10.0, left: 18.0, right: 18.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 40 / 48,
                    ),
                    itemBuilder: (context, index) {
                      ProductsModel product = productsResponseList[index];
                      return InkWell(
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14.0,
                            vertical: 6.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                child: Image.network(product.image),
                              ),
                              Text(
                                product.title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.start,
                              ),
                              Text(
                                product.price.toString(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.start,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: .8,
      backgroundColor: Colors.white,
      // foregroundColor: Colors.white,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _appBarTitle,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 1.25,
            ),
          ),
          Text(
            _appBarSubTitle,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(50.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SearchView(),
                    ),
                  ),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14.0,
                      vertical: 6.0,
                    ),
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Icon(Icons.search),
                        const SizedBox(width: 8),
                        Text(
                          "Search here...",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: Colors.grey.shade700,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
