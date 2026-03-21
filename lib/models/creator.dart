import 'package:flutter/material.dart';

enum CreatorStatus { verified, verifiedEmerging, pending, notYet, rejected }

enum PriceRange { budget, mid, premium }

enum CompanyRole { founder, coFounder, employee, none }

enum Specialty {
  contentCreation,
  filmTv,
  musicIndustry,
  advertising,
  fashion,
  art,
  gaming,
  comic,
  editorial,
  architecture,
  documentary,
  educational,
  mediaForKids
}

// ─── Skill Entry (discipline + specification + experience) ───
class SkillEntry {
  final String discipline;
  final String? specification;
  final int yearsOfExperience;

  const SkillEntry({
    required this.discipline,
    this.specification,
    required this.yearsOfExperience,
  });

  Map<String, dynamic> toMap() => {
        'discipline': discipline,
        'specification': specification,
        'yearsOfExperience': yearsOfExperience,
      };

  factory SkillEntry.fromMap(Map<String, dynamic> map) => SkillEntry(
        discipline: map['discipline'] as String? ?? '',
        specification: map['specification'] as String?,
        yearsOfExperience: map['yearsOfExperience'] as int? ?? 1,
      );

  SkillEntry copyWith({
    String? discipline,
    String? specification,
    int? yearsOfExperience,
  }) {
    return SkillEntry(
      discipline: discipline ?? this.discipline,
      specification: specification ?? this.specification,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
    );
  }
}

// ─── External Link (PDFs, resources, etc.) ───
class ExternalLink {
  final String label;
  final String url;

  const ExternalLink({required this.label, required this.url});

  Map<String, dynamic> toMap() => {'label': label, 'url': url};

  factory ExternalLink.fromMap(Map<String, dynamic> map) => ExternalLink(
        label: map['label'] as String? ?? '',
        url: map['url'] as String? ?? '',
      );

  ExternalLink copyWith({String? label, String? url}) {
    return ExternalLink(
      label: label ?? this.label,
      url: url ?? this.url,
    );
  }
}

class PortfolioItem {
  final String id;
  final String title;
  final String skill;
  final String url;
  final String coverImageUrl;
  final String? videoUrl; // YouTube/Vimeo embed URL
  final LinearGradient cover;
  final List<String> coverColors;

  const PortfolioItem({
    required this.id,
    required this.title,
    required this.skill,
    required this.url,
    this.coverImageUrl = '',
    this.videoUrl,
    required this.cover,
    this.coverColors = const [],
  });

  bool get hasCoverImage => coverImageUrl.isNotEmpty;
  bool get isAssetImage => coverImageUrl.startsWith('assets/');

  factory PortfolioItem.fromMap(Map<String, dynamic> map) {
    final colors = List<String>.from(map['coverColors'] ?? []);
    return PortfolioItem(
      id: (map['id'] ?? '').toString(),
      title: map['title'] ?? '',
      skill: map['skill'] ?? '',
      url: map['url'] ?? '',
      coverImageUrl: map['coverImageUrl'] ?? '',
      videoUrl: map['videoUrl'] as String?,
      coverColors: colors,
      cover: _buildGradient(colors),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'skill': skill,
        'url': url,
        'coverImageUrl': coverImageUrl,
        'videoUrl': videoUrl,
        'coverColors': coverColors,
      };

  static LinearGradient _buildGradient(List<String> hexColors) {
    if (hexColors.isEmpty) {
      return const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)]);
    }
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: hexColors.map((h) {
        final hex = h.replaceFirst('#', '');
        return Color(int.parse('FF$hex', radix: 16));
      }).toList(),
    );
  }

  PortfolioItem copyWith({
    String? id,
    String? title,
    String? skill,
    String? url,
    String? coverImageUrl,
    String? videoUrl,
    LinearGradient? cover,
    List<String>? coverColors,
  }) {
    return PortfolioItem(
      id: id ?? this.id,
      title: title ?? this.title,
      skill: skill ?? this.skill,
      url: url ?? this.url,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      cover: cover ?? this.cover,
      coverColors: coverColors ?? this.coverColors,
    );
  }
}

class Creator {
  final String id;
  final String? userId;
  final String name;
  final String initials;
  final String companyName;
  final String profilePhotoUrl;

  // NEW FIELDS
  final String? artistName; // Stage name (optional)
  final CompanyRole companyRole; // founder/coFounder/employee/none
  final SkillEntry mainSkill; // Replaces primarySkill
  final List<SkillEntry> sideSkills; // Max 3, replaces skills list
  final List<Specialty> specialties; // Max 5
  final List<String> software; // From predefined list + custom
  final String services; // Free-form "What I offer"
  final List<ExternalLink> externalLinks; // PDFs, resources beyond social
  final List<String> featuredVideoUrls; // 2-3 header videos (YouTube/Vimeo embed URLs)
  final List<String> clients; // Client names for "Clients I've worked for"

  // DEPRECATED (keep for migration, don't display)
  final String primarySkill; // Deprecated: use mainSkill.discipline
  final List<String> skills; // Deprecated: use sideSkills
  final int level; // Deprecated: use mainSkill.yearsOfExperience

  final PriceRange priceRange;
  final String bio;
  final String location;
  final bool featured;
  final bool isPublic;
  final String email;
  final String phone;
  final String whatsapp;
  final CreatorStatus status;
  final List<PortfolioItem> portfolio;
  final String behance;
  final String instagram;
  final String youtube;
  final String linkedin;
  final String website;
  final String portfolioOther;
  final String reviewNotes;
  final String reviewedBy;
  final String reviewedAt;
  final String reapplyAfter;

  const Creator({
    required this.id,
    this.userId,
    required this.name,
    required this.initials,
    this.companyName = '',
    this.profilePhotoUrl = '',
    // New fields
    this.artistName,
    this.companyRole = CompanyRole.none,
    required this.mainSkill,
    this.sideSkills = const [],
    this.specialties = const [],
    this.software = const [],
    this.services = '',
    this.externalLinks = const [],
    this.featuredVideoUrls = const [],
    this.clients = const [],
    // Deprecated fields
    required this.primarySkill,
    required this.skills,
    required this.level,
    // Existing fields
    required this.priceRange,
    required this.bio,
    required this.location,
    this.featured = false,
    this.isPublic = true,
    required this.email,
    required this.phone,
    this.whatsapp = '',
    required this.status,
    required this.portfolio,
    this.behance = '',
    this.instagram = '',
    this.youtube = '',
    this.linkedin = '',
    this.website = '',
    this.portfolioOther = '',
    this.reviewNotes = '',
    this.reviewedBy = '',
    this.reviewedAt = '',
    this.reapplyAfter = '',
  });

  factory Creator.fromFirestore(String docId, Map<String, dynamic> data) {
    // Deprecated fields (for migration)
    final primarySkillOld = data['primarySkill'] ?? '';
    final skillsOld = List<String>.from(data['skills'] ?? []);
    final levelOld = (data['level'] ?? 1) as int;

    return Creator(
      id: docId,
      userId: data['userId'] as String?,
      name: data['name'] ?? '',
      initials: data['initials'] ?? '',
      companyName: data['companyName'] ?? '',
      profilePhotoUrl: data['profilePhotoUrl'] ?? '',

      // New fields with defaults
      artistName: data['artistName'] as String?,
      companyRole: CompanyRole.values.firstWhere(
        (e) => e.name == data['companyRole'],
        orElse: () => CompanyRole.none,
      ),
      mainSkill: data['mainSkill'] != null
          ? SkillEntry.fromMap(data['mainSkill'] as Map<String, dynamic>)
          : SkillEntry(
              discipline: primarySkillOld,
              yearsOfExperience: _levelToYears(levelOld)), // Fallback migration
      sideSkills: (data['sideSkills'] as List<dynamic>?)
              ?.map((e) => SkillEntry.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      specialties: (data['specialties'] as List<dynamic>?)
              ?.map((e) => Specialty.values.firstWhere((s) => s.name == e,
                  orElse: () => Specialty.contentCreation))
              .toList() ??
          [],
      software: (data['software'] as List<dynamic>?)?.cast<String>() ?? [],
      services: data['services'] as String? ?? '',
      externalLinks: (data['externalLinks'] as List<dynamic>?)
              ?.map((e) => ExternalLink.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      featuredVideoUrls:
          (data['featuredVideoUrls'] as List<dynamic>?)?.cast<String>() ?? [],
      clients:
          (data['clients'] as List<dynamic>?)?.cast<String>() ?? [],

      // Deprecated fields (keep for migration)
      primarySkill: primarySkillOld,
      skills: skillsOld,
      level: levelOld,

      // Existing fields
      priceRange: PriceRange.values.firstWhere(
        (p) => p.name == data['priceRange'],
        orElse: () => PriceRange.mid,
      ),
      bio: data['bio'] ?? '',
      location: data['location'] ?? '',
      featured: data['featured'] ?? false,
      isPublic: data['isPublic'] ?? true,
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      whatsapp: data['whatsapp'] ?? '',
      status: CreatorStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => CreatorStatus.pending,
      ),
      portfolio: (data['portfolio'] as List<dynamic>? ?? [])
          .map((m) => PortfolioItem.fromMap(m as Map<String, dynamic>))
          .toList(),
      behance: data['behance'] ?? '',
      instagram: data['instagram'] ?? '',
      youtube: data['youtube'] ?? '',
      linkedin: data['linkedin'] ?? '',
      website: data['website'] ?? '',
      portfolioOther: data['portfolioOther'] ?? '',
      reviewNotes: data['reviewNotes'] ?? '',
      reviewedBy: data['reviewedBy'] ?? '',
      reviewedAt: data['reviewedAt'] ?? '',
      reapplyAfter: data['reapplyAfter'] ?? '',
    );
  }

  // Helper for migrating level to years
  static int _levelToYears(int level) {
    switch (level) {
      case 1:
        return 2; // Emerging
      case 2:
        return 4; // Skilled
      case 3:
        return 8; // Expert
      default:
        return 3;
    }
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'initials': initials,
        'companyName': companyName,
        'profilePhotoUrl': profilePhotoUrl,

        // New fields
        'artistName': artistName,
        'companyRole': companyRole.name,
        'mainSkill': mainSkill.toMap(),
        'sideSkills': sideSkills.map((e) => e.toMap()).toList(),
        'specialties': specialties.map((e) => e.name).toList(),
        'software': software,
        'services': services,
        'externalLinks': externalLinks.map((e) => e.toMap()).toList(),
        'featuredVideoUrls': featuredVideoUrls,
        'clients': clients,

        // Deprecated fields (still save for migration period)
        'primarySkill': mainSkill.discipline,
        'skills': [mainSkill.discipline, ...sideSkills.map((e) => e.discipline)],
        'level': experienceToLevel(mainSkill.yearsOfExperience),

        // Existing fields
        'priceRange': priceRange.name,
        'bio': bio,
        'location': location,
        'featured': featured,
        'isPublic': isPublic,
        'email': email,
        'phone': phone,
        'whatsapp': whatsapp,
        'status': status.name,
        'portfolio': portfolio.map((p) => p.toMap()).toList(),
        'behance': behance,
        'instagram': instagram,
        'youtube': youtube,
        'linkedin': linkedin,
        'website': website,
        'portfolioOther': portfolioOther,
        'reviewNotes': reviewNotes,
        'reviewedBy': reviewedBy,
        'reviewedAt': reviewedAt,
        'reapplyAfter': reapplyAfter,
        'userId': userId,
      };

  // Helper for converting experience years back to level
  static int experienceToLevel(int years) {
    if (years <= 2) return 1; // Emerging
    if (years <= 5) return 2; // Skilled
    return 3; // Expert
  }

  String get levelLabel {
    switch (level) {
      case 3:
        return 'Expert';
      case 2:
        return 'Skilled';
      default:
        return 'Emerging';
    }
  }

  String get priceLabel {
    switch (priceRange) {
      case PriceRange.premium:
        return 'Premium';
      case PriceRange.mid:
        return 'Mid-range';
      case PriceRange.budget:
        return 'Budget';
    }
  }

  String get statusLabel {
    switch (status) {
      case CreatorStatus.verified:
        return 'Verified';
      case CreatorStatus.verifiedEmerging:
        return 'Emerging';
      case CreatorStatus.pending:
        return 'Pending';
      case CreatorStatus.notYet:
        return 'Not Yet';
      case CreatorStatus.rejected:
        return 'Rejected';
    }
  }

  Creator copyWith({
    String? id,
    String? userId,
    String? name,
    String? initials,
    String? companyName,
    String? profilePhotoUrl,
    // New fields
    String? artistName,
    CompanyRole? companyRole,
    SkillEntry? mainSkill,
    List<SkillEntry>? sideSkills,
    List<Specialty>? specialties,
    List<String>? software,
    String? services,
    List<ExternalLink>? externalLinks,
    List<String>? featuredVideoUrls,
    List<String>? clients,
    // Deprecated fields
    String? primarySkill,
    List<String>? skills,
    int? level,
    // Existing fields
    PriceRange? priceRange,
    String? bio,
    String? location,
    bool? featured,
    bool? isPublic,
    String? email,
    String? phone,
    String? whatsapp,
    CreatorStatus? status,
    List<PortfolioItem>? portfolio,
    String? behance,
    String? instagram,
    String? youtube,
    String? linkedin,
    String? website,
    String? portfolioOther,
    String? reviewNotes,
    String? reviewedBy,
    String? reviewedAt,
    String? reapplyAfter,
  }) {
    return Creator(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      initials: initials ?? this.initials,
      companyName: companyName ?? this.companyName,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      // New fields
      artistName: artistName ?? this.artistName,
      companyRole: companyRole ?? this.companyRole,
      mainSkill: mainSkill ?? this.mainSkill,
      sideSkills: sideSkills ?? this.sideSkills,
      specialties: specialties ?? this.specialties,
      software: software ?? this.software,
      services: services ?? this.services,
      externalLinks: externalLinks ?? this.externalLinks,
      featuredVideoUrls: featuredVideoUrls ?? this.featuredVideoUrls,
      clients: clients ?? this.clients,
      // Deprecated fields
      primarySkill: primarySkill ?? this.primarySkill,
      skills: skills ?? this.skills,
      level: level ?? this.level,
      // Existing fields
      priceRange: priceRange ?? this.priceRange,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      featured: featured ?? this.featured,
      isPublic: isPublic ?? this.isPublic,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      status: status ?? this.status,
      portfolio: portfolio ?? this.portfolio,
      behance: behance ?? this.behance,
      instagram: instagram ?? this.instagram,
      youtube: youtube ?? this.youtube,
      linkedin: linkedin ?? this.linkedin,
      website: website ?? this.website,
      portfolioOther: portfolioOther ?? this.portfolioOther,
      reviewNotes: reviewNotes ?? this.reviewNotes,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reapplyAfter: reapplyAfter ?? this.reapplyAfter,
    );
  }
}
