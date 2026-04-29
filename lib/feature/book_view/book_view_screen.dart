import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/book_bloc.dart';
import 'bloc/book_event.dart';
import 'bloc/book_state.dart';
import 'models/page_model.dart';
import 'repository/book_repository.dart';
import 'widgets/page_content.dart';

class BookViewScreen extends StatelessWidget {
  const BookViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BookBloc(BookRepositoryImpl())..add(LoadBook()),
      child: const _BookViewContent(),
    );
  }
}

class _BookViewContent extends StatefulWidget {
  const _BookViewContent();

  @override
  State<_BookViewContent> createState() => _BookViewContentState();
}

class _BookViewContentState extends State<_BookViewContent> {
  int _currentPage = 0;

  void _onPageTurn(bool isTurnForward, int totalPages) {
    setState(() {
      if (isTurnForward) {
        _currentPage = (_currentPage + 1).clamp(0, totalPages - 1);
      } else {
        _currentPage = (_currentPage - 1).clamp(0, totalPages - 1);
      }
    });
  }

  void _addNewPage(BuildContext context, int currentPageCount) {
    final newPageNumber = currentPageCount + 1;
    final newPage = PageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Page $newPageNumber',
      content: 'This is page $newPageNumber.\n\nAdd your content here!',
    );
    context.read<BookBloc>().add(AddPage(newPage));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<BookBloc, BookState>(
        builder: (context, state) {
          if (state is BookLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is BookError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          if (state is BookLoaded) {
            final pages = state.pages;

            if (pages.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('No pages yet. Add your first page!'),
                    const SizedBox(height: 16),
                    FloatingActionButton(
                      onPressed: () => _addNewPage(context, 0),
                      child: const Icon(Icons.add),
                    ),
                  ],
                ),
              );
            }

            return _BookPageView(
              pages: pages,
              currentPage: _currentPage,
              onPageTurn: _onPageTurn,
              onAddPage: () => _addNewPage(context, pages.length),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _BookPageView extends StatefulWidget {
  final List<PageModel> pages;
  final int currentPage;
  final Function(bool, int) onPageTurn;
  final VoidCallback onAddPage;

  const _BookPageView({
    required this.pages,
    required this.currentPage,
    required this.onPageTurn,
    required this.onAddPage,
  });

  @override
  State<_BookPageView> createState() => _BookPageViewState();
}

class _BookPageViewState extends State<_BookPageView> {
  late PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      initialPage: widget.currentPage,
      viewportFraction: 0.9,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView.builder(
          controller: _controller,
          itemCount: widget.pages.length,
          physics: const BouncingScrollPhysics(),
          onPageChanged: (index) {
            final isTurnForward = index > widget.currentPage;
            widget.onPageTurn(isTurnForward, widget.pages.length);
          },
          itemBuilder: (context, index) {
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                double value = 1.0;
                if (_controller.position.haveDimensions) {
                  value = _controller.page! - index;
                  value = (1 - (value.abs() * 0.3)).clamp(0.7, 1.0);
                }

                return Center(
                  child: Transform.scale(
                    scale: value,
                    child: Opacity(
                      opacity: value,
                      child: child,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                child: Card(
                  elevation: 8,
                  shadowColor: Colors.black.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: PageContent(
                      page: widget.pages[index],
                      pageNumber: index + 1,
                      totalPages: widget.pages.length,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: widget.onAddPage,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
