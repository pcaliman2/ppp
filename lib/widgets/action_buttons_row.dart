import 'package:flutter/material.dart';

class ActionButtonsRow extends StatelessWidget {
  const ActionButtonsRow({super.key});

  @override
  Widget build(BuildContext context) {
    // --- INICIO: Sección comentada por solicitud ---
    /*
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'OWA is Mexico City\'s first wellness club of its kind—bringing together the essential pillars of human wellbeing in one place. By integrating contrast therapies, nutrition, supplementation, social connection, and hospitality, OWA creates an integrated ecosystem designed for vitality.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {},
                child: Text('BOOK A SESSION'),
              ),
              SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {},
                child: Text('BECOME A MEMBER'),
              ),
              SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {},
                child: Text('STAY AT OWA'),
              ),
            ],
          ),
        ],
      ),
      */
    // --- FIN: Sección comentada por solicitud ---
    // Retorno alternativo para evitar errores
    return SizedBox.shrink();
  }
}
