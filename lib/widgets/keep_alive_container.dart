import 'package:flutter/material.dart';

class KeepAliveContainer extends StatefulWidget {
  final Widget child;

  const KeepAliveContainer({super.key, required this.child});

  @override
  State<KeepAliveContainer> createState() => _KeepAliveContainerState();
}

class _KeepAliveContainerState extends State<KeepAliveContainer> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}
