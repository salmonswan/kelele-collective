import 'package:flutter/material.dart';
import '../models/creator.dart';

// Main disciplines with their specifications
const Map<String, List<String>> disciplineSpecifications = {
  'Photographer': ['for event', 'for nature', 'for studio'],
  'Cinematographer': ['for Documentary'],
  'Video Editor': [],
  '2D Animator': [],
  '3D Artist': [
    'for Modelling',
    'for Rigging',
    'for Architecture',
    'for Animation',
    'for Products'
  ],
  'Motion Designer': ['for Animation', 'for VFX', 'for Live-Events'],
  'Graphic Designer': ['for Branding', 'for Print', 'for online'],
  'Illustrator': [
    'for Character Design',
    'for Storyboarding',
    'for Concept Art',
    'for Comics'
  ],
  'Set Designer': [],
  'Audio Producer': ['for Composing', 'for Sounddesign'],
  'Director': ['for Film', 'for Animation', 'for Documentary'],
  'Film Producer': ['for Animation', 'for Events'],
  'Writer': ['for Screen', 'for Comics'],
  'AI Specialist': [],
  'Actor': [],
  'Scenography': [],
};

// Just the discipline names (for backward compat)
final skillsList = disciplineSpecifications.keys.toList();

// Software & Tools
const softwareList = [
  // Photo/Video
  'Adobe Photoshop',
  'Adobe Lightroom',
  'Adobe Premiere Pro',
  'DaVinci Resolve',
  'Final Cut Pro',
  'Capcut',
  // Animation
  'Toon Boom Harmony',
  'Adobe Animate',
  'Moho Pro (Anime Studio)',
  'TVPaint',
  'Clip Studio Paint',
  // Design
  'Adobe Illustrator',
  'Adobe InDesign',
  'Affinity',
  'Canva',
  // 3D
  'Cinema 4D',
  'Blender',
  'Maya',
  'Spline',
  // Motion/VFX
  'Adobe After Effects',
  'Cavalry',
  'Rive',
  // Audio
  'Logic',
  'Adobe Audition',
  'Audacity',
  // Other
  'Procreate',
  'GIMP',
  'Canon',
  'Sony',
  'Blackmagic',
];

// Specialty/Industry labels
const specialtyLabels = {
  Specialty.contentCreation: 'Content Creation',
  Specialty.filmTv: 'Film/TV',
  Specialty.musicIndustry: 'Music Industry',
  Specialty.advertising: 'Advertising',
  Specialty.fashion: 'Fashion',
  Specialty.art: 'Art',
  Specialty.gaming: 'Gaming',
  Specialty.comic: 'Comic',
  Specialty.editorial: 'Editorial',
  Specialty.architecture: 'Architecture',
  Specialty.documentary: 'Documentary',
  Specialty.educational: 'Educational',
  Specialty.mediaForKids: 'Media for Kids',
};

LinearGradient _g(List<Color> colors) =>
    LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors);

const _profiles = 'assets/images/profiles';
const _covers = 'assets/images/portfolio';

final List<Creator> mockCreators = [
  Creator(
    id: '1',
    name: 'Amara Nakato',
    initials: 'AN',
    profilePhotoUrl: '$_profiles/amara.jpg',

    // New fields
    artistName: null,
    companyRole: CompanyRole.none,
    mainSkill: SkillEntry(
      discipline: 'Photographer',
      specification: 'for event',
      yearsOfExperience: 7,
    ),
    sideSkills: [
      SkillEntry(discipline: 'Cinematographer', specification: null, yearsOfExperience: 4),
      SkillEntry(discipline: 'Video Editor', specification: null, yearsOfExperience: 3),
    ],
    specialties: [Specialty.advertising, Specialty.fashion, Specialty.contentCreation],
    software: ['Adobe Photoshop', 'Adobe Lightroom', 'DaVinci Resolve', 'Canon'],
    services: 'Event photography and videography with full post-production. Available for freelance gigs and production consulting.',
    externalLinks: [],
    featuredVideoUrls: ['https://vimeo.com/example/showreel-amara'],
    clients: ['Daily Monitor', 'Kampala Serena Hotel', 'Pearl of Africa Tourism'],

    // Deprecated fields (for migration)
    primarySkill: 'Photography',
    skills: ['Photography', 'Cinematography', 'Editing'],
    level: 3,

    // Existing fields
    priceRange: PriceRange.mid,
    bio: 'Documentary & editorial photographer capturing East African stories with authenticity and depth.',
    location: 'Kampala',
    featured: true,
    email: 'amara@email.com',
    phone: '+256 700 123 456',
    whatsapp: '+256700123456',
    status: CreatorStatus.verified,
    portfolio: [
      PortfolioItem(id: '1', title: 'Kampala Streets', skill: 'Photography', url: 'https://behance.net/amara1', coverImageUrl: '$_covers/kampala-streets.jpg', cover: _g([const Color(0xFF2d1b69), const Color(0xFF11998e)])),
      PortfolioItem(id: '2', title: 'Lake Victoria Dawn', skill: 'Photography', url: 'https://behance.net/amara2', coverImageUrl: '$_covers/lake-victoria.jpg', cover: _g([const Color(0xFFf5af19), const Color(0xFFf12711)])),
      PortfolioItem(id: '3', title: 'Wedding Film', skill: 'Cinematography', url: 'https://youtube.com/amara3', coverImageUrl: '$_covers/wedding-film.jpg', cover: _g([const Color(0xFF3a1c71), const Color(0xFFd76d77), const Color(0xFFffaf7b)])),
    ],
    behance: 'https://behance.net/amara',
    instagram: '@amara.photo',
    youtube: 'https://youtube.com/@amara',
    website: 'https://amaranakato.com',
    reviewNotes: 'Excellent portfolio with strong editorial work. Verified.',
    reviewedBy: 'Tobi',
    reviewedAt: '2025-01-15',
  ),
  Creator(
    id: '2',
    name: 'Daniel Okello',
    initials: 'DO',
    profilePhotoUrl: '$_profiles/daniel.jpg',

    // New fields
    artistName: null,
    companyRole: CompanyRole.founder,
    mainSkill: SkillEntry(
      discipline: 'Motion Designer',
      specification: 'for Animation',
      yearsOfExperience: 9,
    ),
    sideSkills: [
      SkillEntry(discipline: '3D Artist', specification: 'for Products', yearsOfExperience: 6),
      SkillEntry(discipline: 'Graphic Designer', specification: 'for Branding', yearsOfExperience: 5),
    ],
    specialties: [Specialty.advertising, Specialty.filmTv, Specialty.contentCreation],
    software: ['Adobe After Effects', 'Cinema 4D', 'Adobe Illustrator', 'Blender'],
    services: 'Full-service motion design and 3D animation for commercials, explainers, and brand identity.',
    externalLinks: [],
    featuredVideoUrls: ['https://vimeo.com/example/showreel-daniel', 'https://youtube.com/watch?v=example-daniel'],
    clients: ['MTN Uganda', 'Thrones Kampala', 'Bugolobi Bamboo', 'Brand Factory UG'],

    // Deprecated fields
    primarySkill: 'Motion Design',
    skills: ['Motion Design', '3D Animation', 'Art Direction'],
    level: 3,

    // Existing fields
    priceRange: PriceRange.premium,
    bio: 'Award-winning motion designer creating bold visual narratives for brands across Africa.',
    location: 'Kampala',
    featured: true,
    companyName: 'Okello Studios',
    email: 'daniel@email.com',
    phone: '+256 700 234 567',
    whatsapp: '+256700234567',
    status: CreatorStatus.verified,
    portfolio: [
      PortfolioItem(id: '4', title: 'MTN Brand Spot', skill: 'Motion Design', url: 'https://vimeo.com/daniel1', coverImageUrl: '$_covers/mtn-brand.jpg', cover: _g([const Color(0xFFFF1A66), const Color(0xFFC40041)])),
      PortfolioItem(id: '5', title: 'Product Vis', skill: '3D Animation', url: 'https://behance.net/daniel2', coverImageUrl: '$_covers/product-vis.jpg', cover: _g([const Color(0xFF0f0c29), const Color(0xFF302b63), const Color(0xFF24243e)])),
    ],
    behance: 'https://behance.net/daniel',
    instagram: '@daniel.motion',
    linkedin: 'https://linkedin.com/in/danielokello',
    reviewNotes: 'Outstanding motion work. Top tier.',
    reviewedBy: 'Tobi',
    reviewedAt: '2025-01-20',
  ),
  Creator(
    id: '3',
    name: 'Fatima Abdi',
    initials: 'FA',
    profilePhotoUrl: '$_profiles/fatima.jpg',

    // New fields
    artistName: null,
    companyRole: CompanyRole.none,
    mainSkill: SkillEntry(
      discipline: 'Graphic Designer',
      specification: 'for Branding',
      yearsOfExperience: 5,
    ),
    sideSkills: [
      SkillEntry(discipline: 'Illustrator', specification: 'for Concept Art', yearsOfExperience: 4),
    ],
    specialties: [Specialty.contentCreation, Specialty.advertising, Specialty.editorial],
    software: ['Adobe Illustrator', 'Adobe InDesign', 'Adobe Photoshop', 'Affinity'],
    services: 'Brand identity design, packaging, and editorial layout. Freelance and project-based work.',
    externalLinks: [],
    featuredVideoUrls: [],
    clients: ['Endiro Coffee', 'Motiv Uganda'],

    // Deprecated fields
    primarySkill: 'Graphic Design (Digital)',
    skills: ['Graphic Design (Digital)', 'Illustration', 'Graphic Design (Print)'],
    level: 2,

    // Existing fields
    priceRange: PriceRange.mid,
    bio: 'Brand identity specialist blending traditional Ugandan patterns with modern design sensibility.',
    location: 'Entebbe',
    email: 'fatima@email.com',
    phone: '+256 700 345 678',
    whatsapp: '+256700345678',
    status: CreatorStatus.verified,
    portfolio: [
      PortfolioItem(id: '6', title: 'Cafe Branding', skill: 'Graphic Design (Digital)', url: 'https://behance.net/fatima1', coverImageUrl: '$_covers/cafe-brand.jpg', cover: _g([const Color(0xFFffe259), const Color(0xFFffa751)])),
      PortfolioItem(id: '7', title: 'Pattern Series', skill: 'Illustration', url: 'https://behance.net/fatima2', coverImageUrl: '$_covers/pattern-art.jpg', cover: _g([const Color(0xFFa8e063), const Color(0xFF56ab2f)])),
      PortfolioItem(id: '8', title: 'Annual Report', skill: 'Graphic Design (Print)', url: 'https://behance.net/fatima3', coverImageUrl: '$_covers/annual-report.jpg', cover: _g([const Color(0xFF434343), const Color(0xFF000000)])),
    ],
    behance: 'https://behance.net/fatima',
    instagram: '@fatima.design',
    website: 'https://fatimaabdi.com',
    reviewNotes: 'Good brand work, growing portfolio.',
    reviewedBy: 'Tobi',
    reviewedAt: '2025-02-01',
  ),
  Creator(
    id: '4',
    name: 'Joseph Tumusiime',
    initials: 'JT',
    profilePhotoUrl: '$_profiles/joseph.jpg',

    // New fields
    artistName: null,
    companyRole: CompanyRole.founder,
    mainSkill: SkillEntry(
      discipline: 'Cinematographer',
      specification: 'for Documentary',
      yearsOfExperience: 10,
    ),
    sideSkills: [
      SkillEntry(discipline: 'Video Editor', specification: null, yearsOfExperience: 8),
      SkillEntry(discipline: 'Film Producer', specification: null, yearsOfExperience: 6),
    ],
    specialties: [Specialty.filmTv, Specialty.musicIndustry, Specialty.documentary, Specialty.advertising],
    software: ['DaVinci Resolve', 'Adobe Premiere Pro', 'Sony', 'Blackmagic'],
    services: 'Full production services: cinematography, editing, and producing for films, commercials, and music videos.',
    externalLinks: [],
    featuredVideoUrls: ['https://vimeo.com/example/showreel-kwame', 'https://youtube.com/watch?v=example-kwame'],
    clients: ['Airtel Uganda', 'NBS TV', 'Nile Breweries'],

    // Deprecated fields
    primarySkill: 'Cinematography',
    skills: ['Cinematography', 'Editing', 'Producing'],
    level: 3,

    // Existing fields
    priceRange: PriceRange.premium,
    bio: 'Cinematic storyteller producing films, music videos, and branded content for East African markets.',
    location: 'Kampala',
    featured: true,
    companyName: 'JT Films',
    email: 'joseph@email.com',
    phone: '+256 700 456 789',
    whatsapp: '+256700456789',
    status: CreatorStatus.verified,
    portfolio: [
      PortfolioItem(id: '9', title: 'Afrobeats Music Video', skill: 'Cinematography', url: 'https://youtube.com/joseph1', coverImageUrl: '$_covers/afrobeats-mv.jpg', cover: _g([const Color(0xFFe44d26), const Color(0xFFf16529)])),
      PortfolioItem(id: '10', title: 'NGO Documentary', skill: 'Cinematography', url: 'https://vimeo.com/joseph2', coverImageUrl: '$_covers/ngo-doc.jpg', cover: _g([const Color(0xFF0C0C20), const Color(0xFF1a1a3e)])),
      PortfolioItem(id: '11', title: 'Commercial — Airtel', skill: 'Producing', url: 'https://youtube.com/joseph3', coverImageUrl: '$_covers/airtel-ad.jpg', cover: _g([const Color(0xFF8E2DE2), const Color(0xFF4A00E0)])),
    ],
    instagram: '@joseph.films',
    youtube: 'https://youtube.com/@josephfilms',
    website: 'https://josephfilms.ug',
    linkedin: 'https://linkedin.com/in/josepht',
    reviewNotes: 'Cinematic quality is excellent.',
    reviewedBy: 'Tobi',
    reviewedAt: '2025-01-25',
  ),
  Creator(
    id: '5',
    name: 'Grace Achieng',
    initials: 'GA',
    profilePhotoUrl: '$_profiles/grace.jpg',

    // New fields
    artistName: null,
    companyRole: CompanyRole.none,
    mainSkill: SkillEntry(
      discipline: 'Graphic Designer',
      specification: 'for online',
      yearsOfExperience: 3,
    ),
    sideSkills: [
      SkillEntry(discipline: 'Illustrator', specification: null, yearsOfExperience: 2),
    ],
    specialties: [Specialty.contentCreation, Specialty.advertising],
    software: ['Adobe Illustrator', 'Canva', 'Figma'],
    services: 'UI/UX design and digital branding for startups and small businesses.',
    externalLinks: [],
    featuredVideoUrls: [],
    clients: [],

    // Deprecated fields
    primarySkill: 'Graphic Design (Digital)',
    skills: ['Graphic Design (Digital)', 'Illustration'],
    level: 2,

    // Existing fields
    priceRange: PriceRange.budget,
    bio: 'Digital designer focused on building intuitive brand experiences for African audiences.',
    location: 'Jinja',
    email: 'grace@email.com',
    phone: '+256 700 567 890',
    status: CreatorStatus.pending,
    portfolio: [
      PortfolioItem(id: '12', title: 'FinTech App Design', skill: 'Graphic Design (Digital)', url: 'https://figma.com/grace1', coverImageUrl: '$_covers/fintech-app.jpg', cover: _g([const Color(0xFF667eea), const Color(0xFF764ba2)])),
    ],
    instagram: '@grace.designs',
    reapplyAfter: '',
  ),
  Creator(
    id: '6',
    name: 'Samuel Wasswa',
    initials: 'SW',
    profilePhotoUrl: '$_profiles/samuel.jpg',

    // New fields
    artistName: null,
    companyRole: CompanyRole.none,
    mainSkill: SkillEntry(
      discipline: 'Video Editor',
      specification: null,
      yearsOfExperience: 5,
    ),
    sideSkills: [
      SkillEntry(discipline: 'Cinematographer', specification: null, yearsOfExperience: 3),
    ],
    specialties: [Specialty.musicIndustry, Specialty.filmTv, Specialty.contentCreation],
    software: ['Adobe Premiere Pro', 'DaVinci Resolve', 'Final Cut Pro'],
    services: 'Video editing and color grading for films, music videos, and branded content.',
    externalLinks: [],
    featuredVideoUrls: ['https://youtube.com/watch?v=example-fatima'],
    clients: ['Swangz Avenue', 'Fenon Records'],

    // Deprecated fields
    primarySkill: 'Editing',
    skills: ['Editing', 'Cinematography'],
    level: 2,

    // Existing fields
    priceRange: PriceRange.mid,
    bio: 'Film editor and colorist with a passion for narrative storytelling and music video editing.',
    location: 'Kampala',
    email: 'samuel@email.com',
    phone: '+256 700 678 901',
    whatsapp: '+256700678901',
    status: CreatorStatus.verified,
    portfolio: [
      PortfolioItem(id: '13', title: 'Short Film Edit', skill: 'Editing', url: 'https://vimeo.com/samuel1', coverImageUrl: '$_covers/short-film.jpg', cover: _g([const Color(0xFF1DB954), const Color(0xFF191414)])),
      PortfolioItem(id: '14', title: 'Music Video Reel', skill: 'Editing', url: 'https://youtube.com/samuel2', coverImageUrl: '$_covers/music-reel.jpg', cover: _g([const Color(0xFF141e30), const Color(0xFF243b55)])),
    ],
    instagram: '@samuel.edits',
    youtube: 'https://youtube.com/@samueledits',
    reviewNotes: 'Solid editing work across formats.',
    reviewedBy: 'Tobi',
    reviewedAt: '2025-02-05',
  ),
  Creator(
    id: '7',
    name: 'Esther Namuli',
    initials: 'EN',
    profilePhotoUrl: '$_profiles/esther.jpg',

    // New fields
    artistName: 'Esther N.',
    companyRole: CompanyRole.none,
    mainSkill: SkillEntry(
      discipline: 'Illustrator',
      specification: 'for Character Design',
      yearsOfExperience: 9,
    ),
    sideSkills: [
      SkillEntry(discipline: '2D Animator', specification: null, yearsOfExperience: 6),
      SkillEntry(discipline: 'Graphic Designer', specification: 'for Print', yearsOfExperience: 4),
    ],
    specialties: [Specialty.mediaForKids, Specialty.editorial, Specialty.comic, Specialty.art],
    software: ['Procreate', 'Adobe Illustrator', 'Adobe Animate', 'Clip Studio Paint'],
    services: 'Character design, editorial illustration, and 2D animation for books, publications, and media.',
    externalLinks: [],
    featuredVideoUrls: ['https://vimeo.com/example/showreel-brian'],
    clients: ['Storymoja', 'Nation Media', 'UNICEF Uganda'],

    // Deprecated fields
    primarySkill: 'Illustration',
    skills: ['Illustration', '2D Animation', 'Graphic Design (Print)'],
    level: 3,

    // Existing fields
    priceRange: PriceRange.premium,
    bio: 'Digital illustrator creating vibrant character art and editorial illustrations for publications.',
    location: 'Kampala',
    featured: true,
    email: 'esther@email.com',
    phone: '+256 700 789 012',
    whatsapp: '+256700789012',
    status: CreatorStatus.verified,
    portfolio: [
      PortfolioItem(id: '15', title: "Children's Book", skill: 'Illustration', url: 'https://behance.net/esther1', coverImageUrl: '$_covers/childrens-book.jpg', cover: _g([const Color(0xFFf953c6), const Color(0xFFb91d73)])),
      PortfolioItem(id: '16', title: 'Animated Short', skill: '2D Animation', url: 'https://vimeo.com/esther2', coverImageUrl: '$_covers/animated-short.jpg', cover: _g([const Color(0xFF6441A5), const Color(0xFF2a0845)])),
      PortfolioItem(id: '17', title: 'Magazine Covers', skill: 'Graphic Design (Print)', url: 'https://behance.net/esther3', coverImageUrl: '$_covers/magazine-cover.jpg', cover: _g([const Color(0xFFF4FF7A), const Color(0xFFf5af19)])),
    ],
    behance: 'https://behance.net/esther',
    instagram: '@esther.draws',
    website: 'https://esthernamuli.art',
    reviewNotes: 'Exceptional illustration talent.',
    reviewedBy: 'Tobi',
    reviewedAt: '2025-01-10',
  ),
  Creator(
    id: '8',
    name: 'Brian Kizza',
    initials: 'BK',
    profilePhotoUrl: '$_profiles/brian.jpg',

    // New fields
    artistName: null,
    companyRole: CompanyRole.none,
    mainSkill: SkillEntry(
      discipline: '3D Artist',
      specification: 'for Architecture',
      yearsOfExperience: 4,
    ),
    sideSkills: [
      SkillEntry(discipline: 'Motion Designer', specification: null, yearsOfExperience: 2),
    ],
    specialties: [Specialty.architecture, Specialty.advertising],
    software: ['Blender', 'Cinema 4D', 'Adobe After Effects'],
    services: 'Architectural visualization and product rendering for real estate and brands.',
    externalLinks: [],
    featuredVideoUrls: [],
    clients: [],

    // Deprecated fields
    primarySkill: '3D Animation',
    skills: ['3D Animation', 'Motion Design', 'Scenography'],
    level: 2,

    // Existing fields
    priceRange: PriceRange.mid,
    bio: '3D artist specializing in architectural visualization and product rendering for brands.',
    location: 'Mukono',
    email: 'brian@email.com',
    phone: '+256 700 890 123',
    status: CreatorStatus.rejected,
    portfolio: [
      PortfolioItem(id: '18', title: 'Arch Viz', skill: '3D Animation', url: 'https://artstation.com/brian1', coverImageUrl: '$_covers/arch-viz.jpg', cover: _g([const Color(0xFF4b6cb7), const Color(0xFF182848)])),
    ],
    instagram: '@brian.3d',
    reviewNotes: 'Portfolio needs more variety. Reapply with 3+ samples showing range.',
    reviewedBy: 'Tobi',
    reviewedAt: '2025-02-03',
    reapplyAfter: '2025-08-03',
  ),
  Creator(
    id: '9',
    name: 'Patricia Oroma',
    initials: 'PO',
    profilePhotoUrl: '$_profiles/patricia.jpg',

    // New fields
    artistName: null,
    companyRole: CompanyRole.founder,
    mainSkill: SkillEntry(
      discipline: 'Director',
      specification: null,
      yearsOfExperience: 11,
    ),
    sideSkills: [
      SkillEntry(discipline: 'Photographer', specification: 'for studio', yearsOfExperience: 8),
      SkillEntry(discipline: 'Graphic Designer', specification: 'for Branding', yearsOfExperience: 7),
    ],
    specialties: [Specialty.advertising, Specialty.fashion, Specialty.contentCreation, Specialty.filmTv],
    software: ['Adobe Photoshop', 'Adobe Illustrator', 'Adobe InDesign', 'Canon'],
    services: 'Full creative direction for campaigns, brand strategy, and photographic production.',
    externalLinks: [],
    featuredVideoUrls: [],
    clients: ['Tusker', 'Safaricom', 'UNICEF'],

    // Deprecated fields
    primarySkill: 'Art Direction',
    skills: ['Art Direction', 'Photography', 'Graphic Design (Digital)'],
    level: 3,

    // Existing fields
    priceRange: PriceRange.premium,
    bio: 'Art director with 8 years leading creative campaigns for international brands across East Africa.',
    location: 'Kampala',
    featured: true,
    companyName: 'Studio Oroma',
    email: 'patricia@email.com',
    phone: '+256 700 901 234',
    whatsapp: '+256700901234',
    status: CreatorStatus.verified,
    portfolio: [
      PortfolioItem(id: '19', title: 'Tusker Campaign', skill: 'Art Direction', url: 'https://behance.net/patricia1', coverImageUrl: '$_covers/tusker-campaign.jpg', cover: _g([const Color(0xFFcc2b5e), const Color(0xFF753a88)])),
      PortfolioItem(id: '20', title: 'Fashion Editorial', skill: 'Photography', url: 'https://behance.net/patricia2', coverImageUrl: '$_covers/fashion-editorial.jpg', cover: _g([const Color(0xFF2c3e50), const Color(0xFFbdc3c7)])),
      PortfolioItem(id: '21', title: 'Safaricom Rebrand', skill: 'Graphic Design (Digital)', url: 'https://behance.net/patricia3', coverImageUrl: '$_covers/safaricom-rebrand.jpg', cover: _g([const Color(0xFFde6262), const Color(0xFFffb88c)])),
    ],
    behance: 'https://behance.net/patricia',
    instagram: '@patricia.oroma',
    linkedin: 'https://linkedin.com/in/patriciaoroma',
    website: 'https://studiooroma.com',
    reviewNotes: 'Outstanding creative direction. Campaign work is world-class.',
    reviewedBy: 'Tobi',
    reviewedAt: '2025-01-18',
  ),
  Creator(
    id: '10',
    name: 'Ivan Mugisha',
    initials: 'IM',
    profilePhotoUrl: '$_profiles/ivan.jpg',

    // New fields
    artistName: null,
    companyRole: CompanyRole.none,
    mainSkill: SkillEntry(
      discipline: 'Writer',
      specification: 'for Screen',
      yearsOfExperience: 4,
    ),
    sideSkills: [
      SkillEntry(discipline: 'Film Producer', specification: null, yearsOfExperience: 2),
    ],
    specialties: [Specialty.filmTv, Specialty.advertising, Specialty.contentCreation],
    software: ['Final Draft', 'Adobe Audition'],
    services: 'Scriptwriting for film, TV, commercials, and radio. Available for freelance and contract work.',
    externalLinks: [],
    featuredVideoUrls: ['https://youtube.com/watch?v=example-joseph'],
    clients: [],

    // Deprecated fields
    primarySkill: 'Writing',
    skills: ['Writing', 'Producing'],
    level: 2,

    // Existing fields
    priceRange: PriceRange.budget,
    bio: 'Creative writer and script consultant for film, advertising, and branded content in Uganda.',
    location: 'Kampala',
    email: 'ivan@email.com',
    phone: '+256 700 012 345',
    status: CreatorStatus.pending,
    portfolio: [
      PortfolioItem(id: '22', title: 'TV Series Script', skill: 'Writing', url: 'https://docs.google.com/ivan1', coverImageUrl: '$_covers/tv-script.jpg', cover: _g([const Color(0xFF373B44), const Color(0xFF4286f4)])),
      PortfolioItem(id: '23', title: 'Radio Ad Campaign', skill: 'Writing', url: 'https://soundcloud.com/ivan2', coverImageUrl: '$_covers/radio-campaign.jpg', cover: _g([const Color(0xFF654ea3), const Color(0xFFeaafc8)])),
    ],
    linkedin: 'https://linkedin.com/in/ivanmugisha',
    reviewNotes: '',
    reviewedBy: '',
    reviewedAt: '',
  ),
];
