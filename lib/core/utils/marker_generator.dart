import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// A utility class to convert a list of widgets into a list of [BitmapDescriptor]s
/// for use as custom map markers.
///
/// This approach uses an [Overlay] to render the widgets off-screen, making it
/// more robust and less prone to breaking with Flutter updates compared to
/// manual RenderObject manipulation.
class MarkerGenerator {
  final BuildContext context;
  final List<Widget> markerWidgets;

  MarkerGenerator(this.context, this.markerWidgets);

  /// Generates the [BitmapDescriptor]s.
  Future<List<BitmapDescriptor>> generate() async {
    final List<GlobalKey> globalKeys =
        List.generate(markerWidgets.length, (_) => GlobalKey());

    final completer = Completer<List<BitmapDescriptor>>();
    final overlayState = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) {
        // Position the widgets off-screen
        return Positioned(
          top: -99999,
          left: 0,
          child: Material(
            type: MaterialType.transparency,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(markerWidgets.length, (index) {
                return RepaintBoundary(
                  key: globalKeys[index],
                  child: markerWidgets[index],
                );
              }),
            ),
          ),
        );
      },
    );

    overlayState.insert(overlayEntry);

    // Wait for the widgets to be rendered.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final bitmaps = await _capturePins(globalKeys);
        completer.complete(bitmaps);
      } catch (e) {
        completer.completeError(e);
      } finally {
        // Clean up the overlay entry
        overlayEntry.remove();
      }
    });

    return completer.future;
  }

  /// Captures the rendered widgets as images.
  Future<List<BitmapDescriptor>> _capturePins(List<GlobalKey> globalKeys) async {
    final List<BitmapDescriptor> bitmaps = [];
    for (final key in globalKeys) {
      final boundary =
          key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      // The pixelRatio can be adjusted for higher or lower resolution markers
      final image = await boundary.toImage(pixelRatio: 2.5);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final uint8List = byteData!.buffer.asUint8List();
      bitmaps.add(BitmapDescriptor.fromBytes(uint8List));
    }
    return bitmaps;
  }
}
