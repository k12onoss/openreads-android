import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class TagsField extends StatefulWidget {
  const TagsField({
    Key? key,
    this.controller,
    this.hint,
    this.icon,
    required this.keyboardType,
    required this.maxLength,
    this.inputFormatters,
    this.autofocus = false,
    this.maxLines = 1,
    this.hideCounter = true,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.onSubmitted,
    this.onEditingComplete,
    this.tags,
    this.selectedTags,
    this.selectTag,
    this.unselectTag,
    this.allTags,
  }) : super(key: key);

  final TextEditingController? controller;
  final String? hint;
  final IconData? icon;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool autofocus;
  final int maxLines;
  final bool hideCounter;
  final int maxLength;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final Function(String)? onSubmitted;
  final Function()? onEditingComplete;
  final List<String>? tags;
  final List<String>? selectedTags;
  final Function(String)? selectTag;
  final Function(String)? unselectTag;
  final List<String>? allTags;

  @override
  State<TagsField> createState() => _TagsFieldState();
}

class _TagsFieldState extends State<TagsField> {
  final FocusNode focusNode = FocusNode();
  bool showClearButton = false;

  Widget _buildTagChip({required String tag, required bool selected}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: FilterChip(
        side: BorderSide(color: dividerColor, width: 1),
        label: Text(
          tag,
          style: TextStyle(
            color: selected ? Theme.of(context).colorScheme.onSecondary : null,
          ),
        ),
        checkmarkColor:
        selected ? Theme.of(context).colorScheme.onSecondary : null,
        selected: selected,
        selectedColor: Theme.of(context).colorScheme.secondary,
        onSelected: (newState) {
          if (widget.selectTag == null || widget.unselectTag == null) return;
          newState ? widget.selectTag!(tag) : widget.unselectTag!(tag);
        },
      ),
    );
  }

  List<Widget> _generateTagChips() {
    final chips = List<Widget>.empty(growable: true);

    if (widget.tags == null) {
      return [];
    }

    for (var tag in widget.tags!) {
      chips.add(_buildTagChip(
        tag: tag,
        selected: (widget.selectedTags?.contains(tag) == true) ? true : false,
      ));
    }

    return chips;
  }

  @override
  void initState() {
    super.initState();

    if (widget.controller == null) return;

    widget.controller!.addListener(() {
      setState(() {
        if (widget.controller!.text.isNotEmpty) {
          showClearButton = true;
        } else {
          showClearButton = false;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(cornerRadius),
        border: Border.all(color: dividerColor),
      ),
      child: Column(
        children: [
          Scrollbar(
              child: TypeAheadField(
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    title: Text(suggestion),
                  );
                },
                suggestionsCallback: (pattern) {
                  if (widget.allTags == null) {
                    return List<String>.empty();
                  }
                  return  widget.allTags!.where((String option) {
                    return option.toLowerCase().contains(pattern.toLowerCase());
                  }).toList();
                },
                onSuggestionSelected: (suggestion) {
                  widget.controller?.text = suggestion;
                  if (widget.onSubmitted != null) {
                    widget.onSubmitted!(suggestion);
                  }
                },
                hideOnLoading: true,
                hideOnEmpty: true,
                suggestionsBoxDecoration: SuggestionsBoxDecoration(
                  borderRadius: BorderRadius.circular(4.0),
                  elevation: 8.0,
                ),
                textFieldConfiguration: TextFieldConfiguration(
                  autofocus: widget.autofocus,
                  keyboardType: widget.keyboardType,
                  inputFormatters: widget.inputFormatters,
                  textCapitalization: widget.textCapitalization,
                  controller: widget.controller,
                  focusNode: focusNode,
                  minLines: 1,
                  maxLines: widget.maxLines,
                  maxLength: widget.maxLength,
                  textInputAction: widget.textInputAction,
                  style: const TextStyle(fontSize: 14),
                  onSubmitted: widget.onSubmitted,
                  onEditingComplete: widget.onEditingComplete,
                  decoration: InputDecoration(
                    labelText: widget.hint,
                    icon: (widget.icon != null)
                        ? Icon(
                      widget.icon,
                      color: Theme.of(context).colorScheme.primary,
                    )
                        : null,
                    border: InputBorder.none,
                    counterText: widget.hideCounter ? "" : null,
                    suffixIcon: showClearButton
                        ? IconButton(
                      onPressed: () {
                        if (widget.controller == null) return;

                        widget.controller!.clear();
                        setState(() {
                          showClearButton = false;
                        });
                        focusNode.requestFocus();
                      },
                      icon: const Icon(Icons.clear),
                    )
                        : null,
                  ),
                ),
              )
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 2.5,
                  ),
                  child: Wrap(
                    children: _generateTagChips(),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}