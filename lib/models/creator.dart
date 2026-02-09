import 'package:flutter/material.dart';

enum CreatorStatus { verified, pending, notYet }

enum PriceRange { budget, mid, premium }

class PortfolioItem {
  final int id;
  final String title;
  final String skill;
  final String url;
  final LinearGradient cover;

  const PortfolioItem({
    required this.id,
    required this.title,
    required this.skill,
    required this.url,
    required this.cover,
  });

  PortfolioItem copyWith({
    int? id,
    String? title,
    String? skill,
    String? url,
    LinearGradient? cover,
  }) {
    return PortfolioItem(
      id: id ?? this.id,
      title: title ?? this.title,
      skill: skill ?? this.skill,
      url: url ?? this.url,
      cover: cover ?? this.cover,
    );
  }
}

class Creator {
  final int id;
  final String name;
  final String initials;
  final String companyName;
  final String profilePhotoUrl;
  final String primarySkill;
  final List<String> skills;
  final int level; // 1-3
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
    required this.name,
    required this.initials,
    this.companyName = '',
    this.profilePhotoUrl = '',
    required this.primarySkill,
    required this.skills,
    required this.level,
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
      case CreatorStatus.pending:
        return 'Pending';
      case CreatorStatus.notYet:
        return 'Not Yet';
    }
  }

  Creator copyWith({
    int? id,
    String? name,
    String? initials,
    String? companyName,
    String? profilePhotoUrl,
    String? primarySkill,
    List<String>? skills,
    int? level,
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
      name: name ?? this.name,
      initials: initials ?? this.initials,
      companyName: companyName ?? this.companyName,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      primarySkill: primarySkill ?? this.primarySkill,
      skills: skills ?? this.skills,
      level: level ?? this.level,
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
