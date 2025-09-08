import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants.dart';
import '../providers/providers.dart';

class CategoryChips extends ConsumerWidget {
  const CategoryChips({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(categoryProvider);
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final cat = Constants.categoryList[index];
          final isSelected = cat == selected;
          return ChoiceChip(
            label: Text(cat.toUpperCase()),
            selected: isSelected,
            onSelected: (v) {
              if (v) {
                ref.read(categoryProvider.notifier).state = cat;
                // refresh headlines by recreating notifier
                ref.invalidate(headlinesProvider);
              }
            },
            selectedColor: Colors.indigo,
            backgroundColor: Colors.white,
            labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontSize: 12),
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: Constants.categoryList.length,
      ),
    );
  }
}
