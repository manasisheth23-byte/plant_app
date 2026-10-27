import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'theme.dart';

/// Rounded white card matching the prototype.
Widget card(Widget child, {EdgeInsets? padding, Color? color}) => Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: padding ?? const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: C.line),
        boxShadow: [
          BoxShadow(color: const Color(0xFF12426E).withOpacity(.08), blurRadius: 10, offset: const Offset(0, 6)),
        ],
      ),
      child: child,
    );

Widget sectionTitle(String t, {Widget? trailing}) => Padding(
      padding: const EdgeInsets.fromLTRB(2, 16, 2, 8),
      child: Row(children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: C.amber, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 7),
        Text(t.toUpperCase(), style: sora(12, w: FontWeight.w700, c: C.deep).copyWith(letterSpacing: .5)),
        const Spacer(),
        if (trailing != null) trailing,
      ]),
    );

Widget pill(String text, String sev) {
  final bg = {
    'red': C.redp, 'amber': C.amberp, 'green': C.greenp, 'blue': C.bluep, 'slate': const Color(0xFFEAEEF3),
  }[sev] ?? const Color(0xFFEAEEF3);
  final fg = {'red': C.red, 'amber': const Color(0xFFB5710F), 'green': C.green, 'blue': C.blue, 'slate': C.slate}[sev] ?? C.slate;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
    child: Text(text, style: body(10.5, w: FontWeight.w600, c: fg)),
  );
}

Widget statusDot(Color c, {double size = 10}) =>
    Container(width: size, height: size, decoration: BoxDecoration(color: c, shape: BoxShape.circle));

/// KPI tile used on the dashboard.
/*Widget kpiTile(String label, String value, {String tone = ''}) {
  final bg = {'good': C.greenp, 'warn': C.amberp, 'bad': C.redp}[tone] ?? Colors.white;
  final vc = {'good': C.green, 'warn': const Color(0xFFB5710F), 'bad': C.red}[tone] ?? C.deep;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14), border: Border.all(color: C.line)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label.toUpperCase(), style: body(9.5, w: FontWeight.w600, c: C.mut).copyWith(letterSpacing: .4)),
      const SizedBox(height: 4),
      Text(value, style: mono(20, c: vc)),
    ]),
  );
}*/
Widget kpiTile(
    BuildContext context,
    String label,
    String value, {
      String tone = '',
    })
{
  final width = MediaQuery.of(context).size.width;

  final bool isMobile = width < 700;
  final bool isTablet = width >= 700 && width < 1100;
  final bool isDesktop = width >= 1100;

  final bg = {
    'good': C.greenp,
    'warn': C.amberp,
    'bad': C.redp,
  }[tone] ??
      Colors.white;

  final valueColor = {
    'good': C.green,
    'warn': const Color(0xFFB5710F),
    'bad': C.red,
  }[tone] ??
      C.deep;

  return Container(
    padding: EdgeInsets.symmetric(
      horizontal: isDesktop ? 10 : 12,
      vertical: isDesktop ? 8 : 11,
    ),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: C.line),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: body(
            isDesktop ? 8.5 : 9.5,
            w: FontWeight.w600,
            c: C.mut,
          ).copyWith(
            letterSpacing: .4,
          ),
        ),

        SizedBox(
          height: isDesktop ? 2 : 4,
        ),

        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            maxLines: 1,
            style: mono(
              isDesktop ? 16 : 20,
              c: valueColor,
            ),
          ),
        ),
      ],
    ),
  );
}
/// Horizontal labelled progress bar.
Widget barRow(String label, int v, {double labelWidth = 120}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        if (label.isNotEmpty) SizedBox(width: labelWidth, child: Text(label, style: body(12))),
        Expanded(
          child: Container(
            height: 9,
            decoration: BoxDecoration(color: const Color(0xFFE9EFF5), borderRadius: BorderRadius.circular(6)),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (v / 100).clamp(0, 1).toDouble(),
              child: Container(decoration: BoxDecoration(color: C.barColor(v), borderRadius: BorderRadius.circular(6))),
            ),
          ),
        ),
        SizedBox(width: 40, child: Text('$v%', textAlign: TextAlign.right, style: mono(11.5, c: C.slate))),
      ]),
    );

/// Thin fill bar (buffer / kettle fill) with an explicit colour.
Widget fillBar(num pct, Color color) => Container(
      height: 7,
      margin: const EdgeInsets.only(top: 5),
      decoration: BoxDecoration(color: const Color(0xFFE9EFF5), borderRadius: BorderRadius.circular(5)),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: (pct / 100).clamp(0, 1).toDouble(),
        child: Container(decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(5))),
      ),
    );

/// Green "benefit" / recommendation box (mirrors .esc).
Widget escBox(String html, {String sev = 'red'}) {
  final c = sev == 'amber' ? C.amber : (sev == 'green' ? C.green : C.red);
  final bg = sev == 'amber' ? C.amberp : (sev == 'green' ? C.greenp : C.redp);
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 6),
    padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
    decoration: BoxDecoration(
      color: bg, borderRadius: const BorderRadius.only(topRight: Radius.circular(9), bottomRight: Radius.circular(9)),
      border: Border(left: BorderSide(color: c, width: 3)),
    ),
    child: Text(html, style: body(12.5, c: C.ink)),
  );
}

/// CCR load gauge (donut).
class GaugePainter extends CustomPainter {
  final double pct;
  final Color color;
  GaugePainter(this.pct, this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.width / 2 - 7;
    final bg = Paint()
      ..color = const Color(0xFFE9EFF5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round;
    final fg = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round;
    final rect = Rect.fromCircle(center: center, radius: r);
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi, false, bg);
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * pct / 100, false, fg);
  }

  @override
  bool shouldRepaint(covariant GaugePainter old) => old.pct != pct || old.color != color;
}

Widget gauge(int pct, Color color, {double size = 118}) => SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: GaugePainter(pct.toDouble(), color),
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('$pct%', style: mono(27, c: C.deep)),
            Text('CCR LOAD', style: body(9.5, w: FontWeight.w600, c: C.mut)),
          ]),
        ),
      ),
    );

/// A simple sparkline.
class Sparkline extends StatelessWidget {
  final List<num> values;
  final Color color;
  const Sparkline(this.values, this.color, {super.key});
  @override
  Widget build(BuildContext context) =>
      SizedBox(height: 38, width: 130, child: CustomPaint(painter: _SparkPainter(values, color)));
}

class _SparkPainter extends CustomPainter {
  final List<num> v;
  final Color color;
  _SparkPainter(this.v, this.color);
  @override
  void paint(Canvas canvas, Size size) {
    if (v.isEmpty) return;
    final mn = v.reduce(math.min).toDouble(), mx = v.reduce(math.max).toDouble();
    final sp = (mx - mn) == 0 ? 1 : (mx - mn);
    final path = Path();
    for (var i = 0; i < v.length; i++) {
      final x = i * (size.width / (v.length - 1));
      final y = size.height - 2 - ((v[i] - mn) / sp) * (size.height - 6);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    canvas.drawPath(path, Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2.2..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);
  }

  @override
  bool shouldRepaint(covariant _SparkPainter old) => false;
}

/// Vertical bar mini-chart.
class VBars extends StatelessWidget {
  final List<num> values;
  final Color color;
  const VBars(this.values, this.color, {super.key});
  @override
  Widget build(BuildContext context) {
    final mx = values.isEmpty ? 1 : values.reduce(math.max);
    return SizedBox(
      height: 62,
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        for (final x in values)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Container(
                height: 60 * (x / mx).clamp(0.04, 1).toDouble(),
                decoration: BoxDecoration(color: color, borderRadius: const BorderRadius.vertical(top: Radius.circular(3))),
              ),
            ),
          ),
      ]),
    );
  }
}

/// Pushes a detail page with a back-arrow app bar (drill-down pattern).
void pushPage(BuildContext context, String title, String subtitle, Widget body) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => DetailScaffold(title: title, subtitle: subtitle, child: body),
  ));
}

class DetailScaffold extends StatelessWidget {
  final String title, subtitle;
  final Widget child;
  const DetailScaffold({super.key, required this.title, required this.subtitle, required this.child});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: C.deep,
          foregroundColor: Colors.white,
          elevation: 0,
          title: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text(title, style: sora(16, c: Colors.white)),
            if (subtitle.isNotEmpty) Text(subtitle, style: body(11, c: const Color(0xFF9DB8D4))),
          ]),
        ),
        body: SafeArea(child: ListView(padding: const EdgeInsets.all(14), children: [child])),
      );
}

/// A lightweight toast/snackbar.
void toast(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg, style: body(12.5, w: FontWeight.w600, c: Colors.white)),
    backgroundColor: C.deep,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    duration: const Duration(milliseconds: 2200),
  ));
}
