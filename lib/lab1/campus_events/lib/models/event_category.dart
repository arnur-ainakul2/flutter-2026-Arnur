import 'package:flutter/material.dart';

enum EventCategory {
  tech(label: 'Technology', icon: Icons.computer),
  sport(label: 'Sport', icon: Icons.sports),
  art(label: 'Art', icon: Icons.palette),
  science(label: 'Science', icon: Icons.science),
  social(label: 'Social', icon: Icons.people);

  const EventCategory({required this.label, required this.icon});

  final String label;
  final IconData icon;

  Color color(ColorScheme scheme) => switch (this) {
    EventCategory.tech => scheme.primary,
    EventCategory.sport => scheme.tertiary,
    EventCategory.art => scheme.secondary,
    EventCategory.science => scheme.primaryContainer,
    EventCategory.social => scheme.secondaryContainer,
  };
}
