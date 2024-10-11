import 'package:flutter/material.dart';
import 'package:flutter_painter/flutter_painter.dart';
import 'package:flutter_painter/src/controllers/items/painter_item.dart';
import 'package:flutter_painter/src/controllers/paint_actions/layer/layer_change_action.dart';
import 'package:flutter_painter/src/controllers/paint_actions/main/add_item_action.dart';
import 'package:flutter_painter/src/controllers/paint_actions/main/draw_action.dart';
import 'package:flutter_painter/src/controllers/paint_actions/main/erase_action.dart';
import 'package:flutter_painter/src/controllers/paint_actions/main/position_action.dart';
import 'package:flutter_painter/src/controllers/paint_actions/main/remove_item_action.dart';
import 'package:flutter_painter/src/controllers/paint_actions/main/rotate_action.dart';
import 'package:flutter_painter/src/controllers/paint_actions/main/size_action.dart';
import 'package:flutter_painter/src/controllers/paint_actions/paint_action.dart';
import 'package:flutter_painter/src/controllers/paint_actions/paint_actions.dart';
import 'package:flutter_painter/src/controllers/paint_actions/text_actions/text_change_value_action.dart';

class ActionsService {
  List<PaintAction> currentActions = [];
  int currentIndex = 0;
  List<PainterItem> items = [];
  List<List<Offset?>> currentPaintPath = [];
  void updateActionWithChangeActionIndex(
    ValueNotifier<PaintActions> changeActions,
    List<List<Offset?>> paintPath,
    PainterControllerValue value,
    int index,
    void Function(List<PainterItem> items) updatedList,
    void Function(int index) updateIndex,
    void Function(List<List<Offset?>> pathList) updatedPaintPath,
  ) {
    _setValues(changeActions, paintPath, value);

    void undoActions() {
      for (var i = currentIndex; i > index; i--) {
        if (currentActions[i] is ActionAddItem) {
          _actionAddItem(currentActions[i] as ActionAddItem, false);
        }
        if (currentActions[i] is ActionPosition) {
          _actionPosition(currentActions[i] as ActionPosition, false);
        } else if (currentActions[i] is ActionSize) {
          _actionSize(currentActions[i] as ActionSize, false);
        } else if (currentActions[i] is ActionRotation) {
          _actionRotation(currentActions[i] as ActionRotation, false);
        } else if (currentActions[i] is ActionLayerChange) {
          _actionLayerChange(currentActions[i] as ActionLayerChange, false);
        } else if (currentActions[i] is ActionRemoveItem) {
          _actionRemoveItem(currentActions[i] as ActionRemoveItem, false);
        } else if (currentActions[i] is ActionDraw) {
          _actionDraw(currentActions[i] as ActionDraw, false);
        } else if (currentActions[i] is ActionErase) {
          _actionErese(currentActions[i] as ActionErase, false);
        } else if (currentActions[i] is ActionTextChangeValue) {
          _actionTextValue(currentActions[i] as ActionTextChangeValue, false);
        }
      }
    }

    void redoActions() {
      for (var i = currentIndex + 1; i <= index; i++) {
        if (currentActions[i] is ActionAddItem) {
          _actionAddItem(currentActions[i] as ActionAddItem, true);
        }
        if (currentActions[i] is ActionPosition) {
          _actionPosition(currentActions[i] as ActionPosition, true);
        } else if (currentActions[i] is ActionSize) {
          _actionSize(currentActions[i] as ActionSize, true);
        } else if (currentActions[i] is ActionRotation) {
          _actionRotation(currentActions[i] as ActionRotation, true);
        } else if (currentActions[i] is ActionLayerChange) {
          _actionLayerChange(currentActions[i] as ActionLayerChange, true);
        } else if (currentActions[i] is ActionRemoveItem) {
          _actionRemoveItem(currentActions[i] as ActionRemoveItem, true);
        } else if (currentActions[i] is ActionDraw) {
          _actionDraw(currentActions[i] as ActionDraw, true);
        } else if (currentActions[i] is ActionErase) {
          _actionErese(currentActions[i] as ActionErase, true);
        } else if (currentActions[i] is ActionTextChangeValue) {
          _actionTextValue(currentActions[i] as ActionTextChangeValue, true);
        }
      }
    }

    if (index < currentIndex) {
      undoActions();
    } else {
      redoActions();
    }
    updatedList(items);
    updateIndex(index);
    updatedPaintPath(currentPaintPath);
  }

  void _updateList(PainterItem item) {
    final itemIndex = items.indexWhere((element) {
      return element.id == item.id;
    });
    items
      ..removeAt(itemIndex)
      ..insert(itemIndex, item);
  }

  void _actionAddItem(ActionAddItem item, bool isRedo) {
    if (isRedo) {
      items.insert(item.listIndex, item.item);
    } else {
      final itemValue = items
          .where(
            (element) => element.id == item.item.id,
          )
          .first;
      _removeItemFromList(itemValue.id);
    }
  }

  void _actionSize(ActionSize item, bool isRedo) {
    var itemValue = items
        .where(
          (element) => element.id == item.item.id,
        )
        .first;
    if (isRedo) {
      itemValue = itemValue.copyWith(
        size: item.newSize,
        position: item.newPosition,
      );
    } else {
      itemValue = itemValue.copyWith(
        size: item.oldSize,
        position: item.oldPosition,
      );
    }
    _updateList(itemValue);
  }

  void _actionPosition(ActionPosition item, bool isRedo) {
    var itemValue = items
        .where(
          (element) => element.id == item.item.id,
        )
        .first;
    if (isRedo) {
      itemValue = itemValue.copyWith(position: item.newPosition);
    } else {
      itemValue = itemValue.copyWith(position: item.oldPosition);
    }
    _updateList(itemValue);
  }

  void _removeItemFromList(String itemId) {
    items.removeWhere((element) => element.id == itemId);
  }

  void _actionRotation(ActionRotation item, bool isRedo) {
    var itemValue = items
        .where(
          (element) => element.id == item.item.id,
        )
        .first;
    if (isRedo) {
      itemValue = itemValue.copyWith(rotation: item.newRotateAngle);
    } else {
      itemValue = itemValue.copyWith(rotation: item.oldRotateAngle);
    }
    _updateList(itemValue);
  }

  void _actionLayerChange(ActionLayerChange item, bool isRedo) {
    final itemValue = items
        .where(
          (element) => element.id == item.item.id,
        )
        .first;
    final changedItem = items
        .where(
          (element) => element.id == item.changedItem.id,
        )
        .first;
    if (isRedo) {
      items
        ..remove(itemValue)
        ..insert(item.newIndex, itemValue)
        ..remove(changedItem)
        ..insert(item.changedItemNewIndex, changedItem);
    } else {
      items
        ..remove(itemValue)
        ..insert(item.oldIndex, itemValue)
        ..remove(changedItem)
        ..insert(item.changedItemOldIndex, changedItem);
    }
  }

  void _actionRemoveItem(ActionRemoveItem item, bool isRedo) {
    if (isRedo) {
      items.insert(item.listIndex, item.item);
    } else {
      _removeItemFromList(item.item.id);
    }
  }

  void _actionDraw(ActionDraw item, bool isRedo) {
    if (isRedo) {
      currentPaintPath.insert(item.listIndex, item.paintPath);
    } else {
      currentPaintPath.removeAt(item.listIndex);
    }
  }

  void _actionErese(ActionErase item, bool isRedo) {
    if (isRedo) {
      currentPaintPath = item.currentPaintPath;
    } else {
      currentPaintPath = item.lastPaintPath;
    }
  }

  void _actionTextValue(ActionTextChangeValue item, bool isRedo) {
    var itemValue = items
        .where(
          (element) => element.id == item.currentItem.id,
        )
        .first;
    if (isRedo) {
      itemValue = item.currentItem;
    } else {
      itemValue = item.lastItem;
    }
    _updateList(itemValue);
  }

  void undo(
    ValueNotifier<PaintActions> changeActions,
    List<List<Offset?>> paintPath,
    PainterControllerValue value,
    void Function(List<PainterItem> items) updatedList,
    void Function(int index) updateIndex,
    void Function(List<List<Offset?>> pathList) updatedPaintPath,
  ) {
    _setValues(changeActions, paintPath, value);
    if (currentIndex < 0) return;
    updateActionWithChangeActionIndex(
      changeActions,
      currentPaintPath,
      value,
      currentIndex - 1,
      updatedList,
      updateIndex,
      updatedPaintPath,
    );
  }

  void redo(
    ValueNotifier<PaintActions> changeActions,
    List<List<Offset?>> paintPath,
    PainterControllerValue value,
    void Function(List<PainterItem> items) updatedList,
    void Function(int index) updateIndex,
    void Function(List<List<Offset?>> pathList) updatedPaintPath,
  ) {
    _setValues(changeActions, paintPath, value);
    if (currentIndex == currentActions.length - 1) return;
    updateActionWithChangeActionIndex(
      changeActions,
      currentPaintPath,
      value,
      currentIndex + 1,
      updatedList,
      updateIndex,
      updatedPaintPath,
    );
  }

  void _setValues(
    ValueNotifier<PaintActions> changeActions,
    List<List<Offset?>> paintPath,
    PainterControllerValue value,
  ) {
    currentActions = changeActions.value.changeList;
    currentIndex = changeActions.value.index;
    currentPaintPath = paintPath;
    items = value.items.toList();
  }
}
