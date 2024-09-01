import 'package:flutter/material.dart';
import 'package:flutter_painter/flutter_painter.dart';
import 'package:flutter_painter/src/controllers/custom_paint.dart';

import 'package:flutter_painter/src/views/widgets/painter_container.dart';

class PainterWidget extends StatelessWidget {
  const PainterWidget({required this.controller, super.key});
  final PainterController controller;
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PainterControllerValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        print('PainterWidget');
        return viewerWidget(controller);
      },
    );
  }

  Widget viewerWidget(PainterController controller) {
    return InteractiveViewer(
      boundaryMargin: const EdgeInsets.all(20.0),
      minScale: 0.1,
      maxScale: 10,
      child: Center(
        child: (controller.background.width == 0 ||
                controller.background.height == 0)
            ? null
            : AspectRatio(
                aspectRatio:
                    controller.background.width / controller.background.height,
                child: (!(controller.isDrawing || controller.isErasing))
                    ? mainBody(controller)
                    : drawingWidget(mainBody(controller)),
              ),
      ),
    );
  }

  Widget drawingWidget(Widget child) {
    return GestureDetector(
      onPanUpdate: (details) {
        if (controller.isDrawing || controller.isErasing) {
          controller.addPaintPoint(details.localPosition);
        }
      },
      onPanEnd: (details) {
        if (controller.isDrawing || controller.isErasing) {
          controller.endPath();
        }
      },
      child: child,
    );
  }

  Widget mainBody(PainterController controller) {
    return RepaintBoundary(
      key: controller.repaintBoundaryKey,
      child: CustomPaint(
        painter: PainterCustomPaint(
          color: Colors.blue,
          isErasing: false,
          paths: controller.value.paintPaths.toList(),
          points: controller.value.currentPaintPath.toList(),
          backgroundImage: controller.background.image,
        ),
        child: Stack(
          children: [
            PainterContainer(
              height: controller.background.height,
            ),
          ],
        ),
      ),
    );
  }
}