import 'package:flutter/material.dart';
import 'package:flutter_painter/flutter_painter.dart';
import 'package:flutter_painter/src/controllers/items/text_item.dart';
import 'package:flutter_painter/src/controllers/paint_actions/main/position_action.dart';
import 'package:flutter_painter/src/controllers/paint_actions/main/size_action.dart';
import 'package:flutter_painter/src/models/position_model.dart';
import 'package:flutter_painter/src/models/size_model.dart';
import 'package:flutter_painter/src/views/widgets/measure_size.dart';
import 'package:flutter_painter/src/views/widgets/painter_container.dart';

class TextItemWidget extends StatefulWidget {
  const TextItemWidget({
    required this.item,
    required this.height,
    required this.painterController,
    super.key,
    this.onPositionChange,
    this.onSizeChange,
  });
  final TextItem item;
  final double height;
  final void Function(PositionModel)? onPositionChange;
  final void Function(SizeModel)? onSizeChange;

  final PainterController painterController;
  @override
  State<TextItemWidget> createState() => _TextItemWidgetState();
}

class _TextItemWidgetState extends State<TextItemWidget> {
  double? widgetHeight;
  ValueNotifier<PositionModel> position =
      ValueNotifier(const PositionModel(x: 50, y: 50));
  @override
  Widget build(BuildContext context) {
    print('widget item ${widget.item.position}');
    return ValueListenableBuilder(
      valueListenable: position,
      builder: (context, value, child) {
        return PainterContainer(
          selectedItem: true,
          height: widget.height,
          minimumContainerHeight: widgetHeight,
          position: widget.item.position,
          onPositionChange: (oldPosition, newPosition) {
            position.value = newPosition;
            widget.onPositionChange?.call(newPosition);
          },
          onSizeChange: (oldSize, newSize) {
            widget.onSizeChange?.call(newSize);
          },
          onPositionChangeEnd:
              (oldPosition, newPosition, oldRotateAngle, newRotateAngle) {
            widget.painterController.addAction(
              ActionPosition(
                item: widget.item,
                oldPosition: oldPosition,
                newPosition: newPosition,
                oldRotateAngle: oldRotateAngle,
                newRotateAngle: newRotateAngle,
                timestamp: DateTime.now(),
                actionType: ActionType.positionItem,
              ),
            );
            print('newposition $newPosition');
          },
          onSizeChangeEnd: (oldPosition, oldSize, newPosition, newSize) {
            widget.painterController.addAction(
              ActionSize(
                item: widget.item,
                oldPosition: oldPosition,
                newPosition: newPosition,
                oldSize: oldSize,
                newSize: newSize,
                timestamp: DateTime.now(),
                actionType: ActionType.sizeItem,
              ),
            );
          },
          enabled: widgetHeight != null,
          child: MeasureSize(
            onChange: (size) {
              if (widgetHeight != null) return;
              setState(() {
                widgetHeight = size.height;
              });
            },
            child: Text(
              widget.item.text,
              style: widget.item.textStyle,
            ),
          ),
        );
      },
    );
  }
}
