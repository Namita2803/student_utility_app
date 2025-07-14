import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BotAssistant extends StatefulWidget {
  final double size;
  const BotAssistant({Key? key, this.size = 200}) : super(key: key);

  @override
  State<BotAssistant> createState() => _BotAssistantState();
}

class _BotAssistantState extends State<BotAssistant> with SingleTickerProviderStateMixin {
  Offset? _pointerPosition;
  Offset? _botCenter;
  double _angle = 0;
  late AnimationController _blinkController;
  late Animation<double> _blinkAnimation;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    _blinkAnimation = Tween<double>(begin: 1, end: 0.1).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );
    _blinkController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          _blinkController.reverse();
        });
      } else if (status == AnimationStatus.dismissed) {
        Future.delayed(const Duration(milliseconds: 2000), () {
          _blinkController.forward();
        });
      }
    });
    _blinkController.forward();
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  void _updatePointer(Offset globalPosition) {
    if (_botCenter == null) return;
    final dx = globalPosition.dx - _botCenter!.dx;
    final dy = globalPosition.dy - _botCenter!.dy;
    setState(() {
      _angle = atan2(dy, dx);
    });
  }

  void _setBotCenter(RenderBox box) {
    final pos = box.localToGlobal(Offset.zero);
    _botCenter = pos + Offset(widget.size / 2, widget.size / 2);
  }

  @override
  Widget build(BuildContext context) {
    Widget bot = LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: GestureDetector(
            onPanDown: (details) => _updatePointer(details.globalPosition),
            onPanUpdate: (details) => _updatePointer(details.globalPosition),
            onTapDown: (details) => _updatePointer(details.globalPosition),
            child: MouseRegion(
              onHover: (event) => _updatePointer(event.position),
              child: AnimatedBuilder(
                animation: _blinkController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _angle,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Bot head
                        SvgPicture.asset(
                          'assets/bot.svg',
                          width: widget.size,
                          height: widget.size,
                          fit: BoxFit.contain,
                          key: ValueKey('bot-image'),
                        ),
                        // Eyes overlay (blinking)
                        Positioned(
                          top: widget.size * 0.38,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _BotEye(
                                size: widget.size * 0.13,
                                blink: _blinkAnimation.value,
                              ),
                              SizedBox(width: widget.size * 0.18),
                              _BotEye(
                                size: widget.size * 0.13,
                                blink: _blinkAnimation.value,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );

    // Get bot center after first layout
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Builder(
              builder: (context) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final box = context.findRenderObject() as RenderBox?;
                  if (box != null) _setBotCenter(box);
                });
                return bot;
              },
            ),
          ),
        );
      },
    );
  }
}

class _BotEye extends StatelessWidget {
  final double size;
  final double blink;
  const _BotEye({required this.size, required this.blink});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: size,
        height: size * blink,
        color: Colors.white,
        child: Center(
          child: Container(
            width: size * 0.45,
            height: size * 0.45,
            decoration: BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
} 