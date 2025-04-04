import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/component/input/input_multi_line_field.dart';
import 'package:repathy/src/component/patient_list/patient_list_selection_body.dart';
import 'package:repathy/src/controller/form_controller/form_controller.dart';
import 'package:repathy/src/controller/patient_controller/patient_controller.dart';
import 'package:repathy/src/controller/patient_transfer_controller/patient_transfer_controller.dart';
import 'package:repathy/src/controller/therapist_controller/therapist_controller.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';
import 'package:repathy/src/theme/styles.dart';

class PatientTransferCard extends ConsumerStatefulWidget {
  const PatientTransferCard({
    super.key,
    this.elements,
    this.textController,
    this.leftPadding = 0,
    this.topPadding = 8,
    this.rightPadding = 0,
    this.bottomPadding = 8,
    this.internalLeftPadding = 16,
    this.internalTopPadding = 32,
    this.internalRightPadding = 16,
    this.internalBottomPadding = 0,
    this.widthScale = 0.85,
    this.initialHeight = 110,
    this.extendedHeight = 300,
    required this.step,
    required this.title,
    required this.description,
  });

  final List<UserModel>? elements;
  final TextEditingController? textController;
  final double leftPadding;
  final double topPadding;
  final double rightPadding;
  final double bottomPadding;
  final double internalLeftPadding;
  final double internalTopPadding;
  final double internalRightPadding;
  final double internalBottomPadding;
  final double widthScale;
  final double initialHeight;
  final double extendedHeight;
  final String title;
  final String description;
  final int step;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PatientTransferCardState();
}

class _PatientTransferCardState extends ConsumerState<PatientTransferCard> {
  List<UserModel>? userList = [];
  final scrollController = ScrollController();

  @override
  void initState() {
    loadDependencies();
    super.initState();
  }

  void loadDependencies() {
    if (widget.step == 1) userList = widget.elements;
    if (widget.step == 2) userList = widget.elements;
    debugPrint('View: patientsList: ${userList?.length} and step: ${widget.step}');
    debugPrint('View: therapistsList: ${userList?.length} and step: ${widget.step}');
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patientTransferController = ref.watch(patientTransferControllerProvider(widget.step));
    ref.listen(filteredPatientsForSelectionListProvider(userList), (_,__){});
    ref.listen(selectedPatientsProvider(userList), (_,__){});
    ref.listen(syncFilteredPatientsProvider, (_,__){});
    ref.listen(syncFilteredTherapistsProvider, (_,__){});

    return GestureDetector(
      onTap: () => ref.read(patientTransferControllerProvider(widget.step).notifier).toggleState(),
      child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.fromLTRB(
            widget.internalLeftPadding,
            widget.internalTopPadding,
            widget.internalRightPadding,
            widget.internalBottomPadding,
          ),
          margin: EdgeInsets.fromLTRB(
            widget.leftPadding,
            widget.topPadding,
            widget.rightPadding,
            widget.bottomPadding,
          ),
          height: patientTransferController ? widget.extendedHeight : widget.initialHeight,
          width: MediaQuery.sizeOf(context).width * widget.widthScale,
          decoration: BoxDecoration(
            color: RepathyStyle.backgroundColor,
            borderRadius: BorderRadius.circular(RepathyStyle.roundedRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.grey[300]!,
                offset: Offset(4, 2),
                blurRadius: 10,
              ),
            ],
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: RepathyStyle.defaultTextColor,
                    fontSize: RepathyStyle.standardTextSize,
                    fontWeight: RepathyStyle.semiBoldFontWeight,
                  ),
                ),
                Text(
                  widget.description,
                  style: const TextStyle(
                    color: RepathyStyle.defaultTextColor,
                    fontSize: RepathyStyle.smallTextSize,
                    fontWeight: RepathyStyle.lightFontWeight,
                  ),
                ),
                if (patientTransferController) ...[
                  if (userList != null && widget.step == 1) ...[
                    PatientListPageSelectionBody(userModelList: userList!, height: 180, isMultiSelect: false),
                  ],
                  if (userList != null && widget.step == 2) ...[
                    PatientListPageSelectionBody(userModelList: userList!, height: 170, isMultiSelect: false),
                  ],
                  if (widget.step == 3 && widget.textController != null) ...[
                    InputMultiLineField(
                      controller: widget.textController!,
                      name: 'Descrizione',
                      validator: (value) => ref.read(formControllerProvider.notifier).validateOptionalField(value),
                      leftPadding: 0,
                      topPadding: 16,
                      rightPadding: 0,
                      bottomPadding: 8,
                    ),
                  ],
                ],
              ],
            ),
          )),
    );
  }
}
