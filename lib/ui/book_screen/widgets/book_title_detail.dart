import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:openreads/core/constants.dart/enums.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/generated/locale_keys.g.dart';

class BookTitleDetail extends StatelessWidget {
  const BookTitleDetail({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.author,
    required this.publicationYear,
    required this.bookType,
    this.tags,
  }) : super(key: key);

  final String title;
  final String? subtitle;
  final String author;
  final String publicationYear;
  final BookType bookType;
  final List<String>? tags;

  Widget _buildTagChip({
    required String tag,
    required BuildContext context,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: FilterChip(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        side: BorderSide(
          color: dividerColor,
          width: 1,
        ),
        label: Text(
          tag,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSecondary,
          ),
        ),
        onSelected: (_) {},
      ),
    );
  }

  List<Widget> _generateTagChips({required BuildContext context}) {
    final chips = List<Widget>.empty(growable: true);

    if (tags == null) {
      return [];
    }

    for (var tag in tags!) {
      chips.add(_buildTagChip(
        tag: tag,
        context: context,
      ));
    }

    return chips;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: dividerColor, width: 1),
        borderRadius: BorderRadius.circular(cornerRadius),
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
              child: SelectableText(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            subtitle != null
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
                    child: SelectableText(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : const SizedBox(),
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
              child: SelectableText(
                author,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            (publicationYear != '')
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                    child: SelectableText(
                      publicationYear,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : const SizedBox(),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FaIcon(
                    bookType == BookType.audiobook
                        ? FontAwesomeIcons.headphones
                        : bookType == BookType.ebook
                            ? FontAwesomeIcons.tablet
                            : FontAwesomeIcons.bookOpen,
                    size: 16,
                  ),
                  const SizedBox(width: 10),
                  SelectableText(
                    bookType == BookType.audiobook
                        ? LocaleKeys.book_type_audiobook.tr()
                        : bookType == BookType.ebook
                            ? LocaleKeys.book_type_ebook.tr()
                            : LocaleKeys.book_type_paper.tr(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 0,
                    ),
                    child: Wrap(
                      children: _generateTagChips(context: context),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
