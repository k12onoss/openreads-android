import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/model/ol_search_result.dart';
import 'package:openreads/resources/open_library_service.dart';
import 'package:openreads/ui/add_book_screen/widgets/widgets.dart';
import 'package:openreads/ui/search_ol_editions_screen/search_ol_editions_screen.dart';
import 'package:openreads/ui/search_ol_screen/widgets/widgets.dart';

class SearchOLScreen extends StatefulWidget {
  const SearchOLScreen({super.key, this.scan = false});

  final bool scan;

  @override
  State<SearchOLScreen> createState() => _SearchOLScreenState();
}

class _SearchOLScreenState extends State<SearchOLScreen>
    with AutomaticKeepAliveClientMixin {
  final _searchController = TextEditingController();
  int offset = 0;
  late double statusBarHeight;
  final _pageSize = 10;
  String? _searchTerm;
  int? numberOfResults;
  ScanResult? scanResult;

  bool searchActivated = false;

  final _pagingController = PagingController<int, OLSearchResultDoc>(
    firstPageKey: 0,
  );

  void _saveNoEdition({
    required double statusBarHeight,
    required List<String> editions,
    required String title,
    required String author,
    int? firstPublishYear,
    int? pagesMedian,
    int? cover,
    List<String>? isbn,
    String? olid,
  }) {
    final book = Book(
      title: title,
      author: author,
      status: 0,
      favourite: false,
      pages: pagesMedian,
      isbn: (isbn != null && isbn.isNotEmpty) ? isbn[0] : null,
      olid: (olid != null) ? olid.replaceAll('/works/', '') : null,
      publicationYear: firstPublishYear,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddBook(
        topPadding: statusBarHeight,
        previousThemeData: Theme.of(context),
        fromOpenLibrary: true,
        book: book,
        cover: cover,
      ),
    );
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      if (_searchTerm == null) {
        if (!mounted) return;

        return;
      }

      final newItems = await OpenLibraryService().getResults(
        query: _searchTerm!,
        offset: pageKey * _pageSize,
        limit: _pageSize,
      );

      setState(() {
        numberOfResults = newItems.numFound;
      });

      final isLastPage = newItems.docs.length < _pageSize;

      if (isLastPage) {
        if (!mounted) return;
        _pagingController.appendLastPage(newItems.docs);
      } else {
        final nextPageKey = pageKey + newItems.docs.length;
        if (!mounted) return;
        _pagingController.appendPage(newItems.docs, nextPageKey);
      }
    } catch (error) {
      if (!mounted) return;
      _pagingController.error = error;
    }
  }

  void _startNewSearch() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      searchActivated = true;
    });
    _searchTerm = _searchController.text;
    _pagingController.refresh();
  }

  void _startScanner() async {
    var result = await BarcodeScanner.scan(
      options: const ScanOptions(
        strings: {
          'cancel': 'Cancel',
          'flash_on': 'Flash on',
          'flash_off': 'Flash off',
        },
      ),
    );

    if (result.type == ResultType.Barcode) {
      setState(() {
        searchActivated = true;
        _searchController.text = result.rawContent;
      });

      _searchTerm = result.rawContent;
      _pagingController.refresh();
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.scan) {
      _startScanner();
    }

    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pagingController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Search in Open Library',
          style: TextStyle(fontSize: 18),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
            child: Row(
              children: [
                Expanded(
                  child: BookTextField(
                    controller: _searchController,
                    keyboardType: TextInputType.name,
                    maxLength: 99,
                    autofocus: true,
                    textInputAction: TextInputAction.search,
                    textCapitalization: TextCapitalization.words,
                    onSubmitted: (_) => _startNewSearch(),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 51,
                  child: ElevatedButton(
                    onPressed: _startNewSearch,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: Theme.of(context)
                                .extension<CustomBorder>()
                                ?.radius ??
                            BorderRadius.circular(5.0),
                      ),
                    ),
                    child: const Text(
                      "Search",
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          (numberOfResults != null && numberOfResults! != 0)
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 10, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$numberOfResults results',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                )
              : const SizedBox(),
          Expanded(
            child: (!searchActivated)
                ? const SizedBox()
                : Scrollbar(
                    child: PagedListView<int, OLSearchResultDoc>(
                      pagingController: _pagingController,
                      builderDelegate:
                          PagedChildBuilderDelegate<OLSearchResultDoc>(
                        firstPageProgressIndicatorBuilder: (_) => Center(
                          child: LoadingAnimationWidget.staggeredDotsWave(
                            color: Theme.of(context).primaryColor,
                            size: 50,
                          ),
                        ),
                        newPageProgressIndicatorBuilder: (_) => Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: LoadingAnimationWidget.staggeredDotsWave(
                              color: Theme.of(context).primaryColor,
                              size: 50,
                            ),
                          ),
                        ),
                        itemBuilder: (context, item, index) => BookCardOL(
                          title: item.title!,
                          author: (item.authorName != null &&
                                  item.authorName!.isNotEmpty)
                              ? item.authorName![0]
                              : '',
                          openLibraryKey: item.coverEditionKey,
                          doc: item,
                          editions: item.seed,
                          pagesMedian: item.numberOfPagesMedian,
                          firstPublishYear: item.firstPublishYear,
                          onAddBookPressed: () => _saveNoEdition(
                            statusBarHeight: statusBarHeight,
                            editions: item.seed!,
                            title: item.title!,
                            author: (item.authorName != null &&
                                    item.authorName!.isNotEmpty)
                                ? item.authorName![0]
                                : '',
                            pagesMedian: item.numberOfPagesMedian,
                            isbn: item.isbn,
                            olid: item.key,
                            firstPublishYear: item.firstPublishYear,
                            cover: item.coverI,
                          ),
                          onChooseEditionPressed: () {
                            FocusManager.instance.primaryFocus?.unfocus();

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SearchOLEditionsScreen(
                                  editions: item.seed!,
                                  title: item.title!,
                                  author: (item.authorName != null &&
                                          item.authorName!.isNotEmpty)
                                      ? item.authorName![0]
                                      : '',
                                  pagesMedian: item.numberOfPagesMedian,
                                  isbn: item.isbn,
                                  olid: item.key,
                                  firstPublishYear: item.firstPublishYear,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
