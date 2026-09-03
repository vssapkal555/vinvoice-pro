import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Normalizes company logos for stable storage and PDF rendering.
///
/// PNG transparency is preserved. Large images are resized so a company logo
/// cannot unnecessarily bloat the local database or generated PDFs.
class CompanyLogoProcessor {
  const CompanyLogoProcessor._();

  static Uint8List process(Uint8List bytes) {
    var image = img.decodeImage(bytes);

    if (image == null) {
      throw const FormatException('Unsupported company logo image.');
    }

    image = img.bakeOrientation(image);

    const maxDimension = 1000;

    if (image.width > maxDimension || image.height > maxDimension) {
      image = image.width >= image.height
          ? img.copyResize(image, width: maxDimension)
          : img.copyResize(image, height: maxDimension);
    }

    final cleaned = _removeLightNeutralBackground(image);

    return Uint8List.fromList(img.encodePng(cleaned, level: 6));
  }

  static img.Image _removeLightNeutralBackground(img.Image source) {
    final out = img.Image(
      width: source.width,
      height: source.height,
      numChannels: 4,
    );

    for (var y = 0; y < source.height; y++) {
      for (var x = 0; x < source.width; x++) {
        final p = source.getPixel(x, y);

        final r = p.r.toInt();
        final g = p.g.toInt();
        final b = p.b.toInt();
        final existingAlpha = p.a.toInt();

        final maxC = [r, g, b].reduce((a, b) => a > b ? a : b);
        final minC = [r, g, b].reduce((a, b) => a < b ? a : b);
        final saturation = maxC - minC;
        final luminance = 0.299 * r + 0.587 * g + 0.114 * b;

        var alpha = existingAlpha;

        // Checkerboards in downloaded "transparent" logos are usually
        // near-neutral white/light-grey pixels. Preserve coloured and dark
        // logo artwork while removing that baked background.
        if (saturation <= 18 && luminance >= 218) {
          alpha = 0;
        } else if (saturation <= 13 && luminance >= 196) {
          final fade = ((218 - luminance) / 22 * 255).round();
          alpha = fade.clamp(0, existingAlpha);
        }

        out.setPixelRgba(x, y, r, g, b, alpha);
      }
    }

    return out;
  }
}
