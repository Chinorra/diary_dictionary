import '../models/page_model.dart';

abstract class BookRepository {
  Future<List<PageModel>> getAll();
  Future<void> create(PageModel page);
  Future<void> update(PageModel page);
  Future<void> delete(String pageId);
}

class BookRepositoryImpl implements BookRepository {
  // In-memory storage for now - you can replace this with actual database later
  final List<PageModel> _pages = [];

  @override
  Future<List<PageModel>> getAll() async {
    // Simulate async operation
    await Future.delayed(const Duration(milliseconds: 100));
    return List.from(_pages);
  }

  @override
  Future<void> create(PageModel page) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _pages.add(page);
  }

  @override
  Future<void> update(PageModel page) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _pages.indexWhere((p) => p.id == page.id);
    if (index != -1) {
      _pages[index] = page;
    }
  }

  @override
  Future<void> delete(String pageId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _pages.removeWhere((p) => p.id == pageId);
  }
}
