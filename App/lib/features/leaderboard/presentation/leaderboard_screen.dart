import 'package:fitness_application/theme/app_colors.dart';
import 'package:flutter/material.dart';

import '../domain/weekly_leaderboard.dart';
import 'leaderboard_controller.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({required this.controller, super.key});

  final LeaderboardController controller;

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleChanged);
    widget.controller.load();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleChanged);
    super.dispose();
  }

  void _handleChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.controller.value;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        centerTitle: true,
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: _buildBody(context, state),
    );
  }

  Widget _buildBody(BuildContext context, LeaderboardViewState state) {
    if (state.isLoading && state.leaderboard == null) {
      return const Center(
        key: ValueKey('leaderboard-loading'),
        child: CircularProgressIndicator(),
      );
    }
    if (state.leaderboard == null) {
      return _ErrorView(onRetry: widget.controller.retry);
    }

    final leaderboard = state.leaderboard!;
    return RefreshIndicator(
      onRefresh: widget.controller.retry,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          _SummaryCard(leaderboard: leaderboard),
          const SizedBox(height: 24),
          Text('Weekly ranking', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          if (leaderboard.rows.isEmpty)
            const _EmptyView()
          else
            ...leaderboard.rows.map((row) => _LeaderboardTile(row: row)),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.leaderboard});

  final WeeklyLeaderboard leaderboard;

  @override
  Widget build(BuildContext context) {
    final rank = leaderboard.currentUserRank;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.background,
            foregroundColor: AppColors.accent,
            child: Icon(Icons.emoji_events_rounded),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              rank == null ? 'Keep moving' : 'Your weekly rank',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.background,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            rank == null ? '-' : '#$rank',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.background,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  const _LeaderboardTile({required this.row});

  final LeaderboardRow row;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: row.rank <= 3
              ? AppColors.accent
              : Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          child: Text('${row.rank}'),
        ),
        title: Text(row.displayName),
        trailing: Text(
          '${row.points} pts',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Text(
          'No workouts yet this week.\nBe the first to move!',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 48),
            const SizedBox(height: 16),
            Text(
              'Unable to load leaderboard.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
