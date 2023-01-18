class CategoriesItem {
  final int id;
  final String title;

  bool selected;

  CategoriesItem(
      {required this.id, required this.title, this.selected = false});
}
