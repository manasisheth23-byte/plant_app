import 'dart:convert';
import 'package:erpflutter/models/LoginResponseModel.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/alerts/alerts_list.dart';
import 'theme.dart';
import 'data.dart';
import 'widgets.dart';
import 'copilot.dart';
import 'toc.dart';

/// ===================== HOME / DASHBOARD =====================
class HomeScreen extends StatelessWidget {
  final String role;
  final void Function(int) onTab;
  HomeScreen({super.key, required this.role, required this.onTab});

  String _cls(num v, num good, num warn) => v >= good ? 'good' : (v >= warn ? 'warn' : 'bad');

  Future<LoginResponseModel?> getUserResponse() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final loginData = prefs.getString('LOGINRESPONSE');

    if (loginData == null || loginData.isEmpty) {
      return null;
    }

    return LoginResponseModel.fromJson(
      jsonDecode(loginData),
    );
  }
  late bool? isMobile ;
  @override
  Widget build(BuildContext context) {
    final k = plant;
    final isDesktop = MediaQuery.of(context).size.width >= 700;

    final width = MediaQuery.of(context).size.width;

    isMobile = width < 700;
    final bool isTablet = width >= 700 && width < 1100;


    final int toolColumns = isDesktop
        ? 6
        : isTablet
        ? 4
        : 3;

    final int kpiColumns = isDesktop
        ? 6
        : isTablet
        ? 4
        : 3;
    return Center(
      child: Container(
       /* width: isMobile!
            ? double.infinity
            : isTablet
            ? width * 0.92
            : width * 0.40,
*/
        width: isDesktop ? 700 : double.infinity,
        decoration: isMobile!
            ? null
            : BoxDecoration(
          color: const Color(0xFFF6F9FC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade300,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 3),
            )
          ],
        ),
        child: Center(
            child: Container(
                height: MediaQuery.of(context).size.height,
                color:const Color(0xFFF5F7FB),
                width: isDesktop ? 700 : double.infinity,
                padding: const EdgeInsets.all(10),
                child:ListView(padding: const EdgeInsets.all(14), children: [
          // Order Journey banner
          GestureDetector(
            onTap: () => pushPage(context, 'Order Journey', 'QCS → dispatch', const JourneyHubScreen()),
            child: _hero(const LinearGradient(colors: [C.amber, Color(0xFFC2791B)]), Icons.alt_route, 'Order Journey — QCS to dispatch', 'Walk one order end-to-end through the system', const Color(0xFFFFF3E2)),
          ),
          // Ask copilot
          GestureDetector(
            onTap: () => onTab(4),
            child: _hero(const LinearGradient(colors: [C.deep, Color(0xFF0E3358)]), null, 'Ask the Plant Copilot', 'Self-service answers — no need to call anyone', const Color(0xFFBCD4EE), avatar: '9'),
          ),
          sectionTitle('Self-service tools'),
          GridView.count(
            crossAxisCount: isMobile! ? 3 :3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 9, crossAxisSpacing: 9,  childAspectRatio: isMobile! ? 1.0 : 1.8,

            children: [
              _tool('Buffer board', Icons.dashboard_customize, C.red, () => pushPage(context, 'Buffer board', 'Work the reds first', const BufferBoardScreen())),
              _tool('Track order', Icons.search, C.blue, () => pushPage(context, 'Track & trace', 'Where is my order?', const TraceScreen())),
              _tool('Drum sequence', Icons.view_agenda, C.amber, () => pushPage(context, 'Drum sequencing', 'Galvanizing kettle', const DrumSeqScreen())),
              _tool('Throughput', Icons.show_chart, C.blue, () => pushPage(context, 'Throughput', '₹ per drum-hour', const ThroughputScreen())),
              _tool('Actions', Icons.notifications, C.blue, () => onTab(2)),
              _tool('Shop floor', Icons.grid_view, C.blue, () => onTab(1)),
              /* _tool(
                'Approvals',
                Icons.grid_view,
                C.blue,
                    () async {
                  final loginResponseModel = await getUserResponse();

                  if (loginResponseModel == null) return;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider(
                        create: (_) => ApprovalsController(),
                        child: ApprovalsListFragment(
                          loginResponseModel: loginResponseModel,
                        ),
                      ),
                    ),
                  );
                },
              ),*/

              /* _tool(
                'Production Barcode',
                Icons.grid_view,
                C.blue,
                    () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ProductionBarcodePage()),
                  );
                },
              ),
        */
              /*_tool(
                'Barcode Issue',
                Icons.grid_view,
                C.blue,
                    () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            BarcodeRegistrationView()),
                  );
                },
              ),
        */
              /* _tool(
                'Barcode Audit Check',
                Icons.grid_view,
                C.blue,
                    () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            BarcodeAuditScreen()),
                  );
                },
              ),*/
              /* _tool(
                'Asset Barcode/Qrcode',
                Icons.grid_view,
                C.blue,
                    () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            AssetbarcodeScreen()),
                  );
                },
              ),*/

            ],
          ),
          sectionTitle('At a glance'),
          GridView.count(
            crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 9, crossAxisSpacing: 9,childAspectRatio: isMobile! ? 1.25 : 1.9,
            children: [
              kpiTile(context,'MT today', '${k.mtToday}/${k.mtTarget}', tone: k.mtToday >= k.mtTarget ? 'good' : 'warn'),
              kpiTile(context,'CCR load', '${k.galvLoad}%', tone: k.galvLoad >= 95 ? 'warn' : 'good'),
              kpiTile(context,'OEE', '${k.oee}%', tone: _cls(k.oee, 75, 65)),
              kpiTile(context,'OTIF', '${k.otif}%', tone: _cls(k.otif, 90, 80)),
              kpiTile(context,'Red orders', '${k.redOrders}', tone: 'bad'),
              kpiTile(context,'WIP', '${k.wipMT} MT'),
            ],
          ),
          sectionTitle('Constraint (CCR)', trailing: GestureDetector(onTap: () => onTab(1), child: Text('Shop floor ›', style: body(11, w: FontWeight.w600, c: C.blue)))),
          card(Row(children: [
            gauge(k.ccrLoadPct, C.amber, size: 100),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(k.drum, style: sora(15, c: C.deep)),
              const SizedBox(height: 5),
              Text('${k.ccrLoadMT} / ${k.ccrCapMT} MT planned · ${k.ccrBatchesDone}/${k.ccrBatchesTotal} batches done.', style: body(12, c: C.ink)),
              const SizedBox(height: 6),
              pill(k.ccrStatus, 'amber'),
            ])),
          ])),
          sectionTitle('Needs attention', trailing: GestureDetector(onTap: () => onTab(2), child: Text('All (${k.openAlerts}) ›', style: body(11, w: FontWeight.w600, c: C.blue)))),
          ...k.alerts.where((a) => a.status == 'open').take(3).map((a) => alertCard(context, a)),
          sectionTitle('Today'),
          card(Column(children: [
            _todayRow('Plan', '${k.ccrBatchesTotal} galv batches · target ${k.mtTarget} MT', 'Focus: ${k.todayFocus}'),
            _todayRow('14:00', 'Client inspection', k.todayInspection),
            _todayRow('17:30', 'Dispatch', k.todayDispatch),
          ])),
          sectionTitle('Performance (5 days)'),
          card(Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('OEE %', style: body(11, w: FontWeight.w600, c: C.mut)), const SizedBox(height: 4), Sparkline(k.oeeTrend, C.blue)])),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Throughput MT', style: body(11, w: FontWeight.w600, c: C.mut)), const SizedBox(height: 4), Sparkline(k.mtTrend, C.green)])),
          ])),
        ]))),
      ),
    );
  }

  Widget _hero(Gradient g, IconData? ic, String t, String d, Color sub, {String? avatar}) => Container(
    margin: const EdgeInsets.only(bottom: 11),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(gradient: g, borderRadius: BorderRadius.circular(16)),
    child: Row(children: [
      Container(width: 42, height: 42, alignment: Alignment.center, decoration: BoxDecoration(color: Colors.white.withOpacity(.18), borderRadius: BorderRadius.circular(12)),
          child: avatar != null ? Text(avatar, style: sora(18, c: Colors.white)) : Icon(ic, color: Colors.white)),
      const SizedBox(width: 13),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: sora(14, c: Colors.white)), const SizedBox(height: 3), Text(d, style: body(11.5, c: sub))])),
      const Icon(Icons.chevron_right, color: Colors.white70),
    ]),
  );

/*  Widget _tool(String label, IconData ic, Color color, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: C.line), boxShadow: [BoxShadow(color: const Color(0xFF12426E).withOpacity(.06), blurRadius: 8, offset: const Offset(0, 4))]),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(width: isMobile! ? 36:26, height: isMobile! ? 36:26, alignment: Alignment.center, decoration: BoxDecoration(color: color.withOpacity(.13), borderRadius: BorderRadius.circular(11)), child: Icon(ic, color: color, size: 19)),
            const SizedBox(height: 7),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: Text(label, textAlign: TextAlign.center, style: body(11, w: FontWeight.w600, c: C.deep))),
          ]),
        ),
      );*/
  Widget _tool(
      String label,
      IconData ic,
      Color color,
      VoidCallback onTap,
      ) =>
      GestureDetector(
        onTap: onTap,
        child: SizedBox(
          height: isMobile! ? 110 : 25, // Smaller height on Windows
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile! ? 8 : 6,
              vertical: isMobile! ? 10 : 6,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: C.line),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF12426E).withOpacity(.06),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: isMobile! ? 38 : 28,
                  height: isMobile! ? 38 : 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color.withOpacity(.13),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    ic,
                    color: color,
                    size: isMobile! ? 20 : 16,
                  ),
                ),
                SizedBox(height: isMobile! ? 8 : 5),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: body(
                    isMobile! ? 11 : 10,
                    w: FontWeight.w600,
                    c: C.deep,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  Widget _todayRow(String tm, String t, String d) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 48, child: Text(tm, style: mono(11.5, c: C.slate))),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: body(12.5, w: FontWeight.w600)), Text(d, style: body(11, c: C.mut))])),
    ]),
  );
}

/// Shared alert card.
Widget alertCard(BuildContext context, AlertItem a, {VoidCallback? after}) {
  final tyc = a.sev == 'red' ? C.red : (a.sev == 'amber' ? C.amber : C.blue);
  return GestureDetector(
    onTap: () async {
      await Navigator.of(context).push(MaterialPageRoute(builder: (_) => DetailScaffold(title: 'Action detail', subtitle: '', child: AlertsList(showAppBar: false,))));
      if (after != null) after();
    },
    child: Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(13), border: Border.all(color: C.line), boxShadow: [BoxShadow(color: const Color(0xFF12426E).withOpacity(.06), blurRadius: 8, offset: const Offset(0, 4))]),
      child: Opacity(
        opacity: a.status == 'ack' ? .55 : 1,
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 4, height: 44, decoration: BoxDecoration(color: tyc, borderRadius: BorderRadius.circular(4))),
          const SizedBox(width: 11),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text('${a.type} · ${a.area}'.toUpperCase(), style: body(10, w: FontWeight.w700, c: tyc)),
              const Spacer(),
              Text(a.time, style: mono(10.5, c: C.mut)),
            ]),
            const SizedBox(height: 5),
            Text(a.title, style: body(13, w: FontWeight.w600)),
            const SizedBox(height: 3),
            Text(a.detail, style: body(11.5, c: C.mut)),
          ])),
        ]),
      ),
    ),
  );
}

/// ===================== SHOP FLOOR =====================
class ShopFloorScreen extends StatelessWidget {
  const ShopFloorScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 700;

    final p = plant;
    final down = p.machines.where((m) => !m.working).toList();
    return Center(
        child: Container(
            height: MediaQuery.of(context).size.height,
            color:const Color(0xFFF5F7FB),
            width: isDesktop ? 700 : double.infinity,
            padding: const EdgeInsets.all(10),
            child:ListView(padding: const EdgeInsets.all(14), children: [
      sectionTitle('CCR — the drum', trailing: GestureDetector(onTap: () => pushPage(context, 'Buffer board', 'Work the reds first', const BufferBoardScreen()), child: Text('Buffer board ›', style: body(11, w: FontWeight.w600, c: C.blue)))),
      card(Row(children: [
        gauge(p.ccrLoadPct, C.amber, size: 100),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(p.drum, style: sora(15, c: C.deep)),
          const SizedBox(height: 5),
          Text('${p.ccrLoadMT} / ${p.ccrCapMT} MT today.\n${p.ccrBatchesDone} of ${p.ccrBatchesTotal} batches complete.', style: body(12, c: C.ink)),
          const SizedBox(height: 6),
          pill(p.ccrStatus, 'amber'),
        ])),
      ])),
      sectionTitle('Today\u2019s plan on the CCR', trailing: GestureDetector(onTap: () => pushPage(context, 'Drum sequencing', 'Galvanizing kettle', const DrumSeqScreen()), child: Text('Re-sequence ›', style: body(11, w: FontWeight.w600, c: C.blue)))),
      card(Column(children: [
        for (final b in p.ccrPlan)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(children: [
              SizedBox(width: 46, child: Text(b.time, style: mono(11.5, c: C.slate))),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(b.label, style: body(12.5, w: FontWeight.w600)), Text(b.mt, style: body(11, c: C.mut))])),
              pill(b.status, b.status == 'done' ? 'green' : (b.status == 'running' ? 'amber' : 'slate')),
            ]),
          ),
      ])),
      sectionTitle('Other plans — feeders to the drum'),
      card(Column(children: [
        for (final f in p.feeders) Padding(padding: const EdgeInsets.only(bottom: 6), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Text(f[0] as String, style: body(12, w: FontWeight.w600)), const Spacer(), Text(f[2] as String, style: body(11, c: C.mut))]),
          barRow('', f[1] as int),
        ])),
      ])),
      sectionTitle('Live shop-floor status'),
      GridView.count(
        crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 9, crossAxisSpacing: 9, childAspectRatio: 1.7,
        children: [for (final m in p.machines) _machineTile(context, m)],
      ),
      sectionTitle('Machines not working today (${down.length})'),
      card(Column(children: [
        for (final m in down)
          ListTile(
            contentPadding: EdgeInsets.zero, dense: true,
            leading: CircleAvatar(backgroundColor: (m.status == 'down' ? C.redp : C.bluep), child: statusDot(C.status(m.status))),
            title: Text('${m.id} · ${m.area}', style: body(13, w: FontWeight.w600)),
            subtitle: Text(m.job, style: body(11, c: C.mut)),
            trailing: pill(C.statusLabel(m.status), m.status == 'down' ? 'red' : 'blue'),
            onTap: () => pushPage(context, 'Machine', '', MachineDetailScreen(id: m.id)),
          ),
      ])),
    ])));
  }

  Widget _machineTile(BuildContext context, Machine m) => GestureDetector(
    onTap: () => pushPage(context, 'Machine', '', MachineDetailScreen(id: m.id)),
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(13), border: Border.all(color: C.line)),
      child: IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(width: 4, decoration: BoxDecoration(color: C.status(m.status), borderRadius: BorderRadius.circular(3))),
          const SizedBox(width: 9),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(m.id, style: sora(12.5, c: C.deep)),
            Text(C.statusLabel(m.status) + (m.status == 'running' ? ' · ${m.util}%' : ''), style: body(10.5, w: FontWeight.w600, c: C.status(m.status))),
            const SizedBox(height: 5),
            Text(m.job, style: body(10.5, c: C.mut), maxLines: 2, overflow: TextOverflow.ellipsis),
          ])),
        ]),
      ),
    ),
  );
}

class MachineDetailScreen extends StatelessWidget {
  final String id;
  const MachineDetailScreen({super.key, required this.id});
  @override
  Widget build(BuildContext context) {
    final m = plant.machines.firstWhere((x) => x.id == id);
    return Column(children: [
      card(Row(children: [
        Container(width: 50, height: 50, alignment: Alignment.center, decoration: BoxDecoration(color: C.status(m.status), borderRadius: BorderRadius.circular(14)), child: Text(id.substring(0, 3), style: sora(13, c: Colors.white))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(m.id, style: sora(18, c: C.deep)), Text(m.area, style: body(12, c: C.mut))])),
        pill(C.statusLabel(m.status), m.status == 'down' ? 'red' : (m.status == 'running' ? 'green' : (m.status == 'pm' ? 'blue' : 'slate'))),
      ])),
      card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        sectionTitle('Status'),
        _kv('Current job', m.job),
        if (m.util > 0) _kv('Utilisation', '${m.util}%'),
        if (m.oee > 0) _kv('OEE', '${m.oee}%'),
      ])),
      if (id == 'CNC-124T2')
        card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          sectionTitle('AI prediction'),
          escBox('Failure risk 78% within 36 h\n→ Inspect tonight; pre-stage CNC-124T1.', sev: 'red'),
        ])),
      Row(children: [
        Expanded(child: _btn2('Ask Copilot', C.amber, const Color(0xFF3A2406), () => pushCopilot(context))),
        const SizedBox(width: 9),
        Expanded(child: _btn2('Back', C.panel, C.deep, () => Navigator.pop(context))),
      ]),
    ]);
  }

  Widget _kv(String k, String v) => Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(children: [Expanded(child: Text(k, style: body(13, w: FontWeight.w600))), Text(v, style: mono(13, c: C.deep))]));
}

/// ===================== ALERTS =====================
/*class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});
  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  @override
  Widget build(BuildContext context) {
    final open = plant.alerts.where((a) => a.status == 'open').toList();
    final ack = plant.alerts.where((a) => a.status != 'open').toList();
    return ListView(padding: const EdgeInsets.all(14), children: [
      sectionTitle('Open · escalations & warnings (${open.length})'),
      ...open.map((a) => alertCard(context, a, after: () => setState(() {}))),
      if (ack.isNotEmpty) sectionTitle('Acknowledged'),
      ...ack.map((a) => alertCard(context, a, after: () => setState(() {}))),
    ]);
  }
}

class AlertDetailScreen extends StatefulWidget {
  final int id;
  const AlertDetailScreen({super.key, required this.id});
  @override
  State<AlertDetailScreen> createState() => _AlertDetailScreenState();
}

class _AlertDetailScreenState extends State<AlertDetailScreen> {
  static const ladder = ['L1 Supervisor', 'L2 Plant Head', 'L3 Ops Head', 'L4 MD'];

  @override
  Widget build(BuildContext context) {
    final a = plant.alerts.firstWhere((x) => x.id == widget.id);
    return Column(children: [
      card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        pill('${a.type} · ${a.area}', a.sev == 'red' ? 'red' : (a.sev == 'amber' ? 'amber' : 'blue')),
        const SizedBox(height: 11),
        Text(a.title, style: sora(17, c: C.deep)),
        const SizedBox(height: 6),
        Text(a.detail, style: body(13, c: C.ink)),
      ])),
      card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        sectionTitle('Recommended action'),
        escBox('→ ${a.action}', sev: a.sev == 'amber' ? 'amber' : 'red'),
        const SizedBox(height: 8),
        Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Owner', style: body(13, w: FontWeight.w600)), Text(a.owner, style: body(11.5, c: C.mut))])), pill(a.sla, 'slate')]),
        const SizedBox(height: 12),
        Text('ESCALATION LADDER', style: body(11, w: FontWeight.w600, c: C.mut)),
        const SizedBox(height: 7),
        Row(children: [
          for (var i = 0; i < ladder.length; i++)
            Expanded(child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 2),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: i + 1 < a.level ? C.deep : (i + 1 == a.level ? C.amber : C.panel),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: i + 1 == a.level ? C.amber : C.line),
              ),
              child: Text(ladder[i], textAlign: TextAlign.center, style: body(9.5, w: FontWeight.w600, c: i + 1 <= a.level ? (i + 1 == a.level ? const Color(0xFF3A2406) : Colors.white) : C.mut)),
            )),
        ]),
      ])),
      if (a.status == 'open') ...[
        Row(children: [
          Expanded(child: _btn2('Resolve', C.blue, Colors.white, () { setState(() => a.status = 'ack'); toast(context, 'Action resolved & closed'); Navigator.pop(context); })),
          const SizedBox(width: 9),
          Expanded(child: _btn2('Escalate ↑', C.amber, const Color(0xFF3A2406), () { setState(() { a.level = (a.level + 1).clamp(1, 4); a.owner = '${ladder[a.level - 1]} (notified)'; }); toast(context, 'Escalated to ${ladder[a.level - 1]}'); })),
        ]),
        const SizedBox(height: 9),
        _btn2('Ask Copilot', C.panel, C.deep, () => pushCopilot(context)),
      ] else
        card(Center(child: Text('✓ Resolved & closed', style: body(13, w: FontWeight.w600, c: C.green))), color: C.greenp),
    ]);
  }
}*/

/// ===================== REPORTS / MIS =====================
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final reps = [
      ['production', 'Production summary', 'Today vs target, MT trend', C.blue],
      ['oee', 'OEE & utilisation', 'By machine, with the drum', C.teal],
      ['otif', 'Delivery / OTIF', 'On-time-in-full trend', C.green],
      ['scrap', 'Scrap & quality', 'Scrap %, COPQ drivers', C.amber],
      ['buffer', 'Buffer / material', 'Steel section buffers', C.red],
      ['dispatch', 'Dispatch / MIS', 'Tonnage shipped by day', C.slate],
    ];
    return ListView(padding: const EdgeInsets.all(14), children: [
      sectionTitle('Reports & MIS'),
      _row(context, Icons.show_chart, C.deep, 'Throughput / drum-hour', '₹ per galvanizing hour · TOC priority', () => pushPage(context, 'Throughput', '₹ per drum-hour', const ThroughputScreen())),
      ...reps.map((r) => _row(context, Icons.bar_chart, r[3] as Color, r[1] as String, r[2] as String, () => pushPage(context, r[1] as String, '', ReportDetailScreen(id: r[0] as String)))),
    ]);
  }

  Widget _row(BuildContext c, IconData ic, Color col, String t, String d, VoidCallback onTap) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Container(width: 38, height: 38, alignment: Alignment.center, decoration: BoxDecoration(color: col.withOpacity(.12), borderRadius: BorderRadius.circular(11)), child: Icon(ic, color: col, size: 18)),
    title: Text(t, style: body(13.5, w: FontWeight.w600)),
    subtitle: Text(d, style: body(11.5, c: C.mut)),
    trailing: const Icon(Icons.chevron_right, color: Color(0xFFB8C5D4)),
    onTap: onTap,
  );
}

class ReportDetailScreen extends StatelessWidget {
  final String id;
  const ReportDetailScreen({super.key, required this.id});
  @override
  Widget build(BuildContext context) {
    final p = plant;
    Widget content;
    switch (id) {
      case 'production':
        content = card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [sectionTitle('Production · last 5 days (MT)'), VBars(p.mtTrend, C.blue), const SizedBox(height: 8), Text('Today: ${p.mtToday} / ${p.mtTarget} MT', style: mono(13, c: C.deep))]));
        break;
      case 'oee':
        content = card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [sectionTitle('OEE by machine'), ...p.oeeByMc.map((m) => barRow(m[0] as String, m[1] as int)), const SizedBox(height: 6), Text('Plant OEE ${p.oee}% · target 75%', style: body(11, c: C.mut))]));
        break;
      case 'otif':
        content = card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [sectionTitle('OTIF % · 5 days'), Sparkline(p.otifTrend, C.green), const SizedBox(height: 8), Text('Latest ${p.otif}% · target 90%', style: body(12, c: C.ink))]));
        break;
      case 'scrap':
        content = card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [sectionTitle('Scrap % · 5 days'), Sparkline(p.scrapTrend, C.amber), const SizedBox(height: 8), Text('Latest ${p.scrap}% · target 3.5% · driver: re-drilling on ISA 50×50×5', style: body(12, c: C.ink))]));
        break;
      case 'buffer':
        content = card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [sectionTitle('Steel section buffers'), ...p.sectionsBuffer.map((s) => barRow(s[0] as String, s[1] as int)), escBox('→ ISA 90×90×6 in the red — expedite; it feeds the drum.', sev: 'red')]));
        break;
      default:
        content = card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [sectionTitle('Dispatch (MT) this week'), VBars(p.dispatchWk.map((d) => d[1] as num).toList(), C.slate), const SizedBox(height: 6), Text(p.dispatchWk.map((d) => d[0]).join(' · '), style: body(11, c: C.mut))]));
    }
    return Column(children: [
      content,
      Row(children: [
        Expanded(child: _btn2('Ask about this', C.amber, const Color(0xFF3A2406), () => pushCopilot(context))),
        const SizedBox(width: 9),
        Expanded(child: _btn2('Back', C.panel, C.deep, () => Navigator.pop(context))),
      ]),
    ]);
  }
}

Widget _btn2(String label, Color bg, Color fg, VoidCallback onTap) => GestureDetector(
  onTap: onTap,
  child: Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    alignment: Alignment.center,
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(11), border: bg == C.panel ? Border.all(color: C.line) : null),
    child: Text(label, style: sora(13, c: fg)),
  ),
);
