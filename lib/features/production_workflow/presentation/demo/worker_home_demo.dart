import 'package:flutter/foundation.dart';

import '../../../../core/theme/colors.dart';

/// A bilingual (English / Nepali) display string pair.
@immutable
class DemoText {
  const DemoText(this.en, this.ne);

  final String en;
  final String ne;

  /// Picks the string for a language code (`'ne'` → Nepali, else English).
  String resolve(String langCode) => langCode == 'ne' ? ne : en;
}

/// The per-garment production stage a job is currently in, as shown on the Worker Home queue.
enum WorkerStage { cutting, stitching, trial }

extension WorkerStageStyle on WorkerStage {
  StatusColor get colors {
    switch (this) {
      case WorkerStage.cutting:
        return StatusColors.cutting; // blue
      case WorkerStage.stitching:
        return StatusColors.stitching; // indigo
      case WorkerStage.trial:
        return StatusColors.trial; // amber
    }
  }

  /// i18n key for the stage label (chip + filter).
  String get labelKey {
    switch (this) {
      case WorkerStage.cutting:
        return 'worker_stage_cutting';
      case WorkerStage.stitching:
        return 'worker_stage_stitching';
      case WorkerStage.trial:
        return 'worker_stage_trial';
    }
  }
}

/// One job as shown on the Worker Home queue.
@immutable
class WorkerJob {
  const WorkerJob({
    required this.garment,
    required this.order,
    required this.customer,
    required this.stage,
    required this.barcode,
    required this.due,
    required this.overdue,
    required this.priority,
  });

  final DemoText garment;
  final String order;
  final DemoText customer;
  final WorkerStage stage;
  final String barcode;
  final DemoText due;
  final bool overdue;
  final bool priority;
}

const DemoText demoWorkerBranch = DemoText(
  'New Road · Stitching unit',
  'नयाँ सडक · सिलाई इकाई',
);

/// The job queue, in the mockup's order.
const List<WorkerJob> demoWorkerJobs = [
  WorkerJob(
    garment: DemoText('Suit', 'सुट'),
    order: 'TS-1039',
    customer: DemoText('Bibek Thapa', 'विवेक थापा'),
    stage: WorkerStage.stitching,
    barcode: 'TS3901',
    due: DemoText('6 Jun', '६ जुन'),
    overdue: true,
    priority: false,
  ),
  WorkerJob(
    garment: DemoText('Daura Suruwal', 'दौरा सुरुवाल'),
    order: 'TS-1042',
    customer: DemoText('Ramesh Shrestha', 'रमेश श्रेष्ठ'),
    stage: WorkerStage.stitching,
    barcode: 'TS4101',
    due: DemoText('12 Jun', '१२ जुन'),
    overdue: false,
    priority: true,
  ),
  WorkerJob(
    garment: DemoText('Blouse', 'ब्लाउज'),
    order: 'TS-1041',
    customer: DemoText('Sita Gurung', 'सीता गुरुङ'),
    stage: WorkerStage.cutting,
    barcode: 'TS4110',
    due: DemoText('11 Jun', '११ जुन'),
    overdue: false,
    priority: false,
  ),
  WorkerJob(
    garment: DemoText('Coat', 'कोट'),
    order: 'TS-1045',
    customer: DemoText('Prakash Tamang', 'प्रकाश तामाङ'),
    stage: WorkerStage.trial,
    barcode: 'TS4501',
    due: DemoText('9 Jun', '९ जुन'),
    overdue: false,
    priority: false,
  ),
  WorkerJob(
    garment: DemoText('Kurta', 'कुर्ता'),
    order: 'TS-1044',
    customer: DemoText('Anjali Maharjan', 'अञ्जली महर्जन'),
    stage: WorkerStage.stitching,
    barcode: 'TS4410',
    due: DemoText('13 Jun', '१३ जुन'),
    overdue: false,
    priority: false,
  ),
  WorkerJob(
    garment: DemoText('Sari Blouse', 'चोलो'),
    order: 'TS-1033',
    customer: DemoText('Deepa Rai', 'दीपा राई'),
    stage: WorkerStage.cutting,
    barcode: 'TS3310',
    due: DemoText('13 Jun', '१३ जुन'),
    overdue: false,
    priority: false,
  ),
];
