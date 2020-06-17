import 'package:flutter/material.dart';

class SilverWrapper extends StatefulWidget {
  final Widget child;

  SilverWrapper({@required this.child});

  @override
  _SilverWrapperState createState() => _SilverWrapperState();
}

class _SilverWrapperState extends State<SilverWrapper> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();
  }
}
