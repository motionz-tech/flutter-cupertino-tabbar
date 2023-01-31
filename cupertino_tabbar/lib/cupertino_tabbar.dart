//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  © Cosmos Software | Ali Yigit Bireroglu                                                                                                          /
//  All material used in the making of this code, project, program, application, software et cetera (the "Intellectual Property")                    /
//  belongs completely and solely to Ali Yigit Bireroglu. This includes but is not limited to the source code, the multimedia and                    /
//  other asset files.                                                                                                                               /
//  If you were granted this Intellectual Property for personal use, you are obligated to include this copyright text at all times.                  /
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class CupertinoTabBar extends StatefulWidget {
  ///The color of this [CupertinoTabBar].
  final Color _backgroundColor;

  ///The color of the moving selection bar.
  final Color _foregroundColor;

  ///The widgets that are to be displayed as the tabs of this [CupertinoTabBar].
  final List<Container> _widgets;

  ///The function that is to be used to get the current index/value of this [CupertinoTabBar].
  final Function _valueGetter;

  ///The function that is to be called when the current index/value of this [CupertinoTabBar] changes.
  final Function(int) _onTap;

  ///Set this value to true if you want separator lines to be displayed between the [_widgets].
  final bool useSeparators;

  final Color? separatorColor;

  ///Set this value to true if you want a shadow to be displayed under the indicator.
  final bool useShadow;

  final List<BoxShadow>? shadows;

  ///The border radius that is to be used to display this [CupertinoTabBar] and the moving selection bar. The default value corresponds to the default iOS 13 value.
  final BorderRadius borderRadius;

  ///The curve which this [CupertinoTabBar] uses to animate the switching of tabs.
  final Curve curve;

  ///The duration that is to be used for the animations of the moving selection bar.
  final Duration duration;

  final EdgeInsets? edgeInsets;

  const CupertinoTabBar(
    this._backgroundColor,
    this._foregroundColor,
    this._widgets,
    this._valueGetter,
    this._onTap, {
    Key? key,
    this.useSeparators: false,
    this.useShadow: true,
    this.borderRadius: const BorderRadius.all(const Radius.circular(10.0)),
    this.curve: Curves.linearToEaseOut,
    this.duration: const Duration(milliseconds: 350),
    this.separatorColor,
    this.shadows,
    this.edgeInsets,
  }) : super(key: key);

  @override
  _CupertinoTabBarState createState() {
    return _CupertinoTabBarState();
  }
}

class _CupertinoTabBarState extends State<CupertinoTabBar>
    with SingleTickerProviderStateMixin {
  late List<GlobalKey> _globalKeys;
  double? _maxWidth;
  double? _maxHeight;
  double? _preferredHeight;
  double? _preferredWidth;
  double? _usedHeight;
  double? _usedWidth;
  double? _singleHeight;
  late double _singleWidth;
  double? _innerContainerHeight;
  double? _innerContainerWidth;
  double? _separatorHeight;
  double? _separatorWidth;
  double? _indicatorHeight;
  double? _indicatorWidth;
  late bool _showSelf;

  ScrollController? _scrollController;
  AnimationController? _animationController;

  bool get _isRTL => Directionality.of(context) == TextDirection.rtl;
  Alignment get _alignment => Alignment(
      (_isRTL ? -1 : 1) *
          (-1.0 + widget._valueGetter() / (widget._widgets.length - 1) * 2),
      0.0);

  void onPostFrameCallback(Duration duration) {
    if (!_showSelf) {
      setState(() {
        _maxWidth = 0;
        _maxHeight = 0;
        for (int i = 0; i < widget._widgets.length; i++) {
          RenderBox _renderBox =
              _globalKeys[i].currentContext!.findRenderObject() as RenderBox;
          if (_renderBox.size.width > _maxWidth!) {
            _maxWidth = _renderBox.size.width;
          }
          if (_renderBox.size.height > _maxHeight!) {
            _maxHeight = _renderBox.size.height;
          }
        }
        _maxWidth = _maxWidth!;
        _maxHeight = _maxHeight!;

        _preferredHeight = _maxHeight;
        _preferredWidth = _maxWidth! * widget._widgets.length;

        _usedHeight = _preferredHeight;
        _usedWidth = _preferredWidth;

        _singleHeight = _usedHeight;
        _singleWidth = _usedWidth! / widget._widgets.length;

        _innerContainerHeight = _preferredHeight;
        _innerContainerWidth = _preferredWidth;

        _separatorHeight = _maxHeight! / 2.0;
        _separatorWidth = 1.0;

        _indicatorHeight = _singleHeight;
        _indicatorWidth = _singleWidth;

        _showSelf = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _globalKeys = [];
    for (int i = 0; i < widget._widgets.length; i++) {
      _globalKeys.add(GlobalKey());
    }
    _showSelf = false;
    WidgetsBinding.instance.addPostFrameCallback(onPostFrameCallback);
  }

  @override
  void dispose() {
    if (_scrollController != null) _scrollController!.dispose();
    if (_animationController != null) _animationController!.dispose();
    super.dispose();
  }

  void onTap(int index) {
    widget._onTap(index);
  }

  @override
  Widget build(BuildContext context) {
    if (!_showSelf) {
      return Row(
        children: List<Widget>.generate(widget._widgets.length, (int index) {
          return Container(
            key: _globalKeys[index],
            child: widget._widgets[index],
          );
        }),
      );
    } else {
      Widget _widget = Stack(
        // alignment: AlignmentDirectional.centerStart,
        children: [
          Row(
            children: List<Widget>.generate(2 * widget._widgets.length - 1,
                (int index) {
              if (index % 2 != 0 && index != 2 * widget._widgets.length - 1) {
                return SizedBox(
                  width: _separatorWidth,
                );
              } else {
                return Flexible(flex: 1, child: Container());
              }
            }),
          ),
          if (widget.useSeparators)
            Positioned.fill(
              child: Row(
                children: List<Widget>.generate(2 * widget._widgets.length - 1,
                    (int index) {
                  if (index % 2 != 0 &&
                      index != 2 * widget._widgets.length - 1) {
                    return _Separator(
                      _separatorHeight,
                      _separatorWidth,
                      widget.separatorColor!,
                    );
                  } else {
                    return Flexible(flex: 1, child: Container());
                  }
                }),
              ),
            ),
          Positioned.fill(
            child: _Indicator(
              _alignment,
              widget.duration,
              widget.curve,
              _indicatorHeight,
              _indicatorWidth,
              widget._foregroundColor,
              widget.borderRadius,
              widget.useShadow,
              widget.shadows,
            ),
          ),
          Positioned.fill(
            child: Row(
              children:
                  List<Widget>.generate(widget._widgets.length, (int index) {
                int _trueIndex = index.floor();
                return _Tab(
                  widget._widgets[_trueIndex],
                  onTap,
                  _trueIndex,
                );
              }),
            ),
          ),
        ],
      );

      return Container(
        padding: widget.edgeInsets,
        width: _innerContainerWidth,
        height: _innerContainerHeight,
        decoration: BoxDecoration(
          color: widget._backgroundColor,
          borderRadius: widget.borderRadius,
        ),
        child: _widget,
      );
    }
  }
}

class _Separator extends StatelessWidget {
  final double? _height;
  final double? _width;
  final Color _color;

  const _Separator(
    this._height,
    this._width,
    this._color,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _height,
      width: _width,
      color: _color,
    );
  }
}

class _Tab extends StatelessWidget {
  final Widget _child;
  final Function(int) _onTap;
  final int _index;

  const _Tab(
    this._child,
    this._onTap,
    this._index,
  );

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        child: _child,
        onTap: () => _onTap(_index),
      ),
    );
  }
}

class _Indicator extends StatelessWidget {
  final Alignment _alignment;
  final Duration _duration;
  final Curve _curve;
  final double? _height;
  final double? _width;
  final Color _color;
  final BorderRadius _borderRadius;
  final bool _useShadow;
  final List<BoxShadow>? _shadows;

  const _Indicator(
    this._alignment,
    this._duration,
    this._curve,
    this._height,
    this._width,
    this._color,
    this._borderRadius,
    this._useShadow,
    this._shadows,
  );

  @override
  Widget build(BuildContext context) {
    return AnimatedAlign(
      alignment: _alignment,
      duration: _duration,
      curve: _curve,
      child: Container(
        height: _height,
        width: _width,
        child: Container(
          decoration: BoxDecoration(
            color: _color,
            borderRadius: _borderRadius,
            boxShadow: _useShadow ? _shadows : null,
          ),
        ),
      ),
    );
  }
}
