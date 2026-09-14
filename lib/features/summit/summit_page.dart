import 'package:adp_mobile/core/design/adp_theme.dart';
import 'package:flutter/material.dart';

class SummitPage extends StatefulWidget {
  const SummitPage({super.key});

  @override
  State<SummitPage> createState() => _SummitPageState();
}

class _SummitPageState extends State<SummitPage> {
  bool _isRegistered = false;
  String? _selectedPollOptionId = 'poll_2';

  final List<Map<String, dynamic>> _pollOptions = [
    {'id': 'poll_1', 'label': 'Économie Circulaire & Tourisme Durable', 'votes': 48},
    {'id': 'poll_2', 'label': 'Hub Tech, IA & Digitalisation de l\'Île', 'votes': 114},
    {'id': 'poll_3', 'label': 'Préservation du Patrimoine & Architecture', 'votes': 72},
    {'id': 'poll_4', 'label': 'Fonds d\'Amorçage pour Entreprises Diaspora', 'votes': 89},
  ];

  final List<Map<String, String>> _tracks = const [
    {
      'time': '10:00 - 11:30',
      'title': 'Investir à Djerba : Incitations & Guichet Unique',
      'speaker': 'Sonia Trabelsi (DG FIPA) & Karim Ben Amor',
    },
    {
      'time': '14:00 - 15:45',
      'title': 'Transition Écologique & Traitement des Eaux',
      'speaker': 'Dr. Mehdi Fakhfakh & Équipe ADP Eau',
    },
    {
      'time': '16:15 - 18:00',
      'title': 'La Diaspora comme Vecteur d\'Influence Mondial',
      'speaker': 'Panel d\'Ambassadeurs & Membres d\'Honneur',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final totalVotes = _pollOptions.fold<int>(0, (sum, item) => sum + (item['votes'] as int));

    return Scaffold(
      backgroundColor: AdpColors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const AdpStudioBackButton(),
        title: const Text('Sommet Diaspora 2026'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        children: [
          // Summit Hero
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [Color(0xFF0E2129), Color(0xFF1B3D4F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0E2129).withValues(alpha: 0.3),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'ÉDITION MONDIALE 2026',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Rencontre Internationale des Talents & Investisseurs',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: const [
                    Icon(Icons.calendar_today_rounded, size: 14, color: AdpColors.sandGold),
                    SizedBox(width: 6),
                    Text(
                      '24 - 26 Octobre 2026 · Houmt Souk',
                      style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(width: 4),
                const SizedBox(height: 6),
                Row(
                  children: const [
                    Icon(Icons.people_outline_rounded, size: 14, color: AdpColors.sandGold),
                    SizedBox(width: 6),
                    Text(
                      'Programme international · Inscriptions ouvertes',
                      style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isRegistered ? const Color(0xFF10B981) : Colors.white,
                      foregroundColor: _isRegistered ? Colors.white : AdpColors.ink,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    icon: Icon(
                      _isRegistered ? Icons.check_circle_rounded : Icons.confirmation_number_outlined,
                      size: 18,
                    ),
                    label: Text(
                      _isRegistered ? 'Vous participez au Sommet (Inscrit)' : 'Confirmer ma présence',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                    onPressed: () {
                      setState(() => _isRegistered = !_isRegistered);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            _isRegistered
                                ? 'Inscription confirmée ! Votre badge a été envoyé par email.'
                                : 'Inscription annulée.',
                          ),
                          backgroundColor: _isRegistered ? const Color(0xFF10B981) : AdpColors.navy,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Live Poll Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sondage des Adhérents',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AdpColors.ink,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AdpColors.ocean.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'EN DIRECT',
                  style: TextStyle(
                    color: AdpColors.ocean,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AdpColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quelle thématique prioritaire souhaitez-vous voir traitée en séance plénière ?',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AdpColors.ink,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 14),
                ..._pollOptions.map((opt) {
                  final optId = opt['id'] as String;
                  final votes = opt['votes'] as int;
                  final isSelected = _selectedPollOptionId == optId;
                  final pct = ((votes / totalVotes) * 100).toInt();

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_selectedPollOptionId != optId) {
                          opt['votes'] = votes + 1;
                          _selectedPollOptionId = optId;
                        }
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Vote pris en compte !'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: AdpColors.navy,
                          duration: const Duration(seconds: 1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? AdpColors.ocean.withValues(alpha: 0.06) : const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? AdpColors.ocean : AdpColors.border,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  opt['label'] as String,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                    color: isSelected ? AdpColors.ocean : AdpColors.ink,
                                  ),
                                ),
                              ),
                              Text(
                                '$pct%',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: AdpColors.ocean,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: pct / 100,
                              minHeight: 5,
                              backgroundColor: const Color(0xFFE2E8F0),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isSelected ? AdpColors.ocean : AdpColors.muted.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Roundtable Tracks
          const Text(
            'Tables Rondes & Ateliers',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AdpColors.ink,
            ),
          ),
          const SizedBox(height: 12),
          ..._tracks.map((t) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AdpColors.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(Icons.mic_none_rounded, color: AdpColors.ocean, size: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t['time']!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AdpColors.terracotta,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            t['title']!,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: AdpColors.ink,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Avec ${t['speaker']!}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AdpColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
