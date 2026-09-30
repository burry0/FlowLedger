import 'package:flowledger/core/formatting.dart';
import 'package:flowledger/l10n/l10n.dart';
import 'package:flowledger/models/client.dart';
import 'package:flowledger/models/period_category.dart';
import 'package:flutter/material.dart';

class QuickAddBar extends StatelessWidget {
  const QuickAddBar({
    super.key,
    required this.client,
    required this.categoriesFuture,
    required this.isCreatingWork,
    required this.onCategoryTap,
    required this.onOneOffTap,
  });

  final Client client;
  final Future<List<PeriodCategory>> categoriesFuture;
  final bool isCreatingWork;
  final ValueChanged<PeriodCategory> onCategoryTap;
  final VoidCallback onOneOffTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(client.name, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            FutureBuilder<List<PeriodCategory>>(
              future: categoriesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const SizedBox(
                    height: 96,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return Text(
                    context.l10n.workItemAddFailed,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  );
                }

                final categories = snapshot.requireData;
                if (categories.isEmpty) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.l10n.noCategoriesForClient),
                      const SizedBox(height: 12),
                      _OneOffCard(onTap: onOneOffTap),
                    ],
                  );
                }

                return SizedBox(
                  height: 112,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length + 1,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      if (index == categories.length) {
                        return _OneOffCard(onTap: onOneOffTap);
                      }
                      final category = categories[index];
                      return _CategoryQuickCard(
                        category: category,
                        enabled: !isCreatingWork,
                        onTap: () => onCategoryTap(category),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryQuickCard extends StatelessWidget {
  const _CategoryQuickCard({
    required this.category,
    required this.enabled,
    required this.onTap,
  });

  final PeriodCategory category;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      width: 190,
      child: OutlinedButton(
        onPressed: enabled ? onTap : null,
        style: OutlinedButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.all(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(
              context.money(category.priceSnapshot),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colors.secondary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OneOffCard extends StatelessWidget {
  const _OneOffCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      child: FilledButton.tonalIcon(
        onPressed: onTap,
        icon: const Icon(Icons.add_circle_outline),
        label: Text(context.l10n.addOneOffWork),
      ),
    );
  }
}
