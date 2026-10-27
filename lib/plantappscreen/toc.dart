import 'package:flutter/material.dart';
import 'theme.dart';
import 'data.dart';
import 'widgets.dart';
import 'copilot.dart';

/// ===================== BUFFER BOARD + DBM =====================
class BufferBoardScreen extends StatefulWidget {
  const BufferBoardScreen({super.key});
  @override
  State<BufferBoardScreen> createState() => _BufferBoardScreenState();
}

class _BufferBoardScreenState extends State<BufferBoardScreen> {
  @override
  Widget build(BuildContext context) {
    final bo = [...plant.bufferOrders]..sort((a, b) => b.pen.compareTo(a.pen));
    final counts = {'red': 0, 'amber': 0, 'green': 0};
    for (final o in bo) {
      counts[o.zone] = (counts[o.zone] ?? 0) + 1;
    }
    Widget countCell(String n, Color c, String l) => Column(children: [
          Text(n, style: mono(23, c: c)),
          Text(l, style: body(10, w: FontWeight.w600, c: C.mut)),
        ]);
    return Column(children: [
      card(Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        countCell('${counts['red']}', C.red, 'RED'),
        countCell('${counts['amber']}', C.amber, 'YELLOW'),
        countCell('${counts['green']}', C.green, 'GREEN'),
      ])),
      sectionTitle('Work the reds first'),
      ...bo.map((o) {
        final col = C.sev(o.zone);
        final tr = o.trend == 'up' ? '↑ penetrating' : (o.trend == 'down' ? '↓ recovering' : '→ stable');
        final tappable = plant.trace.containsKey(o.wo);
        return GestureDetector(
          onTap: tappable ? () => pushPage(context, 'Order trace', '', TraceDetailScreen(wo: o.wo)) : null,
          child: card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              statusDot(col),
              const SizedBox(width: 9),
              Expanded(child: Text(o.wo, style: body(13.5, w: FontWeight.w600))),
              pill('${o.pen}% · $tr', o.zone),
            ]),
            fillBar(o.pen, col),
            const SizedBox(height: 7),
            Text('Cause: ${o.cause}', style: body(11.5, c: C.ink)),
            Text('${o.ct} · ${o.slot}', style: body(11.5, c: C.mut)),
          ]), padding: const EdgeInsets.all(12)),
        );
      }),
      sectionTitle('Dynamic buffer management (DBM)'),
      ...plant.dbm.map((d) => Opacity(
            opacity: d.applied ? .5 : 1,
            child: card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(d.item, style: sora(13, c: C.deep))),
                pill(d.dir == 'up' ? '↑ grow' : '↓ shrink', d.dir == 'up' ? 'red' : 'green'),
              ]),
              const SizedBox(height: 5),
              Text('Signal: ${d.signal}', style: body(11.5, c: C.mut)),
              const SizedBox(height: 4),
              Text('→ ${d.rec}', style: body(12.5, c: C.ink)),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: _btn('Apply', C.blue, Colors.white, () { setState(() => d.applied = true); toast(context, 'Buffer change applied'); })),
                const SizedBox(width: 9),
                Expanded(child: _btn('Dismiss', C.panel, C.deep, () { setState(() => d.applied = true); toast(context, 'Dismissed'); })),
              ]),
            ]), padding: const EdgeInsets.all(12)),
          )),
    ]);
  }
}

Widget _btn(String label, Color bg, Color fg, VoidCallback onTap) => GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(11), border: bg == C.panel ? Border.all(color: C.line) : null),
        child: Text(label, style: sora(13, c: fg)),
      ),
    );

/// ===================== ORDER TRACK & TRACE =====================
class TraceScreen extends StatefulWidget {
  const TraceScreen({super.key});
  @override
  State<TraceScreen> createState() => _TraceScreenState();
}

class _TraceScreenState extends State<TraceScreen> {
  String q = '';
  @override
  Widget build(BuildContext context) {
    final keys = plant.trace.keys.where((k) {
      final t = plant.trace[k]!;
      final hay = '$k ${t.ct} ${t.mark}'.toLowerCase();
      return hay.contains(q.toLowerCase());
    }).toList();
    return Column(children: [
      card(TextField(
        onChanged: (v) => setState(() => q = v),
        decoration: InputDecoration(
          hintText: 'Search order / mark no / contract…',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: C.line)),
          isDense: true,
        ),
      ), padding: const EdgeInsets.all(11)),
      sectionTitle('Orders'),
      ...keys.map((wo) {
        final t = plant.trace[wo]!;
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(backgroundColor: C.sev(t.zone).withOpacity(.13), child: statusDot(C.sev(t.zone))),
          title: Text(wo, style: body(13.5, w: FontWeight.w600)),
          subtitle: Text('${t.mark} · ${t.ct}', style: body(11.5, c: C.mut)),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [pill('${t.pen}%', t.zone), const Icon(Icons.chevron_right, color: Color(0xFFB8C5D4))]),
          onTap: () => pushPage(context, 'Order trace', '', TraceDetailScreen(wo: wo)),
        );
      }),
    ]);
  }
}

class TraceDetailScreen extends StatelessWidget {
  final String wo;
  const TraceDetailScreen({super.key, required this.wo});
  @override
  Widget build(BuildContext context) {
    final t = plant.trace[wo]!;
    Color stepColor(String s) => s == 'done' ? C.green : (s == 'running' ? C.amber : (s == 'staged' ? C.blue : const Color(0xFFCFDAE6)));
    return Column(children: [
      card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Expanded(child: Text(wo, style: sora(17, c: C.deep))), pill('buffer ${t.pen}%', t.zone)]),
        const SizedBox(height: 6),
        Text('${t.mark}\n${t.ct}', style: body(12.5, c: C.ink)),
        const SizedBox(height: 8),
        Text.rich(TextSpan(style: body(12.5, c: C.deep), children: [
          const TextSpan(text: 'Predicted ready: ', style: TextStyle(fontWeight: FontWeight.w700)),
          TextSpan(text: t.ready),
        ])),
      ])),
      card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        sectionTitle('Where it is now'),
        ...t.ops.map((o) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(padding: const EdgeInsets.only(top: 3, right: 10), child: statusDot(stepColor(o.status), size: 12)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(children: [
                    Text(o.name, style: body(13, w: FontWeight.w600)),
                    if (o.status == 'running') ...[const SizedBox(width: 8), pill('here now', 'amber')],
                    const Spacer(),
                    Text(o.time, style: mono(11, c: C.mut)),
                  ]),
                ),
              ),
            ])),
      ])),
      card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        sectionTitle('Traceability & quality'),
        _kv('Steel heat / genealogy', t.heat.join('\n')),
        _kv('Quality', t.qc),
        _kv('Galvanizing (drum)', t.galv),
        _kv('Dispatch', t.dispatch),
      ])),
      Row(children: [
        Expanded(child: _btn('Ask about this order', C.amber, const Color(0xFF3A2406), () => pushCopilot(context))),
        const SizedBox(width: 9),
        Expanded(child: _btn('Back', C.panel, C.deep, () => Navigator.pop(context))),
      ]),
    ]);
  }

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(k, style: body(13, w: FontWeight.w600)),
          Text(v, style: body(11.5, c: C.mut)),
        ]),
      );
}

/// ===================== THROUGHPUT PER DRUM-HOUR =====================
class ThroughputScreen extends StatelessWidget {
  const ThroughputScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final t = [...plant.tput]..sort((a, b) => b.tHr.compareTo(a.tHr));
    final mx = t.first.tHr;
    return Column(children: [
      card(Text.rich(TextSpan(style: body(12.5, c: C.ink), children: const [
        TextSpan(text: 'When galvanizing is the constraint, sequence by '),
        TextSpan(text: '₹ throughput per drum-minute', style: TextStyle(fontWeight: FontWeight.w700, color: C.deep)),
        TextSpan(text: ' — not due date alone (unless a buffer is red). Highest earners first:'),
      ]))),
      ...t.asMap().entries.map((e) {
        final i = e.key;
        final x = e.value;
        final w = (x.tHr / mx * 100).round();
        return card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('#${i + 1}', style: mono(12, c: C.mut)),
            const SizedBox(width: 8),
            Expanded(child: Text(x.item, style: body(13, w: FontWeight.w600))),
            Text('₹${(x.tHr / 100000).toStringAsFixed(2)} L/hr', style: mono(13, c: C.deep)),
          ]),
          fillBar(w, i == 0 ? C.green : C.blue),
          const SizedBox(height: 6),
          Text('${x.min} drum-min/unit · ${x.t}', style: body(11, c: C.mut)),
        ]), padding: const EdgeInsets.all(12));
      }),
      card(Text.rich(TextSpan(style: body(12, c: C.deep), children: const [
        TextSpan(text: 'Mix tip: ', style: TextStyle(fontWeight: FontWeight.w700)),
        TextSpan(text: 'a drum-minute on a PP body earns ~3× one on an A.C. device. Clear red buffers first, then load the drum with the highest ₹/min.'),
      ])), color: C.bluep),
    ]);
  }
}

/// ===================== INTERACTIVE DRUM SEQUENCING =====================
const double _kettle = 20;
int _fillPct(double mt) => (mt / _kettle * 100).round();

class DrumSeqScreen extends StatefulWidget {
  const DrumSeqScreen({super.key});
  @override
  State<DrumSeqScreen> createState() => _DrumSeqScreenState();
}

class _DrumSeqScreenState extends State<DrumSeqScreen> {
  static const _times = ['07:00', '08:30', '10:00', '11:30', '13:30', '15:00', '16:30', '18:00', '19:30'];
  void _reflow() {
    for (var i = 0; i < plant.ccrPlan.length; i++) {
      if (i < _times.length) plant.ccrPlan[i].time = _times[i];
    }
  }

  void _move(int i, int dir) {
    final plan = plant.ccrPlan;
    final j = i + dir;
    if (j < 0 || j >= plan.length || plan[j].status != 'queued') return;
    final t = plan[i];
    plan[i] = plan[j];
    plan[j] = t;
    setState(_reflow);
  }

  void _optimise() {
    final plan = plant.ccrPlan;
    final fixed = plan.where((p) => p.status != 'queued').toList();
    final q = plan.where((p) => p.status == 'queued').toList()
      ..sort((a, b) {
        int red(String l) => RegExp(r'00248|00253').hasMatch(l) ? 0 : 1;
        return red(a.label).compareTo(red(b.label));
      });
    plant.ccrPlan = [...fixed, ...q];
    setState(_reflow);
    toast(context, 'Re-sequenced: reds first, kettles filled');
  }

  @override
  Widget build(BuildContext context) {
    final plan = plant.ccrPlan;
    final planned = plan.fold<double>(0, (s, p) => s + p.mtValue);
    final cap = plan.length * _kettle;
    final avg = (planned / cap * 100).round();
    final unused = (cap - planned).round();
    Widget stat(String v, Color c, String l) => Column(children: [Text(v, style: mono(21, c: c)), Text(l, style: body(10, w: FontWeight.w600, c: C.mut))]);
    return Column(children: [
      card(Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        stat('$avg%', C.deep, 'AVG KETTLE FILL'),
        stat('$unused MT', C.amber, 'UNUSED DRUM CAP'),
        stat('${plan.length}', C.deep, 'BATCHES'),
      ])),
      sectionTitle('Sequence · reorder queued batches', trailing: GestureDetector(onTap: _optimise, child: Text('Optimise ›', style: body(11, w: FontWeight.w600, c: C.blue)))),
      ...plan.asMap().entries.map((e) {
        final i = e.key;
        final p = e.value;
        final fp = _fillPct(p.mtValue);
        final spare = fp < 85 ? ' — ${(_kettle - p.mtValue).round()} MT spare' : '';
        return card(Row(children: [
          SizedBox(width: 40, child: Text(p.time, style: mono(11, c: C.slate))),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.label, style: body(12.5, w: FontWeight.w600)),
              fillBar(fp.clamp(0, 100), fp < 85 ? C.amber : C.green),
              const SizedBox(height: 3),
              Text('${p.mt} · kettle $fp% full$spare', style: body(10.5, c: fp < 85 ? C.amber : C.mut)),
            ]),
          ),
          const SizedBox(width: 8),
          pill(p.status, p.status == 'done' ? 'green' : (p.status == 'running' ? 'amber' : 'slate')),
          if (p.status == 'queued')
            Column(children: [
              _arrow(Icons.keyboard_arrow_up, () => _move(i, -1)),
              const SizedBox(height: 3),
              _arrow(Icons.keyboard_arrow_down, () => _move(i, 1)),
            ])
          else
            const SizedBox(width: 28),
        ]), padding: const EdgeInsets.all(11));
      }),
      card(Text.rich(TextSpan(style: body(12, c: const Color(0xFF7A4D08)), children: const [
        TextSpan(text: 'Watch: ', style: TextStyle(fontWeight: FontWeight.w700)),
        TextSpan(text: 'keep Batch 4 (WO-00248-STUB, red) early. Under-filled batches waste drum capacity you can\'t recover — merge where dip time allows.'),
      ])), color: C.amberp),
    ]);
  }

  Widget _arrow(IconData ic, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(width: 28, height: 21, alignment: Alignment.center, decoration: BoxDecoration(color: C.panel2, borderRadius: BorderRadius.circular(6)), child: Icon(ic, size: 16, color: C.deep)),
      );
}

/// ===================== ORDER JOURNEY (end-to-end) =====================
class JourneyHubScreen extends StatelessWidget {
  const JourneyHubScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 700;

    final p = plant;
    return Center(
        child: Container(
            height: MediaQuery.of(context).size.height,
            color:const Color(0xFFF5F7FB),
            width: isDesktop ? 700 : double.infinity,
            padding: const EdgeInsets.all(10),
            child:SingleChildScrollView(
                child:Column(children: [
      card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(p.jContractId, style: sora(16, c: C.deep)),
        const SizedBox(height: 4),
        Text('${p.jContractName} · ${p.jSets} sets · ${p.jTotalMT} MT', style: body(12.5, c: C.ink)),
        const SizedBox(height: 6),
        Text('Follow this order from QCS receipt to dispatch — see what the system does, and what TOC buys you, at every step.', style: body(11, c: C.mut)),
        const SizedBox(height: 12),
        _btn('Start walkthrough ›', C.amber, const Color(0xFF3A2406), () => pushPage(context, 'Order Journey', 'Step 1 of 7', JourneyStageScreen(n: 1))),
      ])),
      sectionTitle('The journey'),
      card(Column(children: [
        for (var i = 0; i < p.stages.length; i++)
          InkWell(
            onTap: () => pushPage(context, 'Order Journey', 'Step ${i + 1} of 7', JourneyStageScreen(n: i + 1)),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: i == p.stages.length - 1 ? Colors.transparent : C.line))),
              child: Row(children: [
                Container(
                  width: 30, height: 30, alignment: Alignment.center,
                  decoration: BoxDecoration(color: p.stages[i].done ? C.greenp : C.bluep, borderRadius: BorderRadius.circular(9)),
                  child: Text(p.stages[i].done ? '✓' : '${i + 1}', style: sora(13, c: p.stages[i].done ? C.green : C.blue)),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(p.stages[i].title, style: body(13.5, w: FontWeight.w600)),
                  Text(p.stages[i].blurb, style: body(11.5, c: C.mut)),
                ])),
                const Icon(Icons.chevron_right, color: Color(0xFFB8C5D4)),
              ]),
            ),
          ),
      ])),
    ]))));
  }
}

class JourneyStageScreen extends StatelessWidget {
  final int n;
  const JourneyStageScreen({super.key, required this.n});

  @override
  Widget build(BuildContext context) {
    final p = plant;
    String ttl = '', ben = '';
    final body0 = <Widget>[];

    if (n == 1) {
      ttl = 'Demand in — Sales Order & QCS';
      body0.add(card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [pill('From SAP', 'blue'), const SizedBox(width: 6), pill(p.sync, 'slate')]),
        const SizedBox(height: 8),
        Text('${p.jContractId} · ${p.jContractName}', style: sora(15, c: C.deep)),
        Text('${p.jCustomer} · ${p.jSets} sets · ${p.jTotalMT} MT', style: body(12, c: C.mut)),
      ])));
      body0.add(card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        sectionTitle('QCS — delivery schedule'),
        ...p.qcs.map((q) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(q.item, style: body(12.5, w: FontWeight.w600)), Text('${q.sets} sets', style: body(11, c: C.mut))])),
                pill('due ${q.due}', 'slate'),
              ]),
            )),
      ])));
      body0.add(card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        sectionTitle('C9 structures it'),
        Text('Contract → Tower type (PP) → Component (body / stub / template / extension) → Mark No → Pieces', style: body(12, c: C.ink)),
      ])));
      ben = 'Order book clean and date-anchored from minute one.';
    } else if (n == 2) {
      ttl = 'Work orders from SAP';
      body0.add(card(Row(children: [pill('${p.sapWO.length} WOs received', 'green'), const SizedBox(width: 6), pill(p.sync, 'slate')])));
      body0.add(card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        sectionTitle('Inbound work orders'),
        ...p.sapWO.map((w) => ListTile(
              contentPadding: EdgeInsets.zero, dense: true,
              title: Text(w.wo, style: body(13, w: FontWeight.w600)),
              subtitle: Text('${w.desc} · ${w.qty} · ${w.mt}', style: body(11, c: C.mut)),
              trailing: pill(w.status, 'green'),
            )),
      ])));
      body0.add(card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        sectionTitle('SAP ↔ Cloud 9 boundary'),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: _boundary('SAP owns', 'SO · WO · PO · goods receipt · dispatch posting', const Color(0xFFEEF1F5))),
          const SizedBox(width: 8),
          Expanded(child: _boundary('Cloud 9 owns', 'DDMRP · DBR scheduling · MES · delivery dates · MIS', C.bluep)),
        ]),
      ])));
      ben = 'No re-keying; the integration boundary is explicit.';
    } else if (n == 3) {
      ttl = 'DDMRP — material readiness';
      body0.add(card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        sectionTitle('Net-flow buffers (high-runner sections)'),
        ...p.ddmrp.map((d) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [Expanded(child: Text(d.section, style: body(12.5, w: FontWeight.w600))), pill('${d.netflow}%', d.zone)]),
                fillBar(d.netflow, C.sev(d.zone)),
                const SizedBox(height: 3),
                Text('on-hand ${d.onHand} · on-order ${d.onOrder} · demand ${d.demand}${d.replenish != '—' ? ' · ${d.replenish}' : ''}', style: body(10.5, c: C.mut)),
              ]),
            )),
      ])));
      body0.add(card(Text(p.boughtout, style: body(12, w: FontWeight.w600, c: C.deep)), color: C.bluep));
      ben = 'Buffer the few sections carrying ~69% of tonnage — never starve the drum.';
    } else if (n == 4) {
      ttl = 'Full-kit availability check';
      body0.add(card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        sectionTitle('Release only complete kits'),
        ...p.fullkit.map((k) {
          final vp = k.verdict == 'hold' ? pill('HOLD', 'red') : pill(k.verdict, 'green');
          Widget kit(String l, bool ok) => Text(ok ? '✓ $l' : '✗ $l', style: body(11.5, w: FontWeight.w600, c: ok ? C.green : C.red));
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Expanded(child: Text(k.wo, style: body(13, w: FontWeight.w600))), vp]),
              const SizedBox(height: 6),
              Wrap(spacing: 14, children: [kit('Steel', k.steel), kit('Bolts/nuts', k.bolt), kit('NC/drawing', k.nc)]),
              if (k.missing.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 4), child: Text('Missing: ${k.missing}', style: body(11, c: C.red))),
            ]),
          );
        }),
      ])));
      body0.add(card(Text.rich(TextSpan(style: body(12, c: const Color(0xFF7A4D08)), children: const [
        TextSpan(text: 'Why it matters: ', style: TextStyle(fontWeight: FontWeight.w700)),
        TextSpan(text: 'releasing partial kits floods the floor with WIP that steals capacity from the drum. Only full kits are released.'),
      ])), color: C.amberp));
      ben = 'Only ready work hits the floor — flow protected.';
    } else if (n == 5) {
      ttl = 'CCR scheduling & delivery promise';
      body0.add(card(Row(children: [
        gauge(p.ccrLoadPct, C.amber, size: 100),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(p.drum, style: sora(15, c: C.deep)),
          const SizedBox(height: 5),
          Text('Load kits to the drum; feeders subordinate to it.', style: body(12, c: C.ink)),
          const SizedBox(height: 5),
          pill('${p.ccrLoadPct}% loaded', 'amber'),
        ])),
      ])));
      body0.add(card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        sectionTitle('Promised date vs QCS required'),
        ...p.promise.map((pr) {
          final pl = pr.status == 'late' ? pill('${pr.promised} · late', 'red') : (pr.status == 'early' ? pill('${pr.promised} · early', 'green') : pill(pr.promised, 'green'));
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(pr.item, style: body(12.5, w: FontWeight.w600)), Text('required ${pr.reqDate}${pr.note.isNotEmpty ? ' · ${pr.note}' : ''}', style: body(11, c: C.mut))])),
              pl,
            ]),
          );
        }),
      ])));
      body0.add(card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        sectionTitle('Machine-wise schedule (subordinated to the drum)'),
        ...p.machineSched.map((m) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(m.machine, style: body(12.5, w: FontWeight.w700, c: C.deep)),
                Text(m.jobs.map((x) => '${x[0]} ${x[1]}').join('  ·  '), style: body(11.5, c: C.mut)),
              ]),
            )),
      ])));
      ben = 'A promise you can keep — computed from real drum load when the order lands.';
    } else if (n == 6) {
      ttl = 'Execution — MES';
      body0.add(card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Released kits run on the floor with live operation confirmations, downtime capture, and full piece traceability (steel heat → galvanized member) for client inspection.', style: body(13, c: C.ink)),
        const SizedBox(height: 12),
        _btn('Open live shop floor', C.blue, Colors.white, () => Navigator.pop(context)),
      ])));
      ben = 'Live control on the floor; traceability for client inspection.';
    } else {
      ttl = 'Monitor & deliver — MIS';
      body0.add(card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('The loop closes: manage by the constraint — buffer status, throughput per drum-hour, drum-first OEE, and dispatch readiness against the QCS.', style: body(13, c: C.ink)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _btn('Buffer board', C.blue, Colors.white, () => pushPage(context, 'Buffer board', 'Work the reds first', const BufferBoardScreen()))),
          const SizedBox(width: 9),
          Expanded(child: _btn('Throughput', C.amber, const Color(0xFF3A2406), () => pushPage(context, 'Throughput', '₹ per drum-hour', const ThroughputScreen()))),
        ]),
      ])));
      ben = 'The loop closes — manage the plant by its constraint.';
    }

    return Column(children: [
      _stepper(n),
      Padding(padding: const EdgeInsets.only(bottom: 10, left: 2, right: 2), child: Align(alignment: Alignment.centerLeft, child: Text('Step $n of 7 · $ttl', style: sora(15, c: C.deep)))),
      ...body0,
      escBox('Benefit: $ben', sev: 'green'),
      const SizedBox(height: 8),
      Row(children: [
        if (n > 1) Expanded(child: _btn('‹ Prev', C.panel, C.deep, () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DetailScaffold(title: 'Order Journey', subtitle: 'Step ${n - 1} of 7', child: JourneyStageScreen(n: n - 1)))))),
        if (n > 1) const SizedBox(width: 9),
        Expanded(child: n < 7
            ? _btn('Next ›', C.blue, Colors.white, () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DetailScaffold(title: 'Order Journey', subtitle: 'Step ${n + 1} of 7', child: JourneyStageScreen(n: n + 1)))))
            : _btn('Finish ✓', C.blue, Colors.white, () => Navigator.pop(context))),
      ]),
    ]);
  }

  Widget _stepper(int n) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(children: [
          for (var i = 1; i <= 7; i++)
            Expanded(
              child: Container(
                height: 5,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(color: i < n ? C.green : (i == n ? C.amber : C.line), borderRadius: BorderRadius.circular(3)),
              ),
            ),
        ]),
      );

  Widget _boundary(String h, String b, Color bg) => Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(11), border: Border.all(color: C.line)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(h, style: sora(12, c: C.deep)),
          const SizedBox(height: 5),
          Text(b, style: body(11.5, c: C.ink)),
        ]),
      );
}
