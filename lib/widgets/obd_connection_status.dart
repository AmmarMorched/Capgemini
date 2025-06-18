import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_models/OBD_viewmodel.dart';

class ConnectionStatusIndicator extends StatelessWidget {
  const ConnectionStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OBDViewModel>(
      builder: (context, viewModel, child) {
        return Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: viewModel.isConnected ? Colors.red : Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              // Text(
              //   viewModel.isConnected ? 'Connected' : 'Disconnected',
              //   style: TextStyle(
              //     color: viewModel.isConnected ? Colors.green : Colors.red,
              //     fontWeight: FontWeight.w500,
              //   ),
              // ),
            ],
          ),
        );
      },
    );
  }
}