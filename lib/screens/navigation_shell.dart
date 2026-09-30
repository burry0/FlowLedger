import 'package:flowledger/app/currency_controller.dart';
import 'package:flowledger/app/locale_controller.dart';
import 'package:flowledger/app/theme_controller.dart';
import 'package:flowledger/core/app_constants.dart';
import 'package:flowledger/l10n/l10n.dart';
import 'package:flowledger/screens/clients_screen.dart';
import 'package:flowledger/screens/dashboard_screen.dart';
import 'package:flowledger/screens/periods_screen.dart';
import 'package:flowledger/screens/settings_screen.dart';
import 'package:flowledger/screens/works_screen.dart';
import 'package:flutter/material.dart';

class NavigationShell extends StatefulWidget {
  const NavigationShell({
    super.key,
    required this.themeController,
    required this.localeController,
    required this.currencyController,
  });

  final ThemeController themeController;
  final LocaleController localeController;
  final CurrencyController currencyController;

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<NavigationShell> {
  var _selectedIndex = 0;

  void _select(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final destinations = <_Destination>[
      _Destination(label: l10n.dashboard, icon: Icons.grid_view_rounded),
      _Destination(label: l10n.clients, icon: Icons.people_outline_rounded),
      _Destination(label: l10n.workItems, icon: Icons.task_alt_outlined),
      _Destination(label: l10n.periods, icon: Icons.calendar_month_outlined),
      _Destination(label: l10n.settings, icon: Icons.settings_outlined),
    ];
    final destination = destinations[_selectedIndex];
    final isDesktop = MediaQuery.sizeOf(context).width >= 900;

    if (!isDesktop) {
      return Scaffold(
        appBar: AppBar(title: Text(destination.label)),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: IndexedStack(
            index: _selectedIndex,
            children: [
              _screenForIndex(0),
              _screenForIndex(1),
              _screenForIndex(2),
              _screenForIndex(3),
              _screenForIndex(4),
            ],
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _select,
          destinations: [
            for (final item in destinations)
              NavigationDestination(icon: Icon(item.icon), label: item.label),
          ],
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          _Sidebar(
            selectedIndex: _selectedIndex,
            destinations: destinations,
            onSelected: _select,
          ),
          VerticalDivider(
              width: 1, color: Theme.of(context).colorScheme.outlineVariant),
          Expanded(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(36, 28, 36, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(destination.label,
                        style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 28),
                    Expanded(
                      child: IndexedStack(
                        index: _selectedIndex,
                        children: [
                          _screenForIndex(0),
                          _screenForIndex(1),
                          _screenForIndex(2),
                          _screenForIndex(3),
                          _screenForIndex(4),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _screenForIndex(int index) => switch (index) {
        0 => const DashboardScreen(),
        1 => const ClientsScreen(),
        2 => const WorksScreen(),
        3 => const PeriodsScreen(),
        4 => SettingsScreen(
            themeController: widget.themeController,
            localeController: widget.localeController,
            currencyController: widget.currencyController,
          ),
        _ => const SizedBox.shrink(),
      };
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.selectedIndex,
    required this.destinations,
    required this.onSelected,
  });

  final int selectedIndex;
  final List<_Destination> destinations;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: 248,
      color: colors.surfaceContainerLow,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 14, 12, 34),
                child: Center(
                  child: Column(
                    children: [
                      SizedBox(
                        width: 64,
                        height: 64,
                        child: Image.asset(
                          'assets/branding/flowledger_icon.png',
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        AppConstants.appName,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colors.onSurface,
                              letterSpacing: 0.2,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              for (var index = 0; index < destinations.length; index++) ...[
                _SidebarItem(
                  destination: destinations[index],
                  selected: selectedIndex == index,
                  onTap: () => onSelected(index),
                ),
                const SizedBox(height: 6),
              ],
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  const _SidebarItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final _Destination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  var _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final foreground =
        widget.selected ? colors.onSurface : colors.onSurfaceVariant;
    final background = widget.selected
        ? colors.surfaceContainerHigh
        : (_hovered
            ? colors.surfaceContainerHigh.withValues(alpha: 0.6)
            : Colors.transparent);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            children: [
              if (widget.selected)
                Positioned(
                  left: 0,
                  top: 10,
                  bottom: 10,
                  child: Container(
                    width: 2,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Icon(widget.destination.icon, color: foreground, size: 22),
                    const SizedBox(width: 14),
                    Text(
                      widget.destination.label,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: foreground,
                            fontWeight: widget.selected
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Destination {
  const _Destination({required this.label, required this.icon});

  final String label;
  final IconData icon;
}
