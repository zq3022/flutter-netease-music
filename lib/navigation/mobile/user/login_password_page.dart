import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../extension.dart';
import '../../../providers/navigator_provider.dart';
import '../../common/login/login.dart';

class LoginPasswordPage extends HookConsumerWidget {
  const LoginPasswordPage({
    super.key,
    required this.phoneNumber,
    required this.registered,
  });

  final String phoneNumber;
  final bool registered;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    LogUtil.e('login_password_page::$phoneNumber,$registered');
    return Scaffold(
      appBar: AppBar(
        title: Text(context.strings.loginWithPhone),
        elevation: 0,
      ),
      body: LoginPasswordWidget(
        phone: phoneNumber,
        registered: registered,
        onVerified: () {
          ref.read(navigatorProvider.notifier)
            ..back()
            ..back();
        },
      ),
    );
  }
}
