import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../extension.dart';
import '../../providers/key_value/settings_provider.dart';
import '../../providers/navigator_provider.dart';

class ThemeSwitchRadios extends ConsumerWidget {
  const ThemeSwitchRadios({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(
      settingKeyValueProvider.select((value) => value.themeMode),
    );
    final notifier = ref.read(settingKeyValueProvider.notifier);
    return Column(
      children: [
        RadioListTile<ThemeMode>(
          onChanged: (mode) => notifier.themeMode = mode!,
          groupValue: themeMode,
          value: ThemeMode.system,
          title: Text(context.strings.themeAuto),
        ),
        RadioListTile<ThemeMode>(
          onChanged: (mode) => notifier.themeMode = mode!,
          groupValue: themeMode,
          value: ThemeMode.light,
          title: Text(context.strings.themeLight),
        ),
        RadioListTile<ThemeMode>(
          onChanged: (mode) => notifier.themeMode = mode!,
          groupValue: themeMode,
          value: ThemeMode.dark,
          title: Text(context.strings.themeDark),
        ),
      ],
    );
  }
}

class CopyRightOverlayCheckBox extends ConsumerWidget {
  const CopyRightOverlayCheckBox({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CheckboxListTile(
      value:
          ref.watch(settingKeyValueProvider.select((value) => value.copyright)),
      onChanged: (value) {
        ref.read(settingKeyValueProvider.notifier).copyright = value ?? false;
      },
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(context.strings.hideCopyrightOverlay),
    );
  }
}

class DebugPlatformNavigationRadios extends ConsumerWidget {
  const DebugPlatformNavigationRadios({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final platform = ref.watch(debugNavigatorPlatformProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RadioListTile<NavigationPlatform>(
          onChanged: (mode) =>
              ref.read(debugNavigatorPlatformProvider.notifier).state = mode!,
          groupValue: platform,
          value: NavigationPlatform.desktop,
          title: Text(NavigationPlatform.desktop.name),
        ),
        RadioListTile<NavigationPlatform>(
          onChanged: (mode) =>
              ref.read(debugNavigatorPlatformProvider.notifier).state = mode!,
          groupValue: platform,
          value: NavigationPlatform.mobile,
          title: Text(NavigationPlatform.mobile.name),
        ),
        RadioListTile<NavigationPlatform>(
          onChanged: (mode) =>
              ref.read(debugNavigatorPlatformProvider.notifier).state = mode!,
          groupValue: platform,
          value: NavigationPlatform.tablet,
          title: Text(NavigationPlatform.tablet.name),
        ),
      ],
    );
  }
}

class SkipAccompanimentCheckBox extends ConsumerWidget {
  const SkipAccompanimentCheckBox({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CheckboxListTile(
      value: ref.watch(
        settingKeyValueProvider.select((value) => value.skipAccompaniment),
      ),
      onChanged: (value) => ref
          .read(settingKeyValueProvider.notifier)
          .skipAccompaniment = value ?? false,
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(context.strings.skipAccompaniment),
    );
  }
}
