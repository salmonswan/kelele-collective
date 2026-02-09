import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/creator_provider.dart';
import '../../theme/app_theme.dart';
import '../directory/widgets/people_card.dart';

class FinderDashboard extends ConsumerWidget {
  const FinderDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final creators = ref.watch(creatorsProvider);
    final bookmarks = ref.watch(bookmarksProvider);
    final saved = creators.where((c) => bookmarks.contains(c.id)).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: KeleleColors.pink,
                  child: Text(user?.initials ?? '',
                      style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Welcome, ${user?.name ?? ''}',
                        style: GoogleFonts.spaceGrotesk(
                            fontSize: 22, fontWeight: FontWeight.w700)),
                    Text('Finder Dashboard',
                        style: TextStyle(
                            fontSize: 13, color: KeleleColors.grayMid)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text('Saved Creators',
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('${saved.length} creator${saved.length != 1 ? 's' : ''} saved',
                style:
                    TextStyle(fontSize: 13, color: KeleleColors.grayMid)),
            const SizedBox(height: 20),
            if (saved.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 60),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: KeleleColors.grayBorder),
                ),
                child: Column(
                  children: [
                    Icon(Icons.star_border,
                        size: 48, color: KeleleColors.grayBorder),
                    const SizedBox(height: 12),
                    Text('No saved creators yet',
                        style: TextStyle(color: KeleleColors.grayMid)),
                    const SizedBox(height: 8),
                    Text('Save creators from the directory to see them here.',
                        style: TextStyle(
                            fontSize: 12, color: KeleleColors.grayMid)),
                  ],
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 300,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 0.68,
                ),
                itemCount: saved.length,
                itemBuilder: (ctx, i) => PeopleCard(
                  creator: saved[i],
                  onTap: () {}, // Could navigate to profile
                ),
              ),
          ],
        ),
      ),
    );
  }
}
