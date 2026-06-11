class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() =>
      _ProductScreenState();
}

class _ProductScreenState
    extends State<ProductScreen> {

  final ScrollController _controller =
      ScrollController();

  List products = [];

  int skip = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    fetchProducts();

    _controller.addListener(() {
      if (_controller.position.pixels ==
          _controller.position.maxScrollExtent) {
        fetchProducts();
      }
    });
  }

  Future<void> fetchProducts() async {
    if (isLoading) return;

    isLoading = true;

    final response = await http.get(
      Uri.parse(
        'https://dummyjson.com/products?limit=10&skip=$skip',
      ),
    );

    final data = jsonDecode(response.body);

    setState(() {
      products.addAll(data['products']);
      skip += 10;
    });

    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _controller,
      itemCount: products.length,
      itemBuilder: (_, index) {
        return ListTile(
          title: Text(products[index]['title']),
        );
      },
    );
  }
}
