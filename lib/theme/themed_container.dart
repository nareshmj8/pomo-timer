import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

class ThemedContainer extends StatelessWidget {
  final Widget child;

  const ThemedContainer({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;

    return Container(
      decoration: BoxDecoration(
        color: theme.backgroundGradient == null ? theme.backgroundColor : null,
        gradient: theme.backgroundGradient,
      ),
      child: DefaultTextStyle(
        style: TextStyle(color: theme.textColor),
        child: child,
      ),
    );
  }
}
