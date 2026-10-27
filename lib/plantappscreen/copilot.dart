import 'dart:convert';

import 'package:erpflutter/plantappscreen/data.dart';
import 'package:erpflutter/plantappscreen/theme.dart';
import 'package:erpflutter/plantappscreen/widgets.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


/// ---------------------------------------------------------------------------
/// Copilot service.
///
/// BACKEND TEAM: the app must NEVER embed the Anthropic API key. It calls YOUR
/// backend, which proxies to the Anthropic Messages API with a system prompt that
/// injects the plant state + role. Contract:
///     POST {backendBase}/copilot/ask   { "role": ..., "question": ... }
///                                    -> { "text": "..." }
/// If the backend is unreachable, we fall back to the on-device TOC engine
/// (answerLocal) so the prototype always works — exactly like the HTML version.
/// ---------------------------------------------------------------------------
class CopilotService {
  static const String backendBase = 'https://your-backend.example.com';
  static const bool preferLive = true;

  static Future<({String text, bool live})> ask(String role, String question) async {
    if (preferLive) {
      try {
        final res = await http
            .post(Uri.parse('$backendBase/copilot/ask'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({'role': role, 'question': question}))
            .timeout(const Duration(seconds: 14));
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body) as Map<String, dynamic>;
          final t = (data['text'] ?? '').toString();
          if (t.trim().isNotEmpty) return (text: t, live: true);
        }
      } catch (_) {/* fall through to local engine */}
    }
    return (text: answerLocal(question, role), live: false);
  }
}

/// Proactive, role-aware briefing (ported from the prototype).
String buildBriefing(String role) {
  final p = plant;
  String exec;
  if (role == 'Managing Director') {
    exec = 'Plant tracking **${p.mtToday}/${p.mtTarget} MT**, OTIF **${p.otif}%**. **3 items need a decision** — below.';
  } else if (role == 'Shop-floor Supervisor') {
    exec = 'Galvanizing is the pace-setter at **${p.galvLoad}%**. Keep the kettle fed. One order to expedite, one machine down.';
  } else if (role == 'Operations Head') {
    exec = 'Throughput **${p.mtToday}/${p.mtTarget} MT**, drum at **${p.galvLoad}%**. Subordinate everything to galvanizing.';
  } else {
    exec = 'Full briefing. **${p.mtToday}/${p.mtTarget} MT** today, drum at **${p.galvLoad}%**, **${p.redOrders} orders red**.';
  }
  final b = StringBuffer();
  b.writeln('### Good morning · $role');
  b.writeln(exec);
  b.writeln();
  b.writeln('### Current state');
  b.writeln('• Drum: **${p.drum}** at [[amber:${p.galvLoad}% load]]');
  b.writeln('• Output: **${p.mtToday} / ${p.mtTarget} MT** · WIP **${p.wipMT} MT**');
  b.writeln();
  b.writeln('### Yesterday');
  b.writeln('• **${p.yMtActual}/${p.yMtPlan} MT** · OEE ${p.yOee}% · OTIF [[green:${p.yOtif}%]] · Scrap [[amber:${p.yScrap}%]]');
  b.writeln('• Top downtime: ${p.yTopDowntime}');
  b.writeln();
  b.writeln('### Today\u2019s schedule');
  b.writeln('• **${p.ccrBatchesTotal} galv batches** · target **${p.mtTarget} MT**');
  b.writeln('• Focus: **${p.todayFocus}**');
  b.writeln('• ${p.todayInspection} · ${p.todayDispatch}');
  b.writeln();
  b.writeln('### Today\u2019s bottlenecks');
  b.writeln('• [[amber:WATCH]] Galvanizing at 96% — protect the drum');
  b.writeln('• [[red:RISK]] CNC-124T2 — 78% failure risk in 36 h');
  b.writeln('• [[red:RISK]] ISA 90×90×6 buffer 18% — feeds the drum');
  b.writeln();
  b.writeln('### Tomorrow');
  b.writeln('• ${p.tomPm}');
  b.writeln('• ${p.tomInspection} · Dispatch ${p.tomDispatch}');
  b.writeln('• [[amber:Heads-up]] ${p.tomNote}');
  b.writeln();
  b.writeln('### Shop-floor utilisation');
  for (final f in p.feeders) {
    b.writeln('[[bar:${f[1]}:${f[0]}]]');
  }
  b.writeln('[[bar:96:Galvanizing (drum)]]');
  b.writeln();
  b.writeln('### Resources to monitor / escalate');
  for (final a in p.alerts.where((a) => a.status == 'open' && a.sev != 'blue')) {
    final sv = a.sev == 'red' ? 'red' : 'amber';
    b.writeln('[[esc:$sv:${a.title}::${a.detail}::${a.action}]]');
  }
  return b.toString().trim();
}

/// On-device TOC reasoning engine (fallback) — ported from the prototype.
String answerLocal(String qRaw, String role) {
  final q = qRaw.toLowerCase();
  bool has(List<String> w) => w.any((x) => q.contains(x));
  if (has(['brief', 'update', 'status', 'overview', 'focus', 'summary', 'what should'])) {
    return buildBriefing(role);
  }
  if (has(['bottleneck', 'drum', 'galvaniz', 'constraint', 'ccr', 'kettle'])) {
    return '### The drum — galvanizing\nGL-1 is your CCR at [[amber:96% load]]. Everything subordinates to it.\n'
        '• Keep it fed — a lost drum hour is a lost plant hour.\n'
        '• [[red:Risk]] ISA 90×90×6 at 18% feeds it — expedite today.\n'
        '• [[red:Risk]] CNC-124T2 (78%) feeds it — pre-stage CNC-124T1.';
  }
  if (has(['miss', 'late', 'risk order', 'red order', 'behind', 'order'])) {
    return '### Orders at risk\n'
        '• [[red:RED]] **WO24Y-00248-STUB** — penetrated red, will miss today\'s galv slot. **→ Expedite to Batch 4.**\n'
        '• [[amber:WATCH]] WO24Y-00247 — entering yellow.\n'
        '• [[green:OK]] WO24Y-00250 — on track.';
  }
  if (has(['downtime', 'machine', 'breakdown', 'fail', 'cnc', 'not working', 'maintenance'])) {
    return '### Machines & downtime\n'
        '• [[red:DOWN]] **CNC-124T2** — predicted fail 78%/36 h (spindle). Feeds the drum → inspect tonight.\n'
        '• [[blue:PM]] MILL-3 — planned maintenance 06:00–10:00.\n'
        '• [[slate:No plan]] DRILL-2 — no plan loaded today.\nAll others running. Act on CNC-124T2 first.';
  }
  if (has(['steel', 'section', 'material', 'buffer', 'isa', 'stock', 'zinc'])) {
    final lines = plant.sectionsBuffer.map((s) => '[[bar:${s[1]}:${s[0]}]]').join('\n');
    return '### Steel buffers\n$lines\n[[red:Act now]] ISA 90×90×6 (18%) is the top-runner and feeds the drum — expedite the open PO today.';
  }
  if (has(['util', 'idle', 'capacity', 'load', 'work cent', 'workcent'])) {
    final lines = plant.feeders.map((f) => '[[bar:${f[1]}:${f[0]}]]').join('\n');
    return '### Utilisation\n$lines\n[[bar:96:Galvanizing (drum)]]\nInspection (61%) is your slack — reallocate toward the drum.';
  }
  if (has(['escalat', 'monitor', 'action', 'decision', 'urgent', 'attention'])) {
    final lines = plant.alerts
        .where((a) => a.status == 'open' && a.sev != 'blue')
        .map((a) {
      final sv = a.sev == 'red' ? 'red' : 'amber';
      return '[[esc:$sv:${a.title}::${a.detail}::${a.action}]]';
    }).join('\n');
    return '### To escalate now\n$lines';
  }
  if (has(['tomorrow'])) {
    return '### Tomorrow\n• ${plant.tomPm}\n• ${plant.tomInspection}\n• Dispatch ${plant.tomDispatch}\n• [[amber:Heads-up]] ${plant.tomNote}';
  }
  if (has(['oee', 'performance', 'trend', 'efficien'])) {
    return '### Performance (5 days)\n• OEE: ${plant.oeeTrend.join(' → ')}\n• MT: ${plant.mtTrend.join(' → ')}\nOEE steady but below 75% — the gap is the drum, not the CNC lines.';
  }
  if (has(['manpower', 'operator', 'workforce', 'absent', 'shift', 'people'])) {
    return '### Manpower\n• [[amber:Tomorrow]] Galv shift-B short 2 operators. **→ Move 2 from Inspection (61%).**\nAllocate to the drum first, then feeders — don\'t balance all areas equally.';
  }
  if (has(['dispatch', 'deliver', 'qcs', 'ship'])) {
    return '### Dispatch\n• Today: 18 MT → Soja, 17:30 (after 14:00 GETCO inspection).\n• Tomorrow: 24 MT → Mehsana.\n• [[amber:Watch]] WO-00248-STUB must clear galvanizing today.';
  }
  if (has(['help', 'what can you', 'capab'])) {
    return '### I\'m your Plant Copilot\nAsk about the **CCR/drum**, **orders at risk**, **machine downtime**, **steel buffers**, **utilisation/OEE**, **manpower**, **dispatch**, or **what to escalate**.';
  }
  return 'Here\'s what matters most now:\n'
      '• [[red:Escalate]] ISA 90×90×6 buffer in the red.\n'
      '• [[red:Escalate]] CNC-124T2 78% failure risk.\n'
      '• [[red:Escalate]] WO24Y-00248-STUB will miss its galv slot.\nSay **\'brief me\'** for the full picture.';
}

/// Current signed-in role (set at login). Used by detail pages that open the copilot.
String appRole = 'Plant Head';

/// Opens the copilot as a full pushed page (used by "Ask Copilot" buttons).
void pushCopilot(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => Scaffold(
      appBar: AppBar(
        backgroundColor: C.deep,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text('Plant Copilot', style: sora(16, c: Colors.white)),
          Text('Self-service AI', style: body(11, c: const Color(0xFF9DB8D4))),
        ]),
      ),
      body: SafeArea(child: CopilotScreen(role: appRole)),
    ),
  ));
}

/// -------- rich-text rendering for copilot messages --------
List<InlineSpan> _boldSpans(String s) {
  final spans = <InlineSpan>[];
  final re = RegExp(r'\*\*(.+?)\*\*');
  var last = 0;
  for (final m in re.allMatches(s)) {
    if (m.start > last) spans.add(TextSpan(text: s.substring(last, m.start)));
    spans.add(TextSpan(text: m.group(1), style: const TextStyle(fontWeight: FontWeight.w700, color: C.deep)));
    last = m.end;
  }
  if (last < s.length) spans.add(TextSpan(text: s.substring(last)));
  return spans;
}

List<InlineSpan> _inline(String s) {
  final spans = <InlineSpan>[];
  final re = RegExp(r'\[\[(red|amber|green|blue|slate):(.+?)\]\]');
  var last = 0;
  for (final m in re.allMatches(s)) {
    if (m.start > last) spans.addAll(_boldSpans(s.substring(last, m.start)));
    spans.add(WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 2), child: pill(m.group(2)!, m.group(1)!)),
    ));
    last = m.end;
  }
  if (last < s.length) spans.addAll(_boldSpans(s.substring(last)));
  return spans;
}

List<Widget> renderRich(String md) {
  final out = <Widget>[];
  final barRe = RegExp(r'\[\[bar:(\d+):(.+?)\]\]');
  final escRe = RegExp(r'\[\[esc:(red|amber):(.+?)::(.+?)::(.+?)\]\]');
  for (final raw in md.split('\n')) {
    final line = raw.trimRight();
    if (line.trim().isEmpty) {
      out.add(const SizedBox(height: 5));
    } else if (line.startsWith('### ')) {
      out.add(Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 6),
        child: Text(line.substring(4).toUpperCase(),
            style: sora(11.5, c: C.deep).copyWith(letterSpacing: .4)),
      ));
    } else if (line.startsWith('[[bar:')) {
      for (final m in barRe.allMatches(line)) {
        out.add(barRow(m.group(2)!, int.parse(m.group(1)!)));
      }
    } else if (line.startsWith('[[esc:')) {
      for (final m in escRe.allMatches(line)) {
        out.add(escBox('${m.group(2)}\n→ ${m.group(4)}', sev: m.group(1)!));
      }
    } else if (line.startsWith('• ')) {
      out.add(Padding(
        padding: const EdgeInsets.only(left: 4, top: 3, bottom: 3),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(padding: const EdgeInsets.only(top: 6, right: 8), child: statusDot(C.blue, size: 5)),
          Expanded(child: Text.rich(TextSpan(style: body(13), children: _inline(line.substring(2))))),
        ]),
      ));
    } else {
      out.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text.rich(TextSpan(style: body(13), children: _inline(line))),
      ));
    }
  }
  return out;
}

/// -------- chat screen --------
class CopilotScreen extends StatefulWidget {
  final String role;
  const CopilotScreen({super.key, required this.role});
  @override
  State<CopilotScreen> createState() => _CopilotScreenState();
}

class _ChatMsg {
  final bool ai;
  final String text;
  _ChatMsg(this.ai, this.text);
}

class _CopilotScreenState extends State<CopilotScreen> {
  final _msgs = <_ChatMsg>[];
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  bool _live = true, _typing = false;

  static const _suggest = [
    'Brief me', 'Today\'s bottleneck?', 'Which orders will miss?', 'Machine at risk?',
    'Steel buffers', 'What should I escalate?', 'Tomorrow\'s plan'
  ];

  @override
  void initState() {
    super.initState();
    _msgs.add(_ChatMsg(true, buildBriefing(widget.role)));
  }

  Future<void> _send(String text) async {
    text = text.trim();
    if (text.isEmpty) return;
    setState(() {
      _msgs.add(_ChatMsg(false, text));
      _typing = true;
      _ctrl.clear();
    });
    _toBottom();
    final r = await CopilotService.ask(widget.role, text);
    if (!mounted) return;
    setState(() {
      _typing = false;
      _live = r.live;
      _msgs.add(_ChatMsg(true, r.text));
    });
    _toBottom();
  }

  void _toBottom() => WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
        child: Row(children: [
          statusDot(_live ? const Color(0xFF46D27A) : C.amber, size: 7),
          const SizedBox(width: 6),
          Text(_live ? 'Live Claude' : 'Demo brain', style: body(10.5, w: FontWeight.w600, c: C.mut)),
        ]),
      ),
      Expanded(
        child: ListView.builder(
          controller: _scroll,
          padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
          itemCount: _msgs.length + (_typing ? 1 : 0),
          itemBuilder: (ctx, i) {
            if (i == _msgs.length) return _aiBubble(const Text('…', style: TextStyle(color: C.sky)));
            final m = _msgs[i];
            return m.ai
                ? _aiBubble(Column(crossAxisAlignment: CrossAxisAlignment.start, children: renderRich(m.text)))
                : Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 11, left: 40),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [C.blue, Color(0xFF175A96)]),
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(15), bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15), topRight: Radius.circular(4))),
                      child: Text(m.text, style: body(13, c: Colors.white)),
                    ),
                  );
          },
        ),
      ),
      SizedBox(
        height: 42,
        child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 14), children: [
          for (final s in _suggest)
            Padding(
              padding: const EdgeInsets.only(right: 7),
              child: ActionChip(
                label: Text(s, style: body(11.5, w: FontWeight.w500, c: C.deep)),
                backgroundColor: Colors.white,
                side: const BorderSide(color: C.line),
                onPressed: () => _send(s),
              ),
            ),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 14),
        child: Row(children: [
          Expanded(
            child: TextField(
              controller: _ctrl,
              minLines: 1,
              maxLines: 4,
              onSubmitted: _send,
              decoration: InputDecoration(
                hintText: 'Ask anything…',
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(21), borderSide: const BorderSide(color: C.line)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(21), borderSide: const BorderSide(color: C.sky)),
              ),
            ),
          ),
          const SizedBox(width: 9),
          GestureDetector(
            onTap: () => _send(_ctrl.text),
            child: Container(
              width: 42, height: 42,
              decoration: const BoxDecoration(gradient: LinearGradient(colors: [C.blue, C.deep]), shape: BoxShape.circle),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 19),
            ),
          ),
        ]),
      ),
    ]);
  }

  Widget _aiBubble(Widget child) => Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 11, right: 30),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.only(left: 2, bottom: 5),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 21, height: 21, alignment: Alignment.center,
                    decoration: BoxDecoration(gradient: const LinearGradient(colors: [C.blue, C.deep]), borderRadius: BorderRadius.circular(7)),
                    child: Text('9', style: sora(10, c: Colors.white))),
                const SizedBox(width: 7),
                Text('Plant Copilot', style: body(11, w: FontWeight.w600, c: C.slate)),
              ]),
            ),
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(15), bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15), topLeft: Radius.circular(4)),
                  border: Border.all(color: C.line)),
              child: child,
            ),
          ]),
        ),
      );
}
