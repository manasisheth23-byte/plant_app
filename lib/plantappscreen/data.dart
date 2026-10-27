/// ---------------------------------------------------------------------------
/// Mock plant state for the Cloud 9 Plant App prototype.
///
/// FLUTTER / BACKEND TEAM: replace this whole file with live data from your API
/// (e.g. GET /state, /alerts, /reports, /journey). The widget tree only depends
/// on the `plant` instance and these model classes, so swapping the source is
/// localised here. The drum / constraint is GALVANIZING — all logic subordinates
/// to it.
/// ---------------------------------------------------------------------------

class Machine {
  final String id, area, status, job;
  final int util, oee;
  Machine(this.id, this.area, this.status, this.util, this.oee, this.job);
  bool get working => !(status == 'down' || status == 'pm' || status == 'noplan');
}

class AlertItem {
  final int id;
  final String sev, type, area, title, detail, action, time;
  String status; // open | ack
  String owner, sla;
  int level; // 1..4 escalation ladder
  AlertItem(this.id, this.sev, this.type, this.area, this.title, this.detail,
      this.action, this.time, this.status,
      {this.owner = 'Unassigned', this.sla = '—', this.level = 1});
}

class BufferOrder {
  final String wo, ct, zone, trend, cause, slot;
  final int pen;
  BufferOrder(this.wo, this.ct, this.zone, this.pen, this.trend, this.cause, this.slot);
}

class DbmRec {
  final String item, signal, rec, dir; // dir: up | down
  bool applied = false;
  DbmRec(this.item, this.signal, this.rec, this.dir);
}

class OpStep {
  final String name, status, time; // done | running | queued | staged
  OpStep(this.name, this.status, this.time);
}

class TraceOrder {
  final String wo, ct, mark, zone, ready, qc, galv, dispatch;
  final int pen;
  final List<String> heat;
  final List<OpStep> ops;
  TraceOrder(this.wo, this.ct, this.mark, this.zone, this.pen, this.ready,
      this.heat, this.qc, this.galv, this.dispatch, this.ops);
}

class TputItem {
  final String item, t;
  final int tHr;
  final double min;
  TputItem(this.item, this.tHr, this.min, this.t);
}

class Batch {
  String time;
  final String label, mt;
  final String status; // done | running | queued
  Batch(this.time, this.label, this.mt, this.status);
  double get mtValue => double.tryParse(mt.split(' ').first) ?? 0;
}

class QcsLine {
  final String item, due;
  final int sets;
  QcsLine(this.item, this.sets, this.due);
}

class SapWO {
  final String wo, desc, qty, mt, status;
  SapWO(this.wo, this.desc, this.qty, this.mt, this.status);
}

class DdmrpRow {
  final String section, onHand, onOrder, demand, zone, replenish;
  final int netflow;
  DdmrpRow(this.section, this.onHand, this.onOrder, this.demand, this.netflow,
      this.zone, this.replenish);
}

class KitRow {
  final String wo, verdict, missing;
  final bool steel, bolt, nc;
  KitRow(this.wo, this.steel, this.bolt, this.nc, this.verdict, this.missing);
}

class PromiseRow {
  final String item, reqDate, promised, status, note;
  PromiseRow(this.item, this.reqDate, this.promised, this.status, this.note);
}

class MachineSched {
  final String machine;
  final List<List<String>> jobs; // [time, job]
  MachineSched(this.machine, this.jobs);
}

class JourneyStage {
  final String title, blurb;
  final bool done;
  JourneyStage(this.title, this.blurb, this.done);
}

class PlantData {
  String plant = 'Gandhinagar';
  String drum = 'Galvanizing Kettle GL-1';
  final String date = 'Wednesday, 11 Jun';

  // KPIs
  int mtToday = 142, mtTarget = 165, galvLoad = 96, oee = 71, otif = 88, redOrders = 3, wipMT = 612;
  double scrap = 4.1;

  // CCR
  int ccrCapMT = 165, ccrLoadMT = 158, ccrLoadPct = 96, ccrBatchesDone = 4, ccrBatchesTotal = 9;
  String ccrStatus = 'At capacity — protect the drum';

  List<Batch> ccrPlan = [
    Batch('07:00', 'Batch 1 · WO-00247 body', '18 MT', 'done'),
    Batch('08:30', 'Batch 2 · WO-00250 ext', '16 MT', 'done'),
    Batch('10:00', 'Batch 3 · WO-00251 ext', '17 MT', 'done'),
    Batch('11:30', 'Batch 4 · WO-00248-STUB', '15 MT', 'running'),
    Batch('13:30', 'Batch 5 · WO-00247 body', '19 MT', 'queued'),
    Batch('15:00', 'Batch 6 · GETCO PP set', '18 MT', 'queued'),
    Batch('16:30', 'Batch 7 · GETCO PP set', '17 MT', 'queued'),
    Batch('18:00', 'Batch 8 · WO-00253', '16 MT', 'queued'),
    Batch('19:30', 'Batch 9 · WO-00254', '12 MT', 'queued'),
  ];

  List<List<dynamic>> feeders = [
    ['CNC punching', 82, 'WO-00248 stub members'],
    ['Notching', 68, 'WO-00251 cleats'],
    ['Bending', 74, 'WO-00247 bracings'],
    ['Inspection', 61, 'GETCO black insp.'],
  ];

  List<Machine> machines = [
    Machine('CNC-124T1', 'CNC punching', 'running', 88, 79, 'WO-00248 stub members'),
    Machine('CNC-124T2', 'CNC punching', 'down', 0, 0, 'Spindle vibration — predicted fail (78%)'),
    Machine('NOTCH-1', 'Notching', 'running', 71, 72, 'WO-00251 cleats'),
    Machine('HP-1L', 'Bending', 'setup', 40, 68, 'Changeover → WO-00247'),
    Machine('HP-2L', 'Bending', 'running', 79, 75, 'WO-00247 bracings'),
    Machine('GL-1', 'Galvanizing (DRUM)', 'running', 96, 82, 'Batch 4 · WO-00248-STUB'),
    Machine('INSP-1', 'Inspection', 'idle', 61, 0, 'Awaiting galv output'),
    Machine('MILL-3', 'Milling', 'pm', 0, 0, 'Planned maintenance 06:00–10:00'),
    Machine('DRILL-2', 'Drilling', 'noplan', 0, 0, 'No plan loaded today'),
  ];

  // Yesterday / performance
  String yTopDowntime = 'CNC-124T2 — 47 min (spindle tool change)';
  int yMtActual = 158, yMtPlan = 165, yOee = 73, yOtif = 90;
  double yScrap = 4.1;
  List<int> oeeTrend = [69, 72, 70, 73, 71];
  List<int> mtTrend = [150, 162, 148, 158, 142];
  List<int> otifTrend = [86, 89, 87, 90, 88];
  List<double> scrapTrend = [4.6, 4.2, 4.4, 4.1, 4.1];
  List<List<dynamic>> oeeByMc = [['GL-1', 82], ['HP-2L', 75], ['CNC-124T1', 79], ['NOTCH-1', 72], ['HP-1L', 68]];
  List<List<dynamic>> dispatchWk = [['Mon', 16], ['Tue', 22], ['Wed', 18], ['Thu', 24], ['Fri', 20]];
  List<List<dynamic>> sectionsBuffer = [['ISA 90×90×6', 18, 'red'], ['ISA 50×50×5', 41, 'amber'], ['ISA 45×45×4', 54, 'green'], ['ISP 06MM plate', 62, 'green']];

  // Today / tomorrow
  String todayFocus = 'CT24Y-00010 · GETCO 66 kV PP';
  String todayInspection = '14:00 — GETCO QA';
  String todayDispatch = '18 MT → Soja, 17:30';
  String tomPm = 'PM on Bending HP-1L · 06:00–08:00';
  String tomInspection = '11:00 — MSEDCL inspection';
  String tomDispatch = '24 MT → Mehsana';
  String tomNote = 'Galv shift-B short 2 operators';

  List<AlertItem> alerts = [
    AlertItem(1, 'red', 'Escalation', 'Orders', 'WO24Y-00248-STUB in the red buffer',
        'Penetrated the red zone — will miss today\'s galvanizing slot.',
        'Expedite to galv Batch 4; pull stub members ahead at CNC-124T1.', '08:12', 'open',
        owner: 'A. Patil · Supervisor', sla: 'Due 12:30', level: 1),
    AlertItem(2, 'red', 'Escalation', 'Machine', 'CNC-124T2 likely to fail in 36 h (78%)',
        'Spindle vibration trending up; it feeds the drum.',
        'Inspect tonight; pre-stage CNC-124T1 for its load.', '07:48', 'open',
        owner: 'Maintenance lead', sla: 'Due tonight (PM)', level: 2),
    AlertItem(3, 'red', 'Warning', 'Material', 'ISA 90×90×6 buffer at 18%',
        'Top-runner section (~69% tonnage); ~2 days cover; feeds the drum.',
        'Expedite open PO / release replenishment today.', '07:30', 'open',
        owner: 'Stores in-charge', sla: 'Due 13:00', level: 1),
    AlertItem(4, 'amber', 'Warning', 'Manpower', 'Galvanizing shift-B short 2 operators tomorrow',
        'Absentee forecast on the drum.',
        'Reallocate 2 from Inspection (61% utilised).', '06:55', 'open',
        owner: 'Shift in-charge', sla: 'Due EOD', level: 1),
    AlertItem(5, 'amber', 'Alert', 'Quality', 'Scrap at 4.1% — above 3.5% target',
        'Driven by re-drilling on ISA 50×50×5.',
        'Review cutting plan / nesting for the section.', 'Yest 21:10', 'ack'),
    AlertItem(6, 'blue', 'Alert', 'Dispatch', 'GETCO client inspection at 14:00',
        'Tangent body, 220 sets — must clear before 17:30 dispatch.',
        'Ensure Batch 4–6 galvanized & inspected by 13:30.', '06:30', 'open',
        owner: 'QA lead', sla: 'Due 13:30', level: 1),
  ];

  int get openAlerts => alerts.where((a) => a.status == 'open').length;

  // Buffer board
  List<BufferOrder> bufferOrders = [
    BufferOrder('WO24Y-00248-STUB', 'GETCO 66kV PP', 'red', 92, 'up', 'Held at CNC-124T2 (down)', 'Galv Batch 4 today'),
    BufferOrder('WO24Y-00253', 'GETCO 66kV PP', 'red', 81, 'up', 'ISA 90×90×6 shortage', 'Galv Batch 8 today'),
    BufferOrder('WO24Y-00247', 'GETCO 66kV PP', 'amber', 58, 'up', 'Bending changeover queue', 'Galv Batch 5'),
    BufferOrder('WO24Y-00251', 'GETCO 66kV PP', 'amber', 46, 'flat', 'Normal flow', 'Galv Batch 3 (done)'),
    BufferOrder('WO24Y-00250', 'GETCO 66kV PP', 'green', 22, 'flat', 'On track', 'Galv Batch 2 (done)'),
    BufferOrder('WO24Y-00254', 'MSEDCL 132kV', 'green', 14, 'down', 'Ahead of buffer', 'Galv Batch 9'),
  ];

  List<DbmRec> dbm = [
    DbmRec('Time buffer · GETCO PP body', '5 of last 12 orders hit RED', 'Increase buffer 20% (1.5 → 1.8 days)', 'up'),
    DbmRec('Time buffer · Extensions', '9 of last 10 finished deep GREEN', 'Reduce buffer 15% — releasing too early, WIP high', 'down'),
    DbmRec('Stock buffer · ISA 90×90×6', '3 stock-out risks in 10 days', 'Raise red zone; expedite replenishment', 'up'),
  ];

  // Track & trace
  Map<String, TraceOrder> trace = {
    'WO24Y-00248-STUB': TraceOrder(
        'WO24Y-00248-STUB', 'CT24Y-00010 · GETCO 66kV PP', 'SP-932-PP-STUB × 220', 'red', 92,
        'Today 16:40 (at risk)', ['H-24117 · SAIL · ISA 90×90×6', 'H-24102 · JSW · ISA 50×50×5'],
        'Black inspection PASS · galv pending', 'Batch 4 (running)', 'Soja · target 17:30 (at risk)', [
      OpStep('Cutting', 'done', '06:10'), OpStep('CNC punching', 'done', '07:25'),
      OpStep('Notching', 'done', '08:40'), OpStep('Bending', 'done', '09:30'),
      OpStep('Black inspection', 'done', '10:15'), OpStep('Galvanizing', 'running', '11:30'),
      OpStep('Galv inspection', 'queued', '—'), OpStep('Dispatch', 'queued', '—'),
    ]),
    'WO24Y-00247': TraceOrder(
        'WO24Y-00247', 'CT24Y-00010 · GETCO 66kV PP', 'SP-932-PP body × 220', 'amber', 58,
        'Today 18:20', ['H-24117 · SAIL · ISA 90×90×6'], 'In-process', 'Batch 5 (queued)', 'Soja · 18:30', [
      OpStep('Cutting', 'done', '06:30'), OpStep('CNC punching', 'done', '08:00'),
      OpStep('Notching', 'done', '09:10'), OpStep('Bending', 'running', '10:40'),
      OpStep('Black inspection', 'queued', '—'), OpStep('Galvanizing', 'queued', '—'),
      OpStep('Galv inspection', 'queued', '—'), OpStep('Dispatch', 'queued', '—'),
    ]),
    'WO24Y-00250': TraceOrder(
        'WO24Y-00250', 'CT24Y-00010 · GETCO 66kV PP', 'PP +3M extension × 50', 'green', 22,
        'Done · galvanized', ['H-24090 · JSW · ISA 45×45×4'], 'PASS', 'Batch 2 (done)', 'Soja · staged', [
      OpStep('Cutting', 'done', '05:40'), OpStep('CNC punching', 'done', '06:50'),
      OpStep('Notching', 'done', '07:30'), OpStep('Bending', 'done', '08:10'),
      OpStep('Black inspection', 'done', '08:40'), OpStep('Galvanizing', 'done', '08:30'),
      OpStep('Galv inspection', 'done', '09:20'), OpStep('Dispatch', 'staged', '—'),
    ]),
  };

  // Throughput per drum-hour
  List<TputItem> tput = [
    TputItem('PP Tangent body (GETCO)', 148000, 9.2, '₹4.1 L/batch'),
    TputItem('PR Medium-angle body', 131000, 11.0, '₹3.8 L/batch'),
    TputItem('+9M / +12M extensions', 96000, 14.5, '₹2.9 L/batch'),
    TputItem('Stub (BC)', 71000, 6.0, '₹1.2 L/batch'),
    TputItem('A.C. device', 52000, 5.5, '₹0.7 L/batch'),
  ];

  // -------- Order Journey (end-to-end) --------
  String sync = 'SAP sync 11:42';
  String jContractId = 'CT24Y-00010', jContractName = 'GETCO 66 kV PP', jCustomer = 'GETCO';
  int jSets = 220, jTotalMT = 154;

  List<QcsLine> qcs = [
    QcsLine('PP template', 10, '18 Jun'),
    QcsLine('PP stub (BC)', 220, '22 Jun'),
    QcsLine('PP Tangent body', 120, '28 Jun'),
    QcsLine('PP +3M extension', 50, '28 Jun'),
  ];
  List<SapWO> sapWO = [
    SapWO('WO24Y-00251', 'PP template · SP-932-PP-T', '10', '6 MT', 'received'),
    SapWO('WO24Y-00248-STUB', 'PP stub (BC) · SP-932-PP-STUB', '220', '34 MT', 'received'),
    SapWO('WO24Y-00247', 'PP Tangent body · SP-932-PP-xx', '120', '96 MT', 'received'),
    SapWO('WO24Y-00250', 'PP +3M extension · SP-932-PP-E3', '50', '18 MT', 'received'),
  ];
  List<DdmrpRow> ddmrp = [
    DdmrpRow('ISA 90×90×6', '42 MT', '20 MT', '88 MT', 18, 'red', 'Release PO 60 MT'),
    DdmrpRow('ISA 50×50×5', '31 MT', '15 MT', '52 MT', 41, 'amber', 'Top-up 20 MT'),
    DdmrpRow('ISA 45×45×4', '58 MT', '10 MT', '49 MT', 54, 'green', '—'),
    DdmrpRow('ISP 06MM plate', '24 MT', '8 MT', '19 MT', 62, 'green', '—'),
  ];
  String boughtout = 'GI bolts & nuts — in stock · kit OK';
  List<KitRow> fullkit = [
    KitRow('WO24Y-00251', true, true, true, 'release', ''),
    KitRow('WO24Y-00248-STUB', false, true, true, 'hold', 'ISA 90×90×6 short'),
    KitRow('WO24Y-00247', true, true, true, 'release', ''),
    KitRow('WO24Y-00250', true, true, true, 'released', ''),
  ];
  List<PromiseRow> promise = [
    PromiseRow('PP template', '18 Jun', '17 Jun', 'early', 'CCR slack'),
    PromiseRow('PP stub (BC)', '22 Jun', '23 Jun', 'late', 'kit short — expedite ISA 90×90×6'),
    PromiseRow('PP Tangent body', '28 Jun', '26 Jun', 'early', ''),
    PromiseRow('PP +3M extension', '28 Jun', 'done', 'ok', 'galvanized'),
  ];
  List<MachineSched> machineSched = [
    MachineSched('GL-1 (drum)', [['11:30', 'WO-00248-STUB'], ['13:30', 'WO-00247 body'], ['15:00', 'GETCO PP set']]),
    MachineSched('CNC-124T1', [['now', 'WO-00248 stub'], ['12:30', 'WO-00247 body']]),
    MachineSched('HP-2L bending', [['now', 'WO-00247 bracings'], ['14:00', 'WO-00251']]),
    MachineSched('NOTCH-1', [['now', 'WO-00251 cleats']]),
  ];
  List<JourneyStage> stages = [
    JourneyStage('Demand in — SO & QCS receipt', 'Order + delivery schedule from SAP', true),
    JourneyStage('Work orders from SAP', 'WOs received & mapped to mark numbers', true),
    JourneyStage('DDMRP — material readiness', 'Net-flow buffers; replenishment signals', true),
    JourneyStage('Full-kit availability check', 'Release only complete kits', false),
    JourneyStage('CCR scheduling & delivery promise', 'Drum schedule, dates vs QCS, machine plans', false),
    JourneyStage('Execution — MES', 'Live floor, confirmations, traceability', false),
    JourneyStage('Monitor & deliver — MIS', 'Buffer, throughput, OEE, dispatch', false),
  ];
}

/// Global singleton (swap for a state-management solution in production).
final plant = PlantData();
