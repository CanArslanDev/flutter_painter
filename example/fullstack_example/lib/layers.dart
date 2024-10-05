import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_painter/flutter_painter.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class Layers extends StatelessWidget {
  const Layers({super.key, required this.controller});
  final PainterController controller;
  @override
  Widget build(BuildContext context) {
    Widget iconButton(IconData icon, Color color, void Function() onTap) {
      return GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Icon(
            icon,
            color: color,
            size: 22,
          ),
        ),
      );
    }

    Widget section(String title, PainterItem item) {
      return Container(
        height: 40,
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: Colors.grey.shade700,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
            const Spacer(),
            iconButton(
              PhosphorIconsRegular.trash,
              Colors.red,
              () {
                // Add your onTap functionality here
              },
            ),
            iconButton(
              PhosphorIconsRegular.arrowDown,
              Colors.white,
              () {
                // Add your onTap functionality here
              },
            ),
            iconButton(
              PhosphorIconsRegular.arrowUp,
              Colors.white,
              () {
                // Add your onTap functionality here
              },
            ),
            const SizedBox(
              width: 10,
            )
          ],
        ),
      );
    }

    Widget title() {
      return Padding(
        padding: EdgeInsets.only(top: 8, bottom: 8, left: 10),
        child: Row(
          children: [
            iconButton(Icons.arrow_back_ios, Colors.white, () {
              // setState(() {
              //   openLayers = !openLayers;
              // });
            }),
            Text('Layers',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                )),
          ],
        ),
      );
    }

    return Container(
      height: 170,
      child: ValueListenableBuilder(
        valueListenable: controller,
        builder: (context, value, child) => ListView.builder(
            itemCount: value.items.length,
            itemBuilder: (context, index) {
              return section(
                  value.items[index].layer.title, value.items[index]);
            }),
      ),
    );
  }
}