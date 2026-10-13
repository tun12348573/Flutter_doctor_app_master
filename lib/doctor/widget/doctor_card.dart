import 'package:practice/l10n/app_strings.dart';
import 'package:flutter/material.dart';
import '../model/doctor.dart';

class DoctorCard extends StatelessWidget {
  const DoctorCard({super.key, required this.doctor, this.onTap});
  final Doctor doctor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CircleAvatar(
                    radius: 28,
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: doctor.profileImageUrl.isEmpty
                        ? const Icon(Icons.person_outline, size: 30)
                        : ClipOval(
                            child: Image.network(doctor.profileImageUrl,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.person_outline)))),
                const SizedBox(width: 16),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text('${doctor.firstName} ${doctor.lastName}',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(context.tr(doctor.category),
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text(doctor.city),
                      Text(
                          context.tr('{years} years of experience',
                              {'years': doctor.yearsOfExperience}),
                          style: Theme.of(context).textTheme.bodySmall),
                      if (onTap != null)
                        Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(context.tr('View profile'),
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary))),
                    ])),
              ]),
            )),
      );
}
