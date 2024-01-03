import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:music_api/music_api.dart';

class Lyric extends StatefulWidget {
  Lyric({
    super.key,
    required this.lyric,
    required this.lyricLineStyle,
    required this.lyricHighlightStyle,
    this.position,
    this.textAlign = TextAlign.center,
    required this.size,
    this.onTap,
    required this.playing,
  }) : assert(lyric.size > 0);

  final TextStyle lyricLineStyle;
  final TextStyle lyricHighlightStyle;

  final LyricContent lyric;

  final TextAlign textAlign;

  final int? position;

  final Size size;

  final VoidCallback? onTap;

  /// player is playing
  final bool playing;

  @override
  State<StatefulWidget> createState() => LyricState();
}

class LyricState extends State<Lyric> with TickerProviderStateMixin {
  late LyricPainter lyricPainter;

  AnimationController? _flingController;

  AnimationController? _lineController;

  @override
  void initState() {
    super.initState();
    lyricPainter = LyricPainter(
      widget.lyricLineStyle,
      widget.lyricHighlightStyle,
      widget.lyric,
      textAlign: widget.textAlign,
    );
    _scrollToCurrentPosition(widget.position);
  }

  @override
  void didUpdateWidget(Lyric oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lyric != oldWidget.lyric) {
      lyricPainter = LyricPainter(
        widget.lyricLineStyle,
        widget.lyricHighlightStyle,
        widget.lyric,
        textAlign: widget.textAlign,
      );
    }
    if (widget.position != oldWidget.position) {
      _scrollToCurrentPosition(widget.position);
    }
  }

  /// scroll lyric to current playing position
  void _scrollToCurrentPosition(int? milliseconds, {bool animate = true}) {
    if (lyricPainter.height == -1) {
      WidgetsBinding.instance.addPostFrameCallback((d) {
//        debugPrint("try to init scroll to position ${widget.position.value},"
//            "but lyricPainter is unavaiable, so scroll(without animate) on next frame $d");
        //TODO maybe cause bad performance
        if (mounted) _scrollToCurrentPosition(milliseconds, animate: false);
      });
      return;
    }

    final line = widget.lyric
        .findLineByTimeStamp(milliseconds!, lyricPainter.currentLine);

    if (lyricPainter.currentLine != line && !dragging) {
      final offset = lyricPainter.computeScrollTo(line);

      if (animate) {
        _lineController?.dispose();
        _lineController = AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 800),
        )..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              lyricPainter.setCustomLineFontSize(const {});
              _lineController!.dispose();
              _lineController = null;
            }
          });
        final animation = Tween<double>(
          begin: lyricPainter.offsetScroll,
          end: lyricPainter.offsetScroll + offset,
        ).chain(CurveTween(curve: Curves.easeInOut)).animate(_lineController!);
        animation.addListener(() {
          lyricPainter.offsetScroll = animation.value;
        });
        final normalSize = widget.lyricLineStyle.fontSize ?? 14;
        final highlightSize = widget.lyricHighlightStyle.fontSize ?? 14;
        if (normalSize != highlightSize) {
          final fontSizeAnimation =
              Tween<double>(begin: normalSize, end: highlightSize)
                  .chain(CurveTween(curve: Curves.easeInOut))
                  .animate(_lineController!);
          fontSizeAnimation.addListener(() {
            lyricPainter.setCustomLineFontSize({
              line: fontSizeAnimation.value,
            });
          });
          lyricPainter.setCustomLineFontSize({
            line: fontSizeAnimation.value,
          });
          if (lyricPainter._lineSpaces.isNotEmpty) {
            final spaces = Map<int, double>.from(lyricPainter._lineSpaces);
            final spaceAnimation = Tween<double>(begin: 0, end: 1)
                .chain(CurveTween(curve: Curves.easeInOut))
                .animate(_lineController!);
            spaceAnimation.addListener(() {
              final value = spaceAnimation.value;
              for (final line in lyricPainter._lineSpaces.keys.toList()) {
                final newSpace = (spaces[line] ?? 0) * (1 - value);
                if (newSpace == 0) {
                  lyricPainter._lineSpaces.remove(line);
                } else {
                  lyricPainter._lineSpaces[line] =
                      (spaces[line] ?? 0) * (1 - value);
                }
              }
            });
          }
        }
        _lineController!.forward();
      } else {
        lyricPainter.offsetScroll += offset;
      }
    }
    lyricPainter.currentLine = line;
  }

  bool dragging = false;

  bool _consumeTap = false;

  @override
  void dispose() {
    _flingController?.dispose();
    _flingController = null;
    _lineController?.dispose();
    _lineController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 300, minHeight: 120),
      child: _ScrollerListener(
        onScroll: (delta) {
          lyricPainter.offsetScroll += -delta;
        },
        child: GestureDetector(
          onTap: () {
            if (!_consumeTap && widget.onTap != null) {
              widget.onTap!();
            } else {
              _consumeTap = false;
            }
          },
          onTapDown: (details) {
            if (dragging) {
              _consumeTap = true;

              dragging = false;
              _flingController?.dispose();
              _flingController = null;
            }
          },
          onVerticalDragStart: (details) {
            dragging = true;
            _flingController?.dispose();
            _flingController = null;
          },
          onVerticalDragUpdate: (details) {
            lyricPainter.offsetScroll += details.primaryDelta!;
          },
          onVerticalDragEnd: (details) {
            _flingController = AnimationController.unbounded(
              vsync: this,
              duration: const Duration(milliseconds: 300),
            )
              ..addListener(() {
                var value = _flingController!.value;

                if (value < -lyricPainter.height || value >= 0) {
                  _flingController!.dispose();
                  _flingController = null;
                  dragging = false;
                  value = value.clamp(-lyricPainter.height, 0.0);
                }
                lyricPainter.offsetScroll = value;
              })
              ..addStatusListener((status) {
                if (status == AnimationStatus.completed ||
                    status == AnimationStatus.dismissed) {
                  dragging = false;
                  _flingController?.dispose();
                  _flingController = null;
                }
              })
              ..animateWith(
                ClampingScrollSimulation(
                  position: lyricPainter.offsetScroll,
                  velocity: details.primaryVelocity!,
                ),
              );
          },
          child: CustomPaint(
            size: widget.size,
            painter: lyricPainter,
          ),
        ),
      ),
    );
  }
}

class _ScrollerListener extends StatefulWidget {
  const _ScrollerListener({
    super.key,
    required this.child,
    required this.onScroll,
    this.axisDirection = AxisDirection.down,
  });

  final Widget child;

  final void Function(double offset) onScroll;

  final AxisDirection axisDirection;

  @override
  State<_ScrollerListener> createState() => _ScrollerListenerState();
}

class _ScrollerListenerState extends State<_ScrollerListener> {
  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: _receivedPointerSignal,
      child: widget.child,
    );
  }

  void _receivedPointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      if (_pointerSignalEventDelta(event) != 0.0) {
        GestureBinding.instance.pointerSignalResolver
            .register(event, _handlePointerScroll);
      }
    }
  }

  void _handlePointerScroll(PointerEvent event) {
    final devicePixelRatio = View.of(context).devicePixelRatio;
    assert(event is PointerScrollEvent);
    final delta = _pointerSignalEventDelta(event as PointerScrollEvent);
    final double scrollerScale;
    if (defaultTargetPlatform == TargetPlatform.windows) {
      scrollerScale = devicePixelRatio * 2;
    } else if (defaultTargetPlatform == TargetPlatform.linux) {
      scrollerScale = devicePixelRatio;
    } else {
      scrollerScale = 1;
    }
    widget.onScroll(delta * scrollerScale);
  }

  // Returns the delta that should result from applying [event] with axis and
  // direction taken into account.
  double _pointerSignalEventDelta(PointerScrollEvent event) {
    var delta = event.scrollDelta.dy;

    if (axisDirectionIsReversed(widget.axisDirection)) {
      delta *= -1;
    }
    return delta;
  }
}

class LyricPainter extends ChangeNotifier implements CustomPainter {
  ///param lyric must not be null
  LyricPainter(
    TextStyle style,
    TextStyle highlightStyle,
    this.lyric, {
    this.textAlign = TextAlign.center,
  })  : _normalStyle = style,
        _highlightStyle = highlightStyle {
    _presetPainters = [];
    for (var i = 0; i < lyric.size; i++) {
      final painter = TextPainter(
        text: TextSpan(style: style, text: lyric[i].line),
        textAlign: textAlign,
      );
      painter.textDirection = TextDirection.ltr;
//      painter.layout();//layout first, to get the height
      _presetPainters.add(painter);
    }
  }

  LyricContent lyric;

  late List<TextPainter> _presetPainters;
  late List<TextPainter> lyricPainters;
  final Map<int, double> _lineSpaces = {};

  double _offsetScroll = 0;

  double get offsetScroll => _offsetScroll;

  set offsetScroll(double value) {
    if (height == -1) {
      // do not change offset when height is not available.
      return;
    }
    _offsetScroll = value.clamp(-height, 0.0);
    _repaint();
  }

  int currentLine = 0;

  TextAlign textAlign;

  final TextStyle _highlightStyle;
  final TextStyle _normalStyle;

  final _fontSizeMap = <int, double>{};

  void setCustomLineFontSize(Map<int, double> lineFontSize) {
    _fontSizeMap
      ..clear()
      ..addAll(lineFontSize);
    _repaint();
  }

  void _repaint() {
    notifyListeners();
  }

  double get height => _height;
  double _height = -1;

  double _width = -1;

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    _width = size.width;
    _layoutPainterList(size.width, currentLine, _fontSizeMap);
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // draw first line at viewport center if offsetScroll is 0.
    var dy = offsetScroll + size.height / 2 - lyricPainters[0].height / 2;

    for (var line = 0; line < lyricPainters.length; line++) {
      final painter = lyricPainters[line];
      _drawLyricLine(canvas, painter, dy, size);
      dy += painter.height;
      if (_lineSpaces[line] != null) {
        dy += _lineSpaces[line]!;
      }
    }
  }

  void _drawLyricLine(
    ui.Canvas canvas,
    TextPainter painter,
    double dy,
    ui.Size size,
  ) {
    if (dy > size.height || dy < 0 - painter.height) {
      return;
    }
    painter.paint(
      canvas,
      Offset(_calculateAlignOffset(painter, size), dy),
    );
  }

  double _calculateAlignOffset(TextPainter painter, ui.Size size) {
    if (textAlign == TextAlign.center) {
      return (size.width - painter.width) / 2;
    }
    return 0;
  }

  @override
  bool shouldRepaint(LyricPainter oldDelegate) {
    return true;
  }

  void _layoutPainterList(
    double maxWith,
    int currentLine,
    Map<int, double> fontSizeMap,
  ) {
    _height = 0;
    lyricPainters = [];
    for (var i = 0; i < _presetPainters.length; i++) {
      final TextPainter painter;
      if (fontSizeMap[i] != null) {
        painter = TextPainter(textDirection: TextDirection.ltr)
          ..text = TextSpan(
            text: lyric[i].line,
            style: (i == currentLine ? _highlightStyle : _normalStyle)
                .copyWith(fontSize: fontSizeMap[i]),
          );
      } else if (i == currentLine) {
        painter = TextPainter(textDirection: TextDirection.ltr)
          ..text = TextSpan(text: lyric[i].line, style: _highlightStyle)
          ..textAlign = textAlign;
      } else {
        painter = _presetPainters[i];
      }
      painter.layout(maxWidth: maxWith);
      _height += painter.height;
      if (_lineSpaces[i] != null) {
        _height += _lineSpaces[i]!;
      }
      lyricPainters.add(painter);
    }
  }

  // compute the offset current offset to destination line
  double computeScrollTo(int destination) {
    if (lyricPainters.isEmpty || this.height == 0 || _width <= 0) {
      return 0;
    }

    final currentLineHeights = lyricPainters.map((e) => e.height).toList();
    _layoutPainterList(_width, destination, {});
    final destinationLineHeights = lyricPainters.map((e) => e.height).toList();

    for (var i = 0; i < currentLineHeights.length; i++) {
      if (currentLineHeights[i] > destinationLineHeights[i]) {
        _lineSpaces[i] = currentLineHeights[i] - destinationLineHeights[i];
      }
    }

    var height = -lyricPainters[0].height / 2;
    for (var i = 0; i < lyricPainters.length; i++) {
      if (i == destination) {
        height += lyricPainters[i].height / 2;
        break;
      }
      height += lyricPainters[i].height;
    }
    return -(height + offsetScroll);
  }

  @override
  bool? hitTest(ui.Offset position) => null;

  @override
  SemanticsBuilderCallback? get semanticsBuilder => null;

  @override
  bool shouldRebuildSemantics(CustomPainter oldDelegate) =>
      shouldRepaint(oldDelegate as LyricPainter);
}
