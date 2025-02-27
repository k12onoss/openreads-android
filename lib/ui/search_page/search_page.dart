import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/main.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/ui/add_book_screen/widgets/book_text_field.dart';
import 'package:openreads/ui/book_screen/book_screen.dart';
import 'package:openreads/ui/books_screen/widgets/widgets.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    _searchController.addListener(() {
      bookCubit.getSearchBooks(_searchController.text);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LocaleKeys.search_in_books.tr(),
          style: const TextStyle(fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: BookTextField(
              controller: _searchController,
              keyboardType: TextInputType.name,
              maxLength: 99,
              autofocus: true,
              textInputAction: TextInputAction.search,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Book>>(
              stream: bookCubit.searchBooks,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final heroTag = 'tag_$index';

                      return BookCard(
                        book: snapshot.data![index],
                        heroTag: heroTag,
                        addBottomPadding: (snapshot.data!.length == index + 1),
                        onPressed: () {
                          if (snapshot.data![index].id == null) return;
                          bookCubit.clearCurrentBook();
                          bookCubit.getBook(snapshot.data![index].id!);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookScreen(
                                id: snapshot.data![index].id!,
                                heroTag: heroTag,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                } else {
                  return const SizedBox();
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
