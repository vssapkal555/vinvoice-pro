import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Converts a photographed/scanned signature into a transparent PNG.
///
/// The cleaner works fully offline and preserves the original pen colour.
/// It estimates the paper/background colour from the image borders, removes
/// that background using alpha transparency, crops excess margins and removes
/// tiny isolated noise.
class SignatureImageProcessor {
  const SignatureImageProcessor._();

  static Uint8List clean(Uint8List bytes) {
    var source = img.decodeImage(bytes);
    if (source == null) {
      throw const FormatException('Unsupported signature image.');
    }

    source = img.bakeOrientation(source);

    const maxDimension = 1600;
    if (source.width > maxDimension || source.height > maxDimension) {
      source = source.width >= source.height
          ? img.copyResize(source, width: maxDimension)
          : img.copyResize(source, height: maxDimension);
    }

    final background = _estimateBackground(source);
    final mask = _makeTransparent(source, background);

    final bounds = _alphaBounds(mask);
    var result = mask;

    if (bounds != null) {
      final padX = (mask.width * 0.025).round().clamp(10, 40);
      final padY = (mask.height * 0.06).round().clamp(8, 30);

      final x1 = (bounds.$1 - padX).clamp(0, mask.width - 1);
      final y1 = (bounds.$2 - padY).clamp(0, mask.height - 1);
      final x2 = (bounds.$3 + padX).clamp(0, mask.width - 1);
      final y2 = (bounds.$4 + padY).clamp(0, mask.height - 1);

      result = img.copyCrop(
        mask,
        x: x1,
        y: y1,
        width: x2 - x1 + 1,
        height: y2 - y1 + 1,
      );
    }

    _removeIsolatedNoise(result);

    return Uint8List.fromList(img.encodePng(result, level: 6));
  }

  static (double, double, double) _estimateBackground(img.Image image) {
    final samples = <(int, int, int)>[];
    final stepX = math.max(1, image.width ~/ 40);
    final stepY = math.max(1, image.height ~/ 40);
    final edge = math.max(2, math.min(image.width, image.height) ~/ 20);

    for (var x = 0; x < image.width; x += stepX) {
      for (var y = 0; y < edge; y += math.max(1, edge ~/ 3)) {
        final p = image.getPixel(x, y);
        samples.add((p.r.toInt(), p.g.toInt(), p.b.toInt()));
      }
      for (
        var y = image.height - edge;
        y < image.height;
        y += math.max(1, edge ~/ 3)
      ) {
        if (y < 0) continue;
        final p = image.getPixel(x, y);
        samples.add((p.r.toInt(), p.g.toInt(), p.b.toInt()));
      }
    }

    for (var y = 0; y < image.height; y += stepY) {
      for (var x = 0; x < edge; x += math.max(1, edge ~/ 3)) {
        final p = image.getPixel(x, y);
        samples.add((p.r.toInt(), p.g.toInt(), p.b.toInt()));
      }
      for (
        var x = image.width - edge;
        x < image.width;
        x += math.max(1, edge ~/ 3)
      ) {
        if (x < 0) continue;
        final p = image.getPixel(x, y);
        samples.add((p.r.toInt(), p.g.toInt(), p.b.toInt()));
      }
    }

    if (samples.isEmpty) return (255, 255, 255);

    // Use the brightest 65% of border samples so a dark accidental border
    // mark does not distort the estimated paper colour.
    samples.sort((a, b) {
      final la = a.$1 + a.$2 + a.$3;
      final lb = b.$1 + b.$2 + b.$3;
      return lb.compareTo(la);
    });

    final take = math.max(1, (samples.length * 0.65).round());
    var r = 0.0;
    var g = 0.0;
    var b = 0.0;

    for (final sample in samples.take(take)) {
      r += sample.$1;
      g += sample.$2;
      b += sample.$3;
    }

    return (r / take, g / take, b / take);
  }

  static img.Image _makeTransparent(
    img.Image source,
    (double, double, double) background,
  ) {
    final out = img.Image(
      width: source.width,
      height: source.height,
      numChannels: 4,
    );

    final bgLum =
        0.299 * background.$1 + 0.587 * background.$2 + 0.114 * background.$3;

    for (var y = 0; y < source.height; y++) {
      for (var x = 0; x < source.width; x++) {
        final p = source.getPixel(x, y);

        var r = p.r.toInt();
        var g = p.g.toInt();
        var b = p.b.toInt();

        final dr = r - background.$1;
        final dg = g - background.$2;
        final db = b - background.$3;
        final distance = math.sqrt(dr * dr + dg * dg + db * db);

        final maxC = math.max(r, math.max(g, b));
        final minC = math.min(r, math.min(g, b));
        final saturation = (maxC - minC).toDouble();
        final lum = 0.299 * r + 0.587 * g + 0.114 * b;
        final darkness = math.max(0.0, bgLum - lum);

        double alpha;

        // Coloured pen (especially blue) is primarily identified by
        // saturation + distance from the sampled paper colour.
        if (saturation >= 24 && distance >= 24) {
          alpha = math.max(150.0, math.max(saturation * 5.2, distance * 4.6));
        } else {
          // Black/dark pen relies on darkness. Low-contrast grey paper
          // shadows are intentionally rejected.
          if (darkness < 42 || distance < 28) {
            alpha = 0;
          } else {
            alpha = math.max((darkness - 28) * 7.2, (distance - 22) * 5.0);
          }
        }

        // Kill residual paper texture / camera shadows.
        if (saturation < 16 && darkness < 72) {
          alpha = 0;
        }

        if (distance < 20 && darkness < 30) {
          alpha = 0;
        }

        alpha = alpha.clamp(0, 255);

        if (alpha > 0) {
          // Preserve original hue but strengthen visible strokes slightly.
          const contrast = 1.10;
          r = (((r - 245) * contrast) + 245).round().clamp(0, 255);
          g = (((g - 245) * contrast) + 245).round().clamp(0, 255);
          b = (((b - 245) * contrast) + 245).round().clamp(0, 255);

          // Avoid semi-transparent, washed-out signature strokes.
          if (alpha >= 90) {
            alpha = math.max(alpha, 205);
          }
        }

        out.setPixelRgba(x, y, r, g, b, alpha.round());
      }
    }

    return out;
  }

  static (int, int, int, int)? _alphaBounds(img.Image image) {
    var minX = image.width;
    var minY = image.height;
    var maxX = -1;
    var maxY = -1;

    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        if (image.getPixel(x, y).a.toInt() >= 35) {
          if (x < minX) minX = x;
          if (x > maxX) maxX = x;
          if (y < minY) minY = y;
          if (y > maxY) maxY = y;
        }
      }
    }

    if (maxX < 0 || maxY < 0) return null;
    return (minX, minY, maxX, maxY);
  }

  static void _removeIsolatedNoise(img.Image image) {
    if (image.width < 3 || image.height < 3) return;

    final clear = <(int, int)>[];

    for (var y = 1; y < image.height - 1; y++) {
      for (var x = 1; x < image.width - 1; x++) {
        if (image.getPixel(x, y).a.toInt() < 45) continue;

        var neighbours = 0;

        for (var yy = y - 1; yy <= y + 1; yy++) {
          for (var xx = x - 1; xx <= x + 1; xx++) {
            if (xx == x && yy == y) continue;
            if (image.getPixel(xx, yy).a.toInt() >= 35) {
              neighbours++;
            }
          }
        }

        if (neighbours <= 1) clear.add((x, y));
      }
    }

    for (final point in clear) {
      image.setPixelRgba(point.$1, point.$2, 0, 0, 0, 0);
    }
  }
}
