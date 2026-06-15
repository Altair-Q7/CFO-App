# The Scalable CFO — Complete UI Overhaul
> Written by Claude. Execute with DeepSeek.
> Read every section before writing a single line of code.
> This is a visual and interaction overhaul. Architecture is not changing.

---

## Vision in one sentence

The app should feel like entering MADI's Financial Operations Center — not opening a dashboard.

---

## MADI Identity (non-negotiable)

MADI is a Financial Operations Intelligence System. Not a chatbot.

Tone: Analytical. Direct. Professional.
Every MADI sentence contains a number or a decision.
MADI never greets. MADI never motivates. MADI reports.

MADI presence on every screen:
- Small indicator: "MADI · Last reviewed 2h ago" with a gold pulsing dot
- Not a floating button. Not a chat bubble. A status line.

---

## Color System (replace everything currently in AppTheme)

```dart
// lib/core/constants/app_constants.dart
// Replace the entire color section with:

// === DARK SURFACES ===
static const Color darkBase = Color(0xFF0A0F1E);       // page bg dark mode
static const Color darkSurface = Color(0xFF111827);    // card bg dark mode
static const Color darkElevated = Color(0xFF1F2937);   // elevated card dark
static const Color darkBorder = Color(0xFF374151);     // borders dark mode

// === LIGHT SURFACES ===
static const Color lightBase = Color(0xFFF8FAFC);      // page bg light mode
static const Color lightSurface = Color(0xFFFFFFFF);   // card bg light mode
static const Color lightElevated = Color(0xFFF1F5F9);  // elevated card light
static const Color lightBorder = Color(0xFFE2E8F0);    // borders light mode

// === NAVY (brand) ===
static const Color navyDeep = Color(0xFF0B1F3A);
static const Color navyMid = Color(0xFF1A3A5C);
static const Color navyLight = Color(0xFF234E7A);

// === SEMANTIC ===
static const Color emerald = Color(0xFF10B981);        // healthy, growth, positive
static const Color amber = Color(0xFFF59E0B);          // warning, watch
static const Color coral = Color(0xFFEF4444);          // critical, danger
static const Color gold = Color(0xFFD4AF37);           // MADI accent, premium

// === TEXT ===
static const Color textPrimary = Color(0xFF0F172A);
static const Color textSecondary = Color(0xFF64748B);
static const Color textMuted = Color(0xFF94A3B8);
static const Color textOnDark = Color(0xFFF8FAFC);
static const Color textOnDarkMuted = Color(0xFF94A3B8);

// === GRADIENTS ===
static const LinearGradient navyGradient = LinearGradient(
  colors: [Color(0xFF0B1F3A), Color(0xFF1A3A5C)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
static const LinearGradient madiBriefingGradient = LinearGradient(
  colors: [Color(0xFF0B1F3A), Color(0xFF0D2B4E), Color(0xFF1A3A5C)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
```

---

## Typography System

```dart
// Use these TextStyle definitions consistently everywhere

// Section labels (uppercase, spaced)
static const TextStyle labelStyle = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w600,
  letterSpacing: 1.2,
  color: Color(0xFF64748B),
);

// Metric values (large, bold)
static const TextStyle metricLarge = TextStyle(
  fontSize: 32,
  fontWeight: FontWeight.w700,
  letterSpacing: -1.0,
  color: Color(0xFF0F172A),
);

static const TextStyle metricMedium = TextStyle(
  fontSize: 22,
  fontWeight: FontWeight.w700,
  letterSpacing: -0.5,
  color: Color(0xFF0F172A),
);

// MADI briefing text
static const TextStyle madiBriefingText = TextStyle(
  fontSize: 15,
  fontWeight: FontWeight.w500,
  height: 1.7,
  color: Color(0xFFF8FAFC),
);

// Body
static const TextStyle bodyText = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w400,
  height: 1.5,
  color: Color(0xFF64748B),
);
```

---

## Card System

Two card types used throughout the app:

```dart
// Standard card
BoxDecoration standardCard = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(16),
  border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ],
);

// Dark card (for MADI, headers, command sections)
BoxDecoration darkCard = BoxDecoration(
  gradient: AppConstants.navyGradient,
  borderRadius: BorderRadius.circular(16),
  border: Border.all(
    color: Colors.white.withValues(alpha: 0.08),
    width: 1,
  ),
);
```

---

## MADI Presence Widget (global, used on every screen)

Create `lib/widgets/madi_presence_indicator.dart`:

```dart
import 'package:flutter/material.dart';

// Small indicator shown at top of every screen's AppBar or below AppBar
// Shows MADI is actively monitoring
class MadiPresenceIndicator extends StatefulWidget {
  final String lastReviewed;
  final bool isActive;

  const MadiPresenceIndicator({
    super.key,
    this.lastReviewed = '2h ago',
    this.isActive = true,
  });

  @override
  State<MadiPresenceIndicator> createState() => _MadiPresenceIndicatorState();
}

class _MadiPresenceIndicatorState extends State<MadiPresenceIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFD4AF37).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _pulse,
            builder: (_, __) => Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD4AF37)
                    .withValues(alpha: _pulse.value),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'MADI · ${widget.lastReviewed}',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFFD4AF37),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## Screen 1 — Login Screen

**File:** `lib/screens/auth/login_screen.dart`

Full replacement. This is the first impression.

```dart
// Structure:
// - Full dark navy background (navyDeep)
// - Top 40%: MADI branding section
// - Bottom 60%: login form on slightly elevated dark surface

// Top section contains:
// - Small gold dot (animated pulse, same as MadiPresenceIndicator)
// - "MADI" in large gold text, 36px, w700, letter-spacing 2.0
// - "Financial Operations Center" in white muted, 13px
// - Divider line
// - "The Scalable CFO" in white, 18px, w500

// Quick demo login section (3 role cards):
// Each card: dark elevated surface, left border accent color by role
// Founder: emerald left border
// Advisor: amber left border  
// Admin: gold left border
// Each shows: role name (white, bold) + person name + company (muted)
// Right side: "Enter →" in muted white

// Manual login form:
// Dark elevated card
// Email + password fields with dark styling
// Input decoration: dark fill, white text, muted border
// Sign In button: full width, navyMid bg, white text — NOT colored button

// Input field dark style:
InputDecoration darkInputDecoration(String label, IconData icon) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
    prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
    filled: true,
    fillColor: const Color(0xFF1F2937),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF374151)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF374151)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
    ),
  );
}
```

---

## Screen 2 — Founder Dashboard

**File:** `lib/screens/dashboard/founder_dashboard_screen.dart`

Full replacement. This is the hero screen.

### AppBar
```dart
AppBar(
  backgroundColor: Colors.white,
  elevation: 0,
  scrolledUnderElevation: 1,
  title: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'TechFlow Inc.',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0F172A),
        ),
      ),
      Text(
        'Founder · Financial Operations',
        style: TextStyle(
          fontSize: 11,
          color: const Color(0xFF64748B),
        ),
      ),
    ],
  ),
  actions: [
    const MadiPresenceIndicator(),
    const SizedBox(width: 8),
    // Notification bell with badge
    Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pushNamed(context, '/notifications'),
        ),
        Positioned(
          right: 8, top: 8,
          child: Container(
            width: 8, height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFFEF4444),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    ),
    IconButton(
      icon: const Icon(Icons.logout_rounded, color: Color(0xFF64748B), size: 20),
      onPressed: () async {
        await ref.read(authProvider.notifier).logout();
        if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
      },
    ),
  ],
)
```

### Dashboard body — exact section order

```dart
ListView(
  padding: EdgeInsets.zero,
  children: [
    _buildMadiBriefing(),        // Section 1: MADI (dark, full width)
    _buildRunwayHero(),          // Section 2: Runway (largest metric)
    _buildMetricsGrid(),         // Section 3: 2x2 supporting metrics
    _buildQuickActions(),        // Section 4: action chips
    _buildTrendChart(),          // Section 5: interactive chart
    _buildRecentTransactions(),  // Section 6: last 5 transactions
    const SizedBox(height: 100),
  ],
)
```

### Section 1 — MADI Briefing (upgraded)

```dart
Widget _buildMadiBriefing() {
  final data = MockDataService().getMadiBriefing();
  final sentences = data['sentences'] as List<String>;
  final status = data['healthStatus'] as String;
  final risk = data['primaryRisk'] as String;
  final action = data['recommendedAction'] as String;
  final route = data['actionRoute'] as String;

  final statusColor = switch (status) {
    'healthy' => const Color(0xFF10B981),
    'critical' => const Color(0xFFEF4444),
    _ => const Color(0xFFF59E0B),
  };

  return Container(
    margin: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF0B1F3A), Color(0xFF0D2B4E), Color(0xFF1A3A5C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.08),
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF0B1F3A).withValues(alpha: 0.3),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
          child: Row(
            children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text('M', style: TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  )),
                ),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('MADI', style: TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  )),
                  Text('Financial Briefing', style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                  )),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Divider
        Container(
          margin: const EdgeInsets.fromLTRB(20, 14, 20, 14),
          height: 1,
          color: Colors.white.withValues(alpha: 0.08),
        ),

        // Briefing sentences
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: sentences.asMap().entries.map((entry) {
              final i = entry.key;
              final sentence = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 7),
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == 0
                            ? const Color(0xFFD4AF37)
                            : Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(sentence, style: TextStyle(
                        fontSize: 14,
                        fontWeight: i == 0 ? FontWeight.w600 : FontWeight.w400,
                        height: 1.6,
                        color: i == 0
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.75),
                      )),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),

        // Action footer
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, route),
          child: Container(
            margin: const EdgeInsets.fromLTRB(20, 8, 20, 18),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.arrow_right_alt_rounded,
                    color: statusColor, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(action, style: TextStyle(
                    color: statusColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  )),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: Colors.white.withValues(alpha: 0.4), size: 18),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
```

### Section 2 — Runway Hero

```dart
Widget _buildRunwayHero() {
  return Container(
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE2E8F0)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('RUNWAY', style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: Color(0xFF64748B),
              )),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('11', style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -2,
                    color: Color(0xFF0F172A),
                    height: 1.0,
                  )),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8, left: 6),
                    child: Text('months', style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    )),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Runway bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: 11 / 24, // 11 months out of 24 benchmark
                  backgroundColor: const Color(0xFFE2E8F0),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFF59E0B), // amber = watch status
                  ),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 6),
              const Text('Below 12-month benchmark',
                style: TextStyle(fontSize: 12, color: Color(0xFFF59E0B))),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _runwayStat('Burn Rate', '₹95K/mo', const Color(0xFFEF4444)),
            const SizedBox(height: 12),
            _runwayStat('Cash', '₹12.4L', const Color(0xFF10B981)),
            const SizedBox(height: 12),
            _runwayStat('Profit', '₹60K/mo', const Color(0xFF10B981)),
          ],
        ),
      ],
    ),
  );
}

Widget _runwayStat(String label, String value, Color color) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Text(label, style: const TextStyle(
        fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500,
      )),
      const SizedBox(height: 2),
      Text(value, style: TextStyle(
        fontSize: 16, fontWeight: FontWeight.w700, color: color,
      )),
    ],
  );
}
```

### Section 3 — Metrics Grid (2x2)

```dart
Widget _buildMetricsGrid() {
  final metrics = [
    {
      'label': 'REVENUE',
      'value': '₹1.85L',
      'change': '+12.5%',
      'positive': true,
      'icon': Icons.trending_up_rounded,
      'color': const Color(0xFF10B981),
    },
    {
      'label': 'EXPENSES',
      'value': '₹1.25L',
      'change': '+3.2%',
      'positive': false,
      'icon': Icons.trending_down_rounded,
      'color': const Color(0xFFEF4444),
    },
    {
      'label': 'NET PROFIT',
      'value': '₹60K',
      'change': '+8.1%',
      'positive': true,
      'icon': Icons.account_balance_outlined,
      'color': const Color(0xFF10B981),
    },
    {
      'label': 'EMPLOYEES',
      'value': '28',
      'change': '+2 this mo',
      'positive': true,
      'icon': Icons.people_outline_rounded,
      'color': const Color(0xFF6366F1),
    },
  ];

  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
    child: GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.4,
      children: metrics.map((m) => _buildMetricCard(m)).toList(),
    ),
  );
}

Widget _buildMetricCard(Map<String, dynamic> m) {
  final color = m['color'] as Color;
  final positive = m['positive'] as bool;

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE2E8F0)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(m['label'] as String, style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
              color: Color(0xFF94A3B8),
            )),
            Icon(m['icon'] as IconData, size: 16, color: color),
          ],
        ),
        Text(m['value'] as String, style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: Color(0xFF0F172A),
        )),
        Row(
          children: [
            Icon(
              positive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
              size: 11,
              color: color,
            ),
            const SizedBox(width: 3),
            Text(m['change'] as String, style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            )),
          ],
        ),
      ],
    ),
  );
}
```

### Section 4 — Quick Actions

```dart
Widget _buildQuickActions() {
  final actions = [
    {'label': 'Forecast', 'icon': Icons.trending_up_rounded, 'route': '/forecast'},
    {'label': 'Reports', 'icon': Icons.receipt_long_rounded, 'route': '/reports'},
    {'label': 'Advisors', 'icon': Icons.people_rounded, 'route': '/marketplace'},
    {'label': 'Fundraise', 'icon': Icons.rocket_launch_rounded, 'route': '/fundraising'},
  ];

  return Container(
    height: 80,
    margin: const EdgeInsets.fromLTRB(16, 0, 0, 12),
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: actions.length,
      separatorBuilder: (_, __) => const SizedBox(width: 10),
      itemBuilder: (_, i) {
        final a = actions[i];
        return GestureDetector(
          onTap: () => Navigator.pushNamed(context, a['route'] as String),
          child: Container(
            width: 90,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(a['icon'] as IconData,
                    size: 22, color: const Color(0xFF0B1F3A)),
                const SizedBox(height: 6),
                Text(a['label'] as String, style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                )),
              ],
            ),
          ),
        );
      },
    ),
  );
}
```

### Section 5 — Interactive Trend Chart

```dart
// Use fl_chart (already in pubspec from previous session)
// Show last 6 months revenue vs expenses line chart

Widget _buildTrendChart() {
  return Container(
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE2E8F0)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('TREND', style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: Color(0xFF64748B),
            )),
            // Legend
            Row(children: [
              _legendDot(const Color(0xFF10B981), 'Revenue'),
              const SizedBox(width: 12),
              _legendDot(const Color(0xFFEF4444), 'Expenses'),
            ]),
          ],
        ),
        const SizedBox(height: 16),
        // MADI tap interaction — show this Container above the chart
        // When user taps a point on chart, update _selectedMonth state
        // and show MADI's comment for that month
        if (_selectedMonth != null)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF0B1F3A).withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Text('M', style: TextStyle(
                  color: Color(0xFFD4AF37),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                )),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getMadiChartComment(_selectedMonth!),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        SizedBox(
          height: 160,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 50000,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: const Color(0xFFE2E8F0),
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                      final i = value.toInt();
                      if (i < 0 || i >= months.length) return const SizedBox();
                      return Text(months[i], style: const TextStyle(
                        fontSize: 10, color: Color(0xFF94A3B8),
                      ));
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineTouchData: LineTouchData(
                touchCallback: (event, response) {
                  if (event is FlTapUpEvent && response?.lineBarSpots != null) {
                    setState(() {
                      _selectedMonth = response!.lineBarSpots![0].x.toInt();
                    });
                  }
                },
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (spots) => spots.map((s) => LineTooltipItem(
                    '₹${(s.y / 1000).toStringAsFixed(0)}K',
                    TextStyle(
                      color: s.bar.color,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  )).toList(),
                ),
              ),
              lineBarsData: [
                // Revenue line
                LineChartBarData(
                  spots: const [
                    FlSpot(0, 120000), FlSpot(1, 135000), FlSpot(2, 148000),
                    FlSpot(3, 162000), FlSpot(4, 174000), FlSpot(5, 185000),
                  ],
                  isCurved: true,
                  color: const Color(0xFF10B981),
                  barWidth: 2.5,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                      radius: 4,
                      color: Colors.white,
                      strokeWidth: 2,
                      strokeColor: const Color(0xFF10B981),
                    ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: const Color(0xFF10B981).withValues(alpha: 0.06),
                  ),
                ),
                // Expenses line
                LineChartBarData(
                  spots: const [
                    FlSpot(0, 85000), FlSpot(1, 92000), FlSpot(2, 98000),
                    FlSpot(3, 105000), FlSpot(4, 118000), FlSpot(5, 125000),
                  ],
                  isCurved: true,
                  color: const Color(0xFFEF4444),
                  barWidth: 2.5,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                      radius: 4,
                      color: Colors.white,
                      strokeWidth: 2,
                      strokeColor: const Color(0xFFEF4444),
                    ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: const Color(0xFFEF4444).withValues(alpha: 0.04),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _legendDot(Color color, String label) {
  return Row(children: [
    Container(
      width: 8, height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    ),
    const SizedBox(width: 4),
    Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
  ]);
}

// Add to state:
int? _selectedMonth;

// MADI chart comments — analytical, no filler
String _getMadiChartComment(int month) {
  const comments = [
    'January: Revenue at ₹1.2L. Expenses at ₹85K. Margin: 29%.',
    'February: Revenue grew 12.5%. Expense growth outpaced at 8%.',
    'March: First month expenses exceeded ₹95K. Payroll expanded.',
    'April: Revenue gap widening. Margin improved to 35%.',
    'May: Burn rate acceleration. Payroll added 2 headcount.',
    'June: Revenue ₹1.85L. Burn ₹1.25L. Net: ₹60K. Runway: 11 months.',
  ];
  return comments[month.clamp(0, 5)];
}
```

---

## Screen 3 — Admin Dashboard

**File:** `lib/screens/dashboard/admin_dashboard_screen.dart`

### AppBar
Dark navy AppBar — this is a command center, not a consumer app.

```dart
AppBar(
  backgroundColor: const Color(0xFF0B1F3A),
  elevation: 0,
  title: const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Operations Center', style: TextStyle(
        color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700,
      )),
      Text('The Scalable CFO · Admin', style: TextStyle(
        color: Color(0xFF64748B), fontSize: 11,
      )),
    ],
  ),
  actions: [
    const MadiPresenceIndicator(),
    const SizedBox(width: 12),
  ],
)
```

### Body sections in order:

1. **Platform Revenue header** — large MRR number on dark surface
2. **4 KPI cards** — Founders, Advisors, Bookings this month, Uptime
3. **Revenue breakdown** — SaaS MRR vs Marketplace GMV vs Enterprise (3 horizontal bars)
4. **Advisor pipeline** — list with status badges
5. **Platform alerts** — warning/info/success items
6. **Recent signups** — last 5 with role badge

```dart
// Platform revenue header (dark card)
Widget _buildRevenueHeader(Map<String, dynamic> data) {
  return Container(
    margin: const EdgeInsets.all(16),
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF0B1F3A), Color(0xFF1A3A5C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('PLATFORM REVENUE', style: TextStyle(
          fontSize: 11, fontWeight: FontWeight.w600,
          letterSpacing: 1.2, color: Color(0xFF94A3B8),
        )),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₹${(data['platformRevenue'] as num / 100000).toStringAsFixed(1)}L',
              style: const TextStyle(
                fontSize: 40, fontWeight: FontWeight.w800,
                color: Colors.white, letterSpacing: -1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '+${data['platformRevenueChange']}%',
                  style: const TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 12, fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text('Monthly Recurring Revenue', style: TextStyle(
          fontSize: 12, color: Color(0xFF64748B),
        )),
      ],
    ),
  );
}
```

---

## Screen 4 — Login Screen (dark, full replacement)

Structure the login screen as follows:

```
Full screen dark background: Color(0xFF0A0F1E)

Top half:
- Centered MADI logo block
  - 60x60 rounded square, navyMid bg, "M" in gold 28px w800
  - "MADI" text below, gold, 28px, w700, letter-spacing 3.0
  - "Financial Operations Center" below, textMuted, 13px
  - "by The Scalable CFO" below, textMuted, 11px

Bottom half (scrollable):
- "DEMO ACCESS" label (uppercase, spaced, gold)
- 3 role cards (dark elevated surface)
  - Founder card: left border emerald
  - Advisor card: left border amber
  - Admin card: left border gold
- Divider with "or continue with credentials"
- Email + password fields (dark styling)
- Sign In button (navyMid, white text, no bright colors)
- "Powered by MADI Intelligence" footer in textMuted
```

---

## What DeepSeek must NOT do

- Do not use `withOpacity()` — use `withValues(alpha: x)` everywhere
- Do not add new packages to pubspec.yaml (fl_chart already installed)
- Do not modify providers.dart
- Do not modify any service files except mock_data_service.dart
- Do not use emoji in financial data displays
- Do not center-align metric values — always left-align
- Do not use bright colored backgrounds on metric cards — white only
- Do not add motivational copy anywhere — MADI is analytical only
- Do not stack more than one BoxShadow per card

---

## Execution order

1. Create `lib/widgets/madi_presence_indicator.dart` (new file)
2. Update color constants in `lib/core/constants/app_constants.dart`
3. Replace `lib/screens/auth/login_screen.dart`
4. Replace `lib/screens/dashboard/founder_dashboard_screen.dart`
5. Replace `lib/screens/dashboard/admin_dashboard_screen.dart`
6. Run `flutter analyze` — fix any errors before reporting done
7. Run `flutter run -d linux` — confirm no crashes

Report after step 7 only. Show me what you see on screen.

---

## Verification checklist

- [ ] Login screen is dark navy, not white or gradient-light
- [ ] MADI logo block visible on login with gold "M"
- [ ] Role cards have colored left borders (not colored backgrounds)
- [ ] Founder dashboard opens to MADI briefing card (dark navy gradient)
- [ ] Runway shows as large number (48px) with progress bar
- [ ] Metrics grid is 2x2, white cards, no colored backgrounds
- [ ] Tapping chart shows MADI comment above chart
- [ ] Admin dashboard AppBar is dark navy
- [ ] Platform revenue shows large number on dark card
- [ ] MadiPresenceIndicator visible in AppBar of founder + admin screens
- [ ] Gold pulsing dot animates on MadiPresenceIndicator
- [ ] No withOpacity() calls anywhere in new code
- [ ] flutter analyze reports zero errors
