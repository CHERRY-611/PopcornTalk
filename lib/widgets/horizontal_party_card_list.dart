import 'package:flutter/material.dart';

class HorizontalPartyCardList extends StatelessWidget {
  final List<dynamic> items;
  final Size imageSize;
  final Widget Function(BuildContext, dynamic, Size) itemBuilder;

  const HorizontalPartyCardList({
    Key? key,
    required this.items,
    required this.imageSize,
    required this.itemBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: imageSize.height + 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return itemBuilder(context, items[index], imageSize);
        },
      ),
    );
  }
}
