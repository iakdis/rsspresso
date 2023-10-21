import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoTab extends StatelessWidget {
  const InfoTab({super.key});

  void launchGitHubURL() async {
    final uri = Uri.parse('https://github.com/iakmds/rsspresso');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      print('Could not launch $uri');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/icon.png',
            height: 128,
            width: 128,
          ),
          const SizedBox(height: 16.0),
          SelectableText(
            'rssPresso',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          FutureBuilder(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                final version = snapshot.data?.version ?? '';
                return SelectableText(
                  'Version $version',
                  style: Theme.of(context).textTheme.labelLarge,
                );
              }),
          const SizedBox(height: 16.0),
          SizedBox(
            width: 512,
            child: SelectableText.rich(
              TextSpan(
                text:
                    'The code is licensed under the GNU Public License v3 on ',
                children: [
                  WidgetSpan(
                    alignment: PlaceholderAlignment.top,
                    child: Tooltip(
                      message: 'https://github.com/iakmds/rsspresso',
                      child: GestureDetector(
                        onTap: launchGitHubURL,
                        child: Text.rich(
                          TextSpan(
                            text: 'GitHub',
                            mouseCursor: SystemMouseCursors.click,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.transparent,
                                  shadows: [
                                    const Shadow(
                                        color: Colors.blue,
                                        offset: Offset(0, -2))
                                  ],
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.blue,
                                  decorationThickness: 1.0,
                                ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const TextSpan(
                    text:
                        '. If you encounter any problem or want to request a feature, please open an issue on GitHub. Thanks!',
                  ),
                ],
              ),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
