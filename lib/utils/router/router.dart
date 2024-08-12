
import 'package:auto_route/auto_route.dart';
import 'package:gainz/domain/repositories/auth_repository.dart';
import 'package:gainz/utils/di/injector.dart';
import 'router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen|Page,Route')
class AppRouter extends RootStackRouter {

  @override
  RouteType get defaultRouteType => const RouteType.material();

  @override
  List<AutoRoute> get routes => [
    /// routes go here
    AutoRoute(page: LandingRoute.page, initial: true, guards: [
      AutoRouteGuard.simple((resolver, stackRouter){
        final authenticated = Injector.resolve<AuthRepository>().isAuthenticated();

        if(authenticated) {
          // if user is authenticated we
          // redirect to home screen
          resolver.redirect(const HomeRoute());
        } else {
          // we continue to the landing page if not authenticated
          resolver.next(true);
        }
      })
    ]),
    AutoRoute(page: HomeRoute.page, maintainState: false),
    AutoRoute(page: WorkoutRoute.page),
  ];
}