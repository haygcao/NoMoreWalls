part of '../service_utils.dart';

extension NavigationUtils on ServiceUtils {
  static void navigate(BuildContext context, String location, {Object? extra}) {
    if (GoRouterState.of(context).matchedLocation == location) return;
    GoRouter.of(context).go(location, extra: extra);
  }

  static void navigateNamed(
    BuildContext context,
    String name, {
    Object? extra,
    Map<String, String>? pathParameters,
    Map<String, dynamic>? queryParameters,
  }) {
    if (GoRouterState.of(context).matchedLocation == name) return;
    GoRouter.of(context).goNamed(
      name,
      pathParameters: pathParameters ?? const {},
      queryParameters: queryParameters ?? const {},
      extra: extra,
    );
  }

  static void push(BuildContext context, String location, {Object? extra}) {
    final router = GoRouter.of(context);
    final routerState = GoRouterState.of(context);
    final routerStack = router.routerDelegate.currentConfiguration.matches
        .map((e) => e.matchedLocation);

    if (routerState.matchedLocation == location ||
        routerStack.contains(location)) return;
    router.push(location, extra: extra);
  }

  static void pushNamed(
    BuildContext context,
    String name, {
    Object? extra,
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
  }) {
    final router = GoRouter.of(context);
    final routerState = GoRouterState.of(context);
    final routerStack = router.routerDelegate.currentConfiguration.matches
        .map((e) => e.matchedLocation);

    final nameLocation = routerState.namedLocation(
      name,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
    );

    if (routerState.matchedLocation == nameLocation ||
        routerStack.contains(nameLocation)) {
      return;
    }
    router.pushNamed(
      name,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      extra: extra,
    );
  }
}